% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Discards images on the brain boundary that have abnormalities

function [filtered_dpids] = remove_edge_images(dpids)
    filtered_dpids = [];
    for i=1:size(dpids,1)
        dpid = dpids(i);
        if Tools.is_edge_image(DPImage(dpid))
            continue;
        end
        filtered_dpids = [filtered_dpids; dpid]; 
    end
end

