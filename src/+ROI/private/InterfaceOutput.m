% University of British Columbia, Vancouver, 2017
%   Dr. Guy Nir
%   Shahriar Noroozi Zadeh
%   Amir Refaee
%   Lap-Tak Chu

clear; close all; clc;


[fpath,~,~,~,~,~,scale_indx,~] = RunTimeInformation([],[],'r',0,0,0);


global SLIDE_DATA;
%load([fpath,'/TestingInfo']);

global RESULTS_PATH

PARALLEL_PROCESSING = true; % for parallel processing. also need to switch FOR/PARFOR below
INVALID_BLK = -99;
GRAY_MATTER = 0;


for slide_idx = 1:length(SLIDE_DATA)
    % Make Directory For Slide and Images


    blk_num = length(SLIDE_DATA{slide_idx}.blk_label);
    
    DPslide(blk_num) = struct(); DPslide(blk_num).Id = blk_num; %#ok<*SAGROW>
    DPslide(blk_num).Pos = {[0,0];[0,0]};
    DPslide(blk_num).Label = 0; DPslide(blk_num).Region = ''; DPslide(blk_num).SlideId = '';
    
    XX = size(SLIDE_DATA{slide_idx}.blk_brc_x,2);
    YY = size(SLIDE_DATA{slide_idx}.blk_brc_y,1);
    
    % Block Processing
    if (PARALLEL_PROCESSING) % don't forget to switch FOR/PARFOR below
        parpool; % matlabpool;
    end % PARALLEL_PROCESSING
    
    parfor blk_idx = 1:blk_num % <= Change FOR to PARFOR when parallel
        tic;
        x = ceil(blk_idx/YY);
        y = mod(blk_idx,YY); if ~y, y = YY; end
        
        DPslide(blk_idx).Id = blk_idx;
        % Structure: { [x_ulc , y_ulc] ; [x_brc , y_brc] }
        DPslide(blk_idx).Pos = {[SLIDE_DATA{slide_idx}.blk_ulc_x(y,x),SLIDE_DATA{slide_idx}.blk_ulc_y(y,x)],...
                                [SLIDE_DATA{slide_idx}.blk_brc_x(y,x),SLIDE_DATA{slide_idx}.blk_brc_y(y,x)]}; 
        %#ok<*PFBNS>

        DPslide(blk_idx).Label = SLIDE_DATA{slide_idx}.blk_label(blk_idx);
        switch DPslide(blk_idx).Label
            case INVALID_BLK
                DPslide(blk_idx).Region = 'Glass';
            case GRAY_MATTER
                DPslide(blk_idx).Region = 'GrayMatter';
            otherwise
                DPslide(blk_idx).Region = 'WhiteMatter';
        end

        if (DPslide(blk_idx).Label ~= INVALID_BLK) && (DPslide(blk_idx).Label ~= GRAY_MATTER)
            blkCols = [SLIDE_DATA{slide_idx}.blk_ulc_x(y,x) , SLIDE_DATA{slide_idx}.blk_brc_x(y,x)]; 
            blkRows = [SLIDE_DATA{slide_idx}.blk_ulc_y(y,x) , SLIDE_DATA{slide_idx}.blk_brc_y(y,x)];
%             blk = imread(Slide{slide_idx}.ImgFile,'Index',scale_indx,'PixelRegion',{blkRows,blkCols});
%             imwrite(blk,[imgPath,'/',num2str(DPslide(blk_idx).Id),'.tif']);
        end
        
        DPslide(blk_idx).SlideId = slide_idx;
        
        disp(['Slide ',slide_idx,', Finished block ',num2str(DPslide(blk_idx).Id),'/', ...
              num2str(blk_num),' at ',num2str(toc),'sec']);
    end
    
    if (PARALLEL_PROCESSING)
        delete(gcp); % matlabpool close;
    end % PARALLEL_PROCESSING
    
    disp(['Finished Slide ',slide_idx,]);
end

disp('   Finished All Slides!   ');
