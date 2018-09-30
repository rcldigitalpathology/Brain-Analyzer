clc;
% University of British Columbia, Vancouver, 2017
%   Dr. Guy Nir
%   Shahriar Noroozi Zadeh
%   Amir Refaee
%   Lap-Tak Chu

global RESULTS_PATH;

PARALLEL_PROCESSING = false; % for parallel processing. also need to switch FOR/PARFOR below
PLOT_RESULTS = false;

% classification parameters, also set USED_FEAT below...
CLASS_LABELS = {[0],[1,2,99]}; %,[2],[99]}; % group classes into labels
color_mat = [1,1,1; 0.5,0.3,0.5; 0,0.7,0; 1,0.7,0; 0,0,1]; % "invalid": white, "benign": Purple, "label1": Yellow, "label2": Green, "label3": Blue

label_num = length(CLASS_LABELS);

TRAIN_ANNOT_MIN_TRIM = false; % to trim the training set such that each annotation has the same number of training blocks (equal to the annotation with the minimum blocks)
MAX_TRAIN_BLKS = 1e3; % maximum number of training blocks from each label
TRAIN_RATE = 1.00; % 0.33 normally, 1.00 for leave-out experiments

% classifier parameters
CLASSIFIER_TYPE = 'svm'; % 'rdf' (random forest), 'svm' (support vector machine), 'knn' (k-nearest neighbor), 'lda' (linear discriminant analysis), 'nbc' (naive Bayes classifier)

RDF_NumTrees = 100; % number of trees parameter for the random forest algorithm (TreeBagger function)
RDF_MinLeaf = 1; % min leaf parameter for random forest algorithm (TreeBagger function)

KNN_NumNeighbors = 5; % number of nearest neighbors
KNN_Distance = 'euclidean'; % distance metric

LDA_DiscrimType = 'diaglinear'; % discriminant type ('linear', 'diaglinear', 'pseudolinear'). 'quadratic' fails due to singular covariance matrices...

NBC_DistributionNames = 'kernel'; % distribution type ('normal', 'kernel', 'mn', 'mvmn')

% define constants
[fpath, ~, ~, testPath,~,~,~,~] = RunTimeInformation([],[],'r',0,0,0);
SLIDE_DIR = testPath;
POSTFIX_MAT = ['_brain_demo.mat'];
POSTFIX_SVS = '.tif';
POSTFIX_XML = '.xml';


%load([RESULTS_PATH,'/training.mat']);

% if exist([fpath,'/TrainingInfo.mat'],'file')
%     load([fpath,'/TrainingInfo']);
% else
%     load([oldPath,'/TrainingInfo']);
%     copyfile([oldPath,'/TrainingInfo.mat'],fpath);
% end

MEMORY_LIMIT = 2e7; % mem = memory; mem.MaxPossibleArrayBytes/8 % max number of doubles
NORMAL_CLASS = single(0);
GLASS_CLASS = single(-97);
MARKER_CLASS = single(-98);
INVALID_CLASS = single(-99);
% end define constants

slide_num = 1; % single slide

% load data
blk_class = cell(slide_num,1);
blk_label = cell(slide_num,1);
blk_test_feat = cell(slide_num,1);
blk_test_slide = cell(slide_num,1);
blk_patient = cell(slide_num,1);

global FEATURE_INFO;    
for slide_indx = 1:slide_num
    disp(['Loading slide ',num2str(slide_indx),'/',num2str(slide_num)]);

    Slide{slide_indx} = FEATURE_INFO;
    
    blk_class{slide_indx} = single(Slide{slide_indx}.blk_class(:)); % cast to single to save memory
    blk_test_feat{slide_indx}  = single(Slide{slide_indx}.blk_feat); % cast to single to save memory
    
    blk_test_slide{slide_indx} = 0.*blk_class{slide_indx} + slide_indx;
    blk_patient{slide_indx} = 0.*blk_class{slide_indx} + slide_indx; % <- change this based on ImgFile case ID
    blk_label{slide_indx} = 0.*blk_class{slide_indx} + INVALID_CLASS;
    for label_indx = 1:label_num
        blk_label{slide_indx}(ismember(blk_class{slide_indx},CLASS_LABELS{label_indx})) = label_indx - 1; % minus one to have "NORMAL" as 0
    end % for label_indx
    Slide{slide_indx}.blk_label = blk_label{slide_indx}; % just to keep Slide struct consistent...
end % for slide_indx

% concatenate blocks from all slides for more efficient processing...
blk_class_all_slides = cat(1,blk_class{:});
blk_label_all_slides = cat(1,blk_label{:});
blk_feat_all_slides = cat(1,blk_test_feat{:});
blk_slide_all_slides = cat(1,blk_test_slide{:});
blk_patient_all_slides = cat(1,blk_patient{:});

% %%%%% patch for demo
% blk_feat_all_slides(:,1) = blk_feat_all_slides(:,1) + randn(size(blk_class_all_slides(:)))*10^2+50;
% blk_feat_all_slides(:,2) = blk_feat_all_slides(:,2) + blk_class_all_slides(:)*100;
% %%%%% end patch for demo

