clear; close all; clc;
% University of British Columbia, Vancouver, 2017
%   Dr. Guy Nir
%   Shahriar Noroozi Zadeh
%   Amir Refaee
%   Lap-Tak Chu

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
[~, ~, trainDirectory, ~,~,~,~,~] = RunTimeInformation([],[],'r',0,0,0);
SLIDE_DIR = trainDirectory;
POSTFIX_MAT = ['_brain_demo.mat'];
POSTFIX_SVS = '.svs';
POSTFIX_XML = '.xml';

MEMORY_LIMIT = 2e7; % mem = memory; mem.MaxPossibleArrayBytes/8 % max number of doubles
NORMAL_CLASS = single(0);
GLASS_CLASS = single(-97);
MARKER_CLASS = single(-98);
INVALID_CLASS = single(-99);
% end define constants

% SlideListMat = dir([SLIDE_DIR,'*',POSTFIX_MAT]); for k = 1:length(SlideListMat), SlideListMat(k).name = SlideListMat(k).name(1:(end-length(POSTFIX_MAT))); end, SlideListMat = {SlideListMat.name}';
% SlideListSvs = dir([SLIDE_DIR,'*',POSTFIX_SVS]); for k = 1:length(SlideListSvs), SlideListSvs(k).name = SlideListSvs(k).name(1:(end-length(POSTFIX_SVS))); end, SlideListSvs = {SlideListSvs.name}';
% SlideListXml = dir([SLIDE_DIR,'*',POSTFIX_XML]); for k = 1:length(SlideListXml), SlideListXml(k).name = SlideListXml(k).name(1:(end-length(POSTFIX_XML))); end, SlideListXml = {SlideListXml.name}';
% SlideId = SlideListMat; % SlideListSvs( ismember(SlideListSvs,SlideListXml) & ismember(SlideListSvs,SlideListMat) ); % slides that have .svs, .xml and .mat files...
% slide_num = length(SlideId); % single slide

trainData = load('+ROI/trainBright.mat'); 
trainData = trainData.train;
slide_num = length(trainData);

% load data
blk_class = cell(slide_num,1);
blk_label = cell(slide_num,1);
blk_feat = cell(slide_num,1);
blk_slide = cell(slide_num,1);
blk_patient = cell(slide_num,1);

for slide_indx = 1:slide_num
    disp(['Loading slide ',num2str(slide_indx),'/',num2str(slide_num)]);
    %Slide{slide_indx} = load([SLIDE_DIR,'/',SlideId{slide_indx},POSTFIX_MAT],'blk_*','ImgFile','res_scale_*');
    Slide{slide_indx} = trainData{slide_indx};
    
    blk_class{slide_indx} = single(Slide{slide_indx}.blk_class(:)); % cast to single to save memory
    blk_feat{slide_indx}  = single(Slide{slide_indx}.blk_feat); % cast to single to save memory
    
    blk_slide{slide_indx} = 0.*blk_class{slide_indx} + slide_indx;
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
blk_feat_all_slides = cat(1,blk_feat{:});
blk_slide_all_slides = cat(1,blk_slide{:});
blk_patient_all_slides = cat(1,blk_patient{:});

% %%%%% patch for demo
% blk_feat_all_slides(:,1) = blk_feat_all_slides(:,1) + randn(size(blk_class_all_slides(:)))*10^2+50;
% blk_feat_all_slides(:,2) = blk_feat_all_slides(:,2) + blk_class_all_slides(:)*100;
% %%%%% end patch for demo

% some more classification parameters...
patient_vec = unique(blk_patient_all_slides(blk_patient_all_slides > 0))';
patient_num = length(patient_vec);
feat_num = size(Slide{slide_indx}.blk_feat,2); % total full number of features
USED_FEAT = 1:feat_num; % all features

% mark invalid blocks
blk_valid = cell(slide_num,1);
for slide_indx = 1:slide_num
    blk_valid{slide_indx} = ~( sum(isnan(blk_feat{slide_indx}(:,USED_FEAT)) ,2) | ... % a block with any feature value of NaN is considered invalid...
        sum(isinf(blk_feat{slide_indx}(:,USED_FEAT)) ,2) | ... % a block with any feature value of Inf is considered invalid...
        (blk_label{slide_indx}(:) < NORMAL_CLASS) ); % NOTE: using the ground-truth to determine invalid blocks for training purposes...
end % for slide_indx
blk_valid_all_slides = cat(1,blk_valid{:});


tic;
% prepare data
% blk_hist_all_slides = hist( blk_label_all_slides( blk_valid_all_slides & ...
%     ~ismember(blk_patient_all_slides,LEAVEOUT_PATIENTS) ), [1:label_num]-1 );
blk_hist_all_slides = hist( blk_label_all_slides( blk_valid_all_slides), [1:label_num]-1 );

% prepare training/testing sets
if (TRAIN_ANNOT_MIN_TRIM)
    train_num = ones(size(blk_hist_all_slides)).* min(MAX_TRAIN_BLKS, ceil(TRAIN_RATE*min(blk_hist_all_slides))); % train on the same number of blocks for each annotation
