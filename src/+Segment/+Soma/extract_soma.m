  % University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi
% 
% The main acting algorithm that actually segments the cell bodies.
%
% dpimage - image object
% cell_classifier - classifier object
function [list,dp] = extract_soma( dpimage, cell_classifier )

    if(~exist('cell_classifier','var'))
        cell_classifier = [];
    end
    
    %%%%SEGMENTATION%%%%%

    input_image = dpimage.image;

    % Converting image to grayscale, increasing contrast.
    grayIm = rgb2gray(input_image);
    % grayIm = input_image(:,:,1);
    grayIm = grayIm + (255-mean(grayIm(grayIm<200)));

    % Mumford-Shah smoothing
    mumfordIm = smooth_ms(grayIm, Config.get_config('MUMFORD_SHAH_LAMBDA'), -1);

    %quantize so imregionalmin is more robust
    tolerance = 5;
    ths = tolerance:tolerance:(255-tolerance);
    values = round((tolerance/2):tolerance:255);
    mumfordIm = uint8(imquantize(mumfordIm,ths,values));
    
    adjusted_im = imadjust(mumfordIm,[0; Config.get_config('WHITE_DISCARD_THRESHOLD')],[0; 1]);
    
    bwIm = ~imregionalmin(adjusted_im);
    
    bw_small_pieces = ~bitxor(~bwareaopen(~bwIm,10),bwIm);
    mumfordIm(~bw_small_pieces) = 255;
    
    bwIm = ~imregionalmin(mumfordIm);
    bwIm = ~bitor(~bwIm,~bw_small_pieces);
  
    dpimage.preThresh = mumfordIm;
    dpimage.rawThresh = bwIm;

    % Filtering by object size
    somaIm = Tools.size_filter(bwIm,Config.get_config('LOWER_SIZE_BOUND'), 10000000);

    %%%%%%
    
    dpimage.somaMask = somaIm;
    comp = bwconncomp(imcomplement(somaIm));

    
    list = {};
    for i=1:comp.NumObjects
        [row,col] = ind2sub(comp.ImageSize,comp.PixelIdxList{i});
        
        prepared = prepare_soma(DPCell([col,row],dpimage)); 
        % Loop through the cells since there could be multiple detected
        % from resolving clumps
        for j=1:size(prepared,2)
            dpcell = prepared{j}; 
            

            if (Config.get_config('USE_DEEP_FILTER'))
                [good,best] = predict_valid(cell_classifier,dpcell);
                dpcell.isFalsePositive = ~good;
                dpcell.isBestCell = best;
            end
            list{end+1} = dpcell;
            
        end
    end    
    dp = dpimage;
%     Verify.display_segment(dp,list)
   end

