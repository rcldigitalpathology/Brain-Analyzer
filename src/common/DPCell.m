% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% A representation of a cell and all its properties


classdef DPCell
    % Digital Pathology Cell (DPImage)
    %   A Cell Representation
    
    properties
        pixelList %list of pixels that belong to this cell (dpimage referenced)

        referenceDPImage %the DP image this belongs to

        TL %top left coordinate of subImage box wrt dpimage. In (x,y)
        subImage %a smaller cropping of the cell out of the DPImage
        oImage %image after a step of smoothing
        rCentroid %relative centroid of the subImage in the DPImage
        
        cnnBox %box around cell created for CNN

        area %area of cell

        isClump = 0;  % true if the component contains multiple cells

        isFalsePositive = 0; %classifier flag
        isBestCell = 0; % TODO descript
        
        %file metadata
        centroid %centroid of pixels
        maxRadius %largest containing radius

        isCorrect = -1; %whether it matches test data or not

        % Following Processes Segmentation
        
        binaryIm     % binary image of the cell
        skelIm     % skeletonized image of the cell

        % Skeleton Analysis
        numJunctions   % number of junctions in a skeletonized image
        numEndpoints    % number of endpoints in a skeletonized image

        % Fractal Analysis
        fractalDim
        
        %morphology
        morphology_class
        
    end
    
    methods
        function obj = DPCell(L,RDPI)
            
            
            obj.pixelList = L; %[col, row]
            obj.referenceDPImage = RDPI;
            obj.area = size(obj.pixelList,1);
    
            dim = size(RDPI.image);
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
            
            g = rgb2gray(RDPI.image);

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
                        
            obj.maxRadius = 0;
            for j=1:size(obj.pixelList,1)
                p = obj.pixelList(j,:);
                r = Tools.calc_distance(obj.centroid,p);
                if (r > obj.maxRadius)
                    obj.maxRadius = r;
                end
            end
            obj.maxRadius = round(obj.maxRadius);
        end        
    end
end

