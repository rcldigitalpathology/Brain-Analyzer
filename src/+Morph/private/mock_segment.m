% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis

% Performs a mock segmentation so the centroid can be found
% This is so we properly emulate the real process when calculating results
% for microglia morphology.


function cent = mock_segment(image)

    grayIm = image(:,:,3);

    grayIm = grayIm + (255-mean(grayIm(grayIm<200)));

    % Mumford-Shah smoothing
    mumfordIm = fastms(grayIm, 'lambda', Config.get_config('MUMFORD_SHAH_LAMBDA'), 'alpha', -1,'verbose',0); 

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

    %     dpimage.preThresh = mumfordIm;
    %     dpimage.rawThresh = bwIm;

    % Filtering by object size
    %%%%%%

    comp = bwconncomp(imcomplement(bwIm));

    numOfPixels = cellfun(@numel,comp.PixelIdxList);
    [unused,indexOfMax] = max(numOfPixels);
    [row,col] = ind2sub(comp.ImageSize,comp.PixelIdxList{indexOfMax});

    L = [col,row]; %[col, row]

    dim = size(image);
    mask = false(dim(1:2));          
    for i=1:size(L,1)
        mask(round(L(i,2)),round(L(i,1))) = 1;                
    end

    % SOMA CENTER CALCULATION
    for i=1:5
        newmask = imerode(mask,strel('disk',1));
        if (any(newmask(:)))
           mask = newmask; 
        else
           break;
        end
    end

    g = rgb2gray(image);

    count_pixels = 0;
    count_intensities = 0;
    sumX = 0; sumY = 0;
    x1=0; y1=0;
    for i=1:size(mask,1)
        for j=1:size(mask,2)
            if (mask(i,j)==1)
               x1 = x1 + j;
               y1 = y1 + i;
               sumX = sumX + j*double(g(i,j));
               sumY = sumY + i*double(g(i,j));
               count_pixels = count_pixels +1;
               count_intensities = count_intensities+double(g(i,j));
            end
        end
    end
    if count_intensities == 0
        obj.centroid = round([x1,y1]/(count_pixels));
    else
        obj.centroid = round([sumX,sumY]/(count_intensities));
    end
    
    cent = obj.centroid;

%     cent = double([colVal,rowVal]);
%     if size(cent,1) ~= 1
%         cent = cent(round(end/2),:);
%     end

end