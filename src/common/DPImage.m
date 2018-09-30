% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% A representation of an entire analyzed image and its properties


classdef DPImage
    % Digital Pathology Image (DPImage)
    %   A representation of an image relevant to this project that 
    %   also contains relevant metadata
    
    properties
        image = 0 %raw image data (3D array)
        flipped = 0; %boolean representing whether image is flipped or not
        
        %file metadata
        filename
        filepath
        id %unique identifier in our image naming system
        
        %average intensity
        avInt = 0;
        
        %soma
        preThresh = 0; %after smoothing and before binarizing
        rawThresh;
        somaMask; %binarized version of image
        
        %slide metadata TODO - not implemented anywhere yet.
        mag %image magnification (multiplication factor)
        stain
        time
        age
        date        
        elapsedTime %elapsed time since injury (hours)
        impactEnergy %injury impact energy (J)
    end
    
    methods
        function obj = DPImage(id)
            
            if(strcmp(id,'notAFile'))
                return;
            end
            
            obj.id = id;
            if ismember(id,Tools.find_dpids('train_v3'))
                filename = strcat('../data/train_v3/',num2str(id),'.tif');
            elseif ismember(id,Tools.find_dpids('test_v3'))
                filename = strcat('../data/test_v3/',num2str(id),'.tif');
                fprintf('WARNING: PULLING FROM TEST SET\n');
            else
                error('cant find image anywhere');
            end
            
            imPath = filename;     

            obj.filename = filename;
            obj.filepath = filename;
            obj.image = imread(filename);
            obj.image = obj.image(:,:,1:3);

            if (size(obj.image,2) > size(obj.image,1))
               obj.image = permute(obj.image, [2 1 3]);
            end

            obj.filename = filename;
            obj.filepath = filename;
            obj.image = imread(filename);
            obj.image = obj.image(:,:,1:3);

            blue = obj.image(:,:,3);
            obj.avInt = mean(blue(:));

            if (size(obj.image,2) > size(obj.image,1))
               obj.image = permute(obj.image, [2 1 3]);
            end
        end
    end
    
end

