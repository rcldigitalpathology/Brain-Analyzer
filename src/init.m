% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Initalizes program. This should be called before running any files.


%get to directory
path = mfilename('fullpath');
path = path(1:end-5);
cd(path);

%clear variable space
clear;

%set global config
global global_config;
global_config = [];

%set random seed
RANDOM_SEED = 23;
rng(RANDOM_SEED);

%add paths
addpath(genpath('library'));
addpath common;
addpath ../src;

%suppress warnings
warning('off','images:initSize:adjustingMag')

