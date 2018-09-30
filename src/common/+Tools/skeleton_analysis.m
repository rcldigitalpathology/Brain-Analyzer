% University of British Columbia, Vancouver, 2017
%   William Choi
%   Alex Kyriazis
% 
% Performs a skeleton analysis to obtain some useful morphology features

function [ numEndpoint, numJunc, skelIm ] = skeleton_analysis( bwIm )
%
% Skeleton Analysis
% 

    skelIm = Skeleton3D(imcomplement(bwIm));

    E = bwmorph(skelIm, 'endpoints');
    numEndpoint = sum(sum(E));
    
    B = bwmorph(skelIm, 'branchpoints');
    numJunc = sum(sum(B));
    
    % TODO: branch length; the average length? total length? longest
    % branch?

end

