% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Sets particular config value, specified by the value's key and the new
% value

function [] = set_config(param,value)
    global global_config;    
    Config.get_config(); %make sure global config exists
    global_config.(param) = value;
end

