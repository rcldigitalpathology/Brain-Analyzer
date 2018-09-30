% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi
% 
% Performs Mumford Shah smoothing
%

function [ out ] = smooth_ms( in, l, a, e)
    if nargin == 4       
        out = fastms(in, 'lambda', l, 'alpha', a, 'edge', e,'verbose',0);
    elseif nargin == 3
        out = fastms(in, 'lambda', l, 'alpha', a,'verbose',0);        
    end
end

