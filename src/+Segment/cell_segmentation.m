% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Main entry point into the cell segmentation process. The result of this
% is a setting of the internal properties of dpimage to reflect the new
% information gathered about the cells.

% The critical parameters that must be modified are the calls to 
% Segment.Soma.extract_soma() below

function [ cell_list ] = cell_segmentation( dpimage, cell_classifier, morph_classifier)

%   Handles cell segmentation; soma segmentation followed by processes
%   segmentation of the cells

    if(~exist('cell_classifier','var'))
        cell_classifier = [];
    end
    if(~exist('morph_classifier','var'))
        morph_classifier = [];
    end

    cell_list={};
    % Soma Segmentation
    [positive_detections,dp] = Segment.Soma.extract_soma(dpimage,cell_classifier);
    
    for i=1:size(positive_detections,2)
        cell = positive_detections{i};
        if cell.isFalsePositive == 0
            cell_list{end+1} = cell;
        end
    end
    length = size(cell_list,2);
    
    % Process Segmentation
    for k=1:length
        
        
        cell_properties = Morph.get_cell_data(cell_list{k}.subImage,cell_list{k}.rCentroid);
        
        [~,p] = predict( morph_classifier, cell_properties);
        Yprob = -p(1);

        if (Yprob > Config.get_config('MORPH_DECISION_THRESHOLD'))
            morphology_class = 4; %most ramified
        else
            morphology_class = 1; %most amboeboid
        end
        
        if (~cell_list{k}.isBestCell)
            morphology_class = -1; 
        end
        
        cell_list{k}.morphology_class = morphology_class;
    end
end