else
    train_num = min(MAX_TRAIN_BLKS, ceil(TRAIN_RATE*blk_hist_all_slides)); % train on a percentage of available blocks for each annotation
end

blk_train_all_slides = false(size(blk_label_all_slides));
for label_indx = 1:label_num
%     blk_to_choose_from = ( (blk_valid_all_slides) & (blk_label_all_slides == (label_indx - 1)) & ... % minus one to have "NORMAL" as 0
%         (~ismember(blk_patient_all_slides,LEAVEOUT_PATIENTS)) );
    
    blk_to_choose_from = ( (blk_valid_all_slides) & (blk_label_all_slides == (label_indx - 1)) ); % minus one to have "NORMAL" as 0

    blk_train_indx = datasample(find(blk_to_choose_from),train_num(label_indx),'Replace',false); % randomly sample "train_num(label_indx)" number of blocks from each label
    blk_train_all_slides(blk_train_indx) = true; % mark the randomly selected training blocks
end % for label_indx
blk_test_all_slides = ((blk_valid_all_slides) & (~blk_train_all_slides));  % mark the rest valid blocks as testing blocks

% normalize each feature in training and testing sets based on distribution among the __TRAINING__ blocks...
blk_feat_all_slides_mean = mean(blk_feat_all_slides(blk_train_all_slides,:),1);
blk_feat_all_slides_std = std(blk_feat_all_slides(blk_train_all_slides,:),0,1);
blk_feat_norm_all_slides = (blk_feat_all_slides - ones(size(blk_feat_all_slides,1),1)*blk_feat_all_slides_mean) ./ ...
    (ones(size(blk_feat_all_slides,1),1)*blk_feat_all_slides_std + eps);

learn_rand_indx = shuffle(find(blk_train_all_slides)); % the indices for a randomize traning set for learning...
if (sum(blk_train_all_slides)*1e2 > MEMORY_LIMIT)
    disp('Number of blocks might cause a stall... check memory...');
    break_; % break;
end

% Training classifier
switch lower(CLASSIFIER_TYPE)
    case 'rdf' % random forest classification
        cls_mdl = TreeBagger(RDF_NumTrees,blk_feat_norm_all_slides(learn_rand_indx,USED_FEAT),blk_label_all_slides(learn_rand_indx),'oobpred','on','minleaf',RDF_MinLeaf);
        %t = templateTree('PredictorSelection','curvature','Surrogate','on');
        %cls_mdl = fitcensemble(blk_feat_norm_all_slides(learn_rand_indx,USED_FEAT),blk_label_all_slides(learn_rand_indx),...
        %                       'Method','Bag','Learners',t);
        % figure; treedisp(cls_mdl.Trees{1})

    case 'svm' % support vector machine classification
        % [svm_struct, ~] = svmtrain(blk_feat_norm_all_slides(learn_rand_indx,USED_FEAT),(blk_label_all_slides(learn_rand_indx)); % svmtrain.m only supports classification into two groups...
        cls_mdl = fitcecoc(blk_feat_norm_all_slides(learn_rand_indx,USED_FEAT),blk_label_all_slides(learn_rand_indx),'ClassNames',single([1:label_num]-1)); % fitcecoc.m is a multiclass svm...

    case 'knn' % k-nearest neighbor classification
        cls_mdl = fitcknn(blk_feat_norm_all_slides(learn_rand_indx,USED_FEAT),blk_label_all_slides(learn_rand_indx),'NumNeighbors',KNN_NumNeighbors,'Distance',KNN_Distance,'ClassNames',single([1:label_num]-1));

    case 'lda' % discriminant analysis classification
        cls_mdl = fitcdiscr(blk_feat_norm_all_slides(learn_rand_indx,USED_FEAT),blk_label_all_slides(learn_rand_indx),'DiscrimType',LDA_DiscrimType,'ClassNames',single([1:label_num]-1));

    case 'nbc' % naive Bayes classification
        cls_mdl = fitcnb(blk_feat_norm_all_slides(learn_rand_indx,USED_FEAT),blk_label_all_slides(learn_rand_indx),'DistributionNames',NBC_DistributionNames,'ClassNames',single([1:label_num]-1));

    otherwise
        warning('Unknown CLASSIFIER_TYPE...');
        cls_mdl = [];
end % switch lower(CLASSIFIER_TYPE)

% Testing classifier
[blk_mdl_all_slides, ~] = predict(cls_mdl, blk_feat_norm_all_slides(:,USED_FEAT));
if ~strcmp(class(blk_mdl_all_slides),class(blk_label_all_slides)), blk_mdl_all_slides = single(str2double(blk_mdl_all_slides)); end
blk_mdl_all_slides(~blk_valid_all_slides) = INVALID_CLASS;
blk_mdl_all_slides_traing_patients = blk_mdl_all_slides;

disp(['Finished Training ',num2str(patient_num),' Patients at ',num2str(toc),'sec']);