clear; %close all; clc;
% University of British Columbia, Vancouver, 2017
%   Dr. Guy Nir
%   Shahriar Noroozi Zadeh
%   Amir Refaee
%   Lap-Tak Chu

PARALLEL_PROCESSING = true; % for parallel processing. also need to switch FOR/for below
PLOT_RESULTS = false;

[~, ~, ~,testPath,BLK_SIZE_X,BLK_SIZE_Y,SCALE_INDX_PROCESS,~] = ...
                                       RunTimeInformation([],[],'r',0,0,0);

% define constants
%BLK_SIZE_X = 750; % in full image pixel coordinates, 0.504[um/pixel] in 20x
%BLK_SIZE_Y = 750; % in full image pixel coordinates, 0.504[um/pixel] in 20x

BLK_SAMP_X = BLK_SIZE_X; % BLK_SIZE_X/2; % sampling rate of blocks (distance between blocks in full image pixel coordinates)
BLK_SAMP_Y = BLK_SIZE_Y; % BLK_SIZE_Y/2; % sampling rate of blocks (distance between blocks in full image pixel coordinates)

SLIDE_PATH = testPath;
POSTFIX_MAT = ['_brain_demo.mat'];
POSTFIX_SVS = '.svs';

%SCALE_INDX_PROCESS = 1; % 1: full img scale, 3: 1/4 img scale

BRIGHT_THRESH = 220; % bright gray intensity for block to be classified as glass
DARK_THRESH = 130; % dark gray intensity for block to be classified as marker pen

MEMORY_LIMIT = 2e7; % mem = memory; mem.MaxPossibleArrayBytes/8 % max number of doubles
NORMAL_CLASS = single(0);
GLASS_CLASS = single(-97);
MARKER_CLASS = single(-98);
INVALID_CLASS = single(-99);
% end define constants

% SlideListMat = dir([SLIDE_PATH,'*',POSTFIX_MAT]); for k = 1:length(SlideListMat), SlideListMat(k).name = SlideListMat(k).name(1:(end-length(POSTFIX_MAT))); end, SlideListMat = {SlideListMat.name}';
% SlideListSvs = dir([SLIDE_PATH,'*',POSTFIX_SVS]); for k = 1:length(SlideListSvs), SlideListSvs(k).name = SlideListSvs(k).name(1:(end-length(POSTFIX_SVS))); end, SlideListSvs = {SlideListSvs.name}';
% SlideId = SlideListSvs(~ismember(SlideListSvs,SlideListMat) ); % slides that have .svs and .xml files, but no .mat file...
% slide_num = length(SlideId); % single slide

% multi-slide processsing: to be run in a 'while (true), slide_process; end' on multiple computers --

% if (isempty(SlideId))
%     error('No more slides...');
% else
%     save([SLIDE_PATH,SlideId{slide_indx},POSTFIX_MAT],'slide_indx'); % save preliminary .mat file so that other computers avoid processing the same slide...
% end
% end multi-slide processsing

ImgFile = SLIDE_PATH;
%XmlFile = [SLIDE_DIR,SlideId{slide_indx},POSTFIX_XML];

% picture=imread(ImgFile,'Index',SCALE_INDX_PROCESS);
% imshow(rgb2gray(picture),[DARK_THRESH BRIGHT_THRESH]);
% pause;

% read images info and sizes
img_info = imfinfo(ImgFile);
img_size_x = [img_info(:).Width];
img_size_y = [img_info(:).Height];

[full_img_size_x,full_scale_indx] = max(img_size_x);
[full_img_size_y,~] = max(img_size_y);

res_scale_x = max(1./round(full_img_size_x./img_size_x), round(img_size_x./full_img_size_x));
res_scale_y = max(1./round(full_img_size_y./img_size_y), round(img_size_y./full_img_size_y));

valid_scale = (res_scale_x == res_scale_y);
[small_img_size_x,small_scale_indx] = min(img_size_x./valid_scale);
[small_img_size_y,~] = min(img_size_y./valid_scale);

