% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Detects if this is an edge image (on the edge of a brain slide)

function [isEdge] = is_edge_image(dpimage)
    isEdge = 0;
    im = rgb2gray(dpimage.image);
    whites = im>230;
    if sum(whites(:)) > 10000
        isEdge = 1;
    end
end