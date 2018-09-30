% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% block_analysis - performs microglia analysis on a particular DPImage
% Return 0 for average_morphology if the analysis type is 1.

function [cell_count, average_morphology] = block_analysis( dpimage, analysis_type,cell_classifier,morph_classifier)

%   analysis_type = 0 cell count & cell morphology
%   analysis_type = 1 cell count only

    if(~exist('cell_classifier','var'))
        cell_classifier = [];
    end
    if(~exist('morph_classifier','var'))
        morph_classifier = [];
    end

    if (Tools.is_edge_image(dpimage))
        cell_count = -1;
        average_morphology = -1;
        return
    end
    
    cell_list = Segment.cell_segmentation(dpimage,cell_classifier,morph_classifier);
    cell_count = size(cell_list,2);
    
    if (analysis_type == 0)
        
        morphologies = zeros(cell_count,1);

        for i =1:cell_count
            morphologies(i) = cell_list{i}.morphology_class;
        end
        
        morphologies(morphologies==1) = 0;
        morphologies(morphologies==4) = 1;
        
        
        a = length(morphologies(morphologies~=-1));

        if cell_count ~= 0
            if a ~= 0
                average_morphology = mean(morphologies(morphologies~=-1)); %percentage ramified
            else
                average_morphology = -1;
            end
        else
            average_morphology = -1;
        end
        
    else
        average_morphology = -1;
    end
end