blk_vec_x = floor(mod(full_img_size_x,BLK_SIZE_X)/2+1):BLK_SAMP_X:floor(full_img_size_x-mod(full_img_size_x,BLK_SIZE_X)/2); % leave equal margins
blk_vec_y = floor(mod(full_img_size_y,BLK_SIZE_Y)/2+1):BLK_SAMP_Y:floor(full_img_size_y-mod(full_img_size_y,BLK_SIZE_Y)/2); % leave equal margins
[blk_ulc_x,blk_ulc_y] = meshgrid(blk_vec_x,blk_vec_y); % blocks' upper left corner matrix -- full image coordinates
blk_brc_x = blk_ulc_x+BLK_SIZE_X-1; blk_brc_y = blk_ulc_y+BLK_SIZE_Y-1; % blocks' bottom right corner matrix -- full image coordinates

% read & initialize slide structure
Slide.SlideName = 'current';
Slide.SlideId = 1;
slide_indx = 1;


% prepare for block processing
blk_num_x = length(blk_vec_x(:));
blk_num_y = length(blk_vec_y(:));
blk_num = blk_num_x*blk_num_y;

% gland_feat_num = length(GlandFeatures_guy6(zeros(3,3), zeros(3,3)));
% cell_feat_num = length(CellFeatures_guy7(zeros(3,3,3), zeros(3,3),zeros(3,3),zeros(3,3),zeros(3,3)));
feat_num = length(ExtractBlkFeat(ones(8,8,3,'uint8'),1)); % gland_feat_num+cell_feat_num; % check the total number of features by processing an empty block
blk_feat = nan(blk_num,feat_num,'single'); % feature matrix (row i'th represents the feature vector of block i'th)

% classify block if inside an annotated region
blk_class = (INVALID_CLASS)*ones(size(blk_ulc_x),'single'); % initialize classes as invalid

if (PARALLEL_PROCESSING) % don't forget to switch FOR/PARFOR below
    parpool; % matlabpool;
end % PARALLEL_PROCESSING

% start processing blocks...
BlkStruct = struct;
parfor blk_indx = 1:blk_num % <== Change FOR to PARFOR to use parallel processing...
    tic;
    % disp(['Starting block ',num2str(blk_indx),'/',num2str(blk_num)]);
    
    scale_indx = SCALE_INDX_PROCESS; % for multi-scale processing, insert a for loop here...
    blk_cols = res_scale_x(scale_indx)*(blk_ulc_x(blk_indx) + blk_brc_x(blk_indx))/2 + [-BLK_SIZE_X+1, BLK_SIZE_X-1]/2;
    blk_rows = res_scale_y(scale_indx)*(blk_ulc_y(blk_indx) + blk_brc_y(blk_indx))/2 + [-BLK_SIZE_Y+1, BLK_SIZE_Y-1]/2;
    if ( (blk_cols(1) < 1) || (blk_cols(2) > img_size_x(scale_indx)) || ...
            (blk_rows(1) < 1) || (blk_rows(2) > img_size_y(scale_indx)) )
        blk_rgb = zeros(BLK_SIZE_Y,BLK_SIZE_X,3,'uint8'); % out of image bounds
    else
        blk_rgb = imread(ImgFile,'Index',scale_indx,'PixelRegion',{[blk_rows],[blk_cols]}); % read current block from image file
    end
    
    % pre-classify blocks
    r=mean2(blk_rgb(:,:,1));
    b=mean2(blk_rgb(:,:,2));
    g=mean2(blk_rgb(:,:,3));
    if (r > BRIGHT_THRESH && g > BRIGHT_THRESH && b > BRIGHT_THRESH) % bright block -- probably glass
        blk_class(blk_indx) = GLASS_CLASS; % assign glass class
        
    elseif ((abs(r-b)<5)&& (abs(r-g)<5) &&(abs(g-b)<5)) % dark block -- probably marker pen
        blk_class(blk_indx) = MARKER_CLASS; % assign marker pen class %was marker class
        
    elseif (blk_class(blk_indx) == INVALID_CLASS) % unclassified block -- probably normal tissue
        blk_class(blk_indx) = NORMAL_CLASS; % assign normal tissue class
    end % end pre-classify blocks
    
    % extract block features vector
    if (blk_class(blk_indx) >= NORMAL_CLASS) % used to be (blk_class(blk_indx) >= NORMAL_CLASS) to process only blocks that are fully normal tissue or within an annotation (for an unseen slide valid blocks are pre-classified as normal and will be processed)
        blk_feat(blk_indx,:) = ExtractBlkFeat(blk_rgb,scale_indx);
        
        if any(isnan(blk_feat(blk_indx,:)))
            blk_class(blk_indx) = INVALID_CLASS; % feature extraction failed -- assign invalid class
        end
    end % end extract block features vector
    
    BlkStruct(blk_indx).BlkUlc = [blk_ulc_x(blk_indx), blk_ulc_y(blk_indx)];
    BlkStruct(blk_indx).BlkBrc = [blk_brc_x(blk_indx), blk_brc_y(blk_indx)];
    BlkStruct(blk_indx).BlkClass = blk_class(blk_indx);
    BlkStruct(blk_indx).BlkFeat = blk_feat(blk_indx,:);
    
    disp(['Finished block ',num2str(blk_indx),'/',num2str(blk_num),' at ',num2str(toc),'sec']);