% some more classification parameters...
patient_vec = unique(blk_patient_all_slides(blk_patient_all_slides > 0))';
patient_num = length(patient_vec);
% feat_num = size(Slide{slide_indx}.blk_feat,2); % total full number of features
% USED_FEAT = 1:feat_num; % all features
feat_num = size(Slide{slide_indx}.blk_feat,2); % total full number of features
USED_FEAT = 1:size(blk_feat_all_slides_mean,2); % all features (training data size)


% mark invalid blocks
blk_valid = cell(slide_num,1);
for slide_indx = 1:slide_num
    blk_valid{slide_indx} = ~( sum(isnan(blk_test_feat{slide_indx}(:,USED_FEAT)) ,2) | ... % a block with any feature value of NaN is considered invalid...
        sum(isinf(blk_test_feat{slide_indx}(:,USED_FEAT)) ,2) | ... % a block with any feature value of Inf is considered invalid...
        (blk_label{slide_indx}(:) < NORMAL_CLASS) ); % NOTE: using the ground-truth to determine invalid blocks for training purposes...
end % for slide_indx
blk_valid_all_slides = cat(1,blk_valid{:});

% leave-patient-out experiment
blk_mdl_all_slides_test_patient = cell(patient_num,1);

if (PARALLEL_PROCESSING) % don't forget to switch FOR/PARFOR below
    parpool; % matlabpool;
end % PARALLEL_PROCESSING

for slideIdx = 1:patient_num % <== Change FOR to PARFOR to use parallel processing...
    tic;
    disp(['Starting testing patient ',num2str(slideIdx),'/',num2str(patient_num)]);  
    

    % normalize each feature in training and testing sets based on distribution among the __TRAINING__ blocks...
    blk_feat_norm_all_slides = (blk_feat_all_slides - ones(size(blk_feat_all_slides,1),1)*blk_feat_all_slides_mean) ./ ...
        (ones(size(blk_feat_all_slides,1),1)*blk_feat_all_slides_std + eps);
   
    
    
    
    
    % Testing classifier
    [blk_mdl_all_slides, ~] = predict(cls_mdl, blk_feat_norm_all_slides(:,USED_FEAT));
    if ~strcmp(class(blk_mdl_all_slides),class(blk_label_all_slides)), blk_mdl_all_slides = single(str2double(blk_mdl_all_slides)); end
    blk_mdl_all_slides(~blk_valid_all_slides) = INVALID_CLASS;
    blk_mdl_all_slides_test_patient{slideIdx} = blk_mdl_all_slides;
    
    
    disp(['Finished predicting patient ',num2str(slideIdx),'/',num2str(patient_num),' at ',num2str(toc),'sec']);
end % parfor leaveout_indx



if (PARALLEL_PROCESSING)
    delete(gcp); % matlabpool close;
end % PARALLEL_PROCESSING

blk_mdl_test = cell(slide_num,1); % the results of the leaveout slides...
for slideIdx = 1:patient_num
    TEST_PATIENTS = patient_vec(slideIdx); % leaveout_indx;
    % leaveout_slides = unique( blk_slide_all_slides(ismember(blk_patient_all_slides,LEAVEOUT_PATIENTS)) );
    
    for slide_indx = 1:slide_num
        blk_mdl_test{slide_indx}( (ismember(blk_patient{slide_indx},TEST_PATIENTS)) & blk_valid{slide_indx}, 1 ) = ...
            blk_mdl_all_slides_test_patient{slideIdx}( (blk_slide_all_slides == slide_indx) & ...
            (ismember(blk_patient_all_slides,TEST_PATIENTS)) & (blk_valid_all_slides) );
        blk_mdl_test{slide_indx}(~blk_valid{slide_indx},1) = INVALID_CLASS;
    end % slide_indx
end % leaveout_indx
blk_mdl_test_all_slides = cat(1,blk_mdl_test{:});

% Update Slide Labels
for slide_indx = 1:slide_num
    Slide{slide_indx}.blk_label = blk_mdl_test{slide_indx};
end % for slide_indx

% plot and print classification results
% if (PLOT_RESULTS)
%     for slide_indx = 1:slide_num
%         figure;
%         imagesc(reshape(blk_mdl_test{slide_indx},Slide{slide_indx}.blk_num_y,Slide{slide_indx}.blk_num_x));
%         axis image; caxis([-1,label_num]); colormap(color_mat); % the most "diverse" slice
%         title(['Slide ',num2str(slide_indx),': Automatic classification'],'FontSize',14);
%         colorbar('Ticks',linspace(-0.5,size(color_mat,1)-2+0.5,size(color_mat,1)),...
%             'TickLabels',{'Invalid','Benign','Label 1','Label 2','Label 3'},'Location','EastOutside','FontSize',14);
%         
%         impixelinfo;
%         set(gcf, 'Position', get(0, 'Screensize'));
%     end % for slide_indx
% end % PLOT_RESULTS