end % for blk_indx

if (PARALLEL_PROCESSING)
    delete(gcp); % matlabpool close;
end % PARALLEL_PROCESSING

% finalize processing
Slide.BlkSize = [BLK_SIZE_X, BLK_SIZE_Y]; % in full image coordinates
Slide.BlkNumX = blk_num_x;
Slide.BlkNumY = blk_num_y;
Slide.BlkNum = blk_num;
Slide.Blk = BlkStruct;

% some .svs image parameters...
Slide.Img.ImgFullSize = [full_img_size_x, full_img_size_y];
Slide.Img.ResScale = [res_scale_x; res_scale_y];
Slide.Img.ScaleIndx = SCALE_INDX_PROCESS; % = 1 full_scale_indx


global FEATURE_INFO;
FEATURE_INFO.blk_vec_x = blk_vec_x;
FEATURE_INFO.blk_vec_y = blk_vec_y;
FEATURE_INFO.blk_ulc_x = blk_ulc_x;
FEATURE_INFO.blk_ulc_y = blk_ulc_y;
FEATURE_INFO.blk_brc_x = blk_brc_x;
FEATURE_INFO.blk_brc_y = blk_brc_y;
FEATURE_INFO.blk_num_x = blk_num_x;
FEATURE_INFO.blk_num_y = blk_num_y;  
FEATURE_INFO.blk_feat = blk_feat;
FEATURE_INFO.blk_class = blk_class; 
FEATURE_INFO.blk_num = blk_num; 
FEATURE_INFO.res_scale_x = res_scale_x; 
FEATURE_INFO.res_scale_y = res_scale_y; 
FEATURE_INFO.ImgFile = ImgFile; 

%global RESULTS_PATH;
%save(strcat(RESULTS_PATH,'/features.mat'),'blk_*','ImgFile','res_scale_*');
disp('Finished!');

% plot class image...
% if PLOT_RESULTS == true
%     color_mat = [1,1,1;0.5,0.3,0.5]; % add "glass" (invalid) and "normal tissue" colors
% 
%     figure;
%     axis image; caxis([-1,3]); colormap(color_mat); % the most "diverse" slice
%     title(['Slide ',num2str(slide_indx),': Ground-truth'],'FontSize',14);
%     colorbar('Ticks',linspace(-0.5,size(color_mat,1)-2+0.5,size(color_mat,1)+1),...
%         'TickLabels',{'Invalid','Benign','Label 1','Label 2','Label 3'},'Location','EastOutside','FontSize',14);
%     imagesc(reshape([Slide.Blk(:).BlkClass],Slide.BlkNumY,Slide.BlkNumX));
% 
%     pause(10); % pause for cooling down cpu before starting a new slide...
% end