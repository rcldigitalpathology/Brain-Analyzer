% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Gets particular config value, specified by the value's key
% This file also holds the default values that are loaded in upon running
% init.m

function [value] = get_config(param)
    global global_config;

    if isempty(global_config)
        
        %make sure to run init.m to reset the changes
        
        %basic parameters
        global_config = [];
        global_config.LOWER_SIZE_BOUND = 12; %smallest cells (in pixel area) that will be permitted
        global_config.MUMFORD_SHAH_LAMBDA = 0.0727; %smoothing factor
        global_config.WHITE_DISCARD_THRESHOLD = 0.9; %image normalization parameter
        
        %clump resolution
        global_config.MIN_CLUMP_AREA = 500; %minimum threshold size a cell needs to be to undergo clump resolution
        global_config.MAX_CLUMP_AREA = 10000; %maximum size an object can be before discarding immediately
        global_config.CLUMP_ADJUST_THRESHOLD = 0.5; %image normalization parameter for clump resolution
        global_config.CLUMP_MUMFORD_SHAH_LAMBDA = 0.05; %image normalization parameter for clump resolution
        global_config.CLUMP_THRESHOLD = 0.9; %clump resolution binarizing threshold
        global_config.CLUMP_THRESHOLD_MIN_SIZE = 60; %minimum acceptable size for clump constitutents

        %morphology analysis
        global_config.MORPHOLOGY_ANALYSIS_BOX_SIZE = 40;
        global_config.MORPH_DECISION_THRESHOLD = 0.6; %decision threshold for morphology detection.
        global_config.STRICT_CELL_CONDITION = 0.9; %the quality threshold of a cell to determine appropriatness for morphology classification

        %Deep cell filtering
        global_config.USE_DEEP_FILTER = 1; %should use deep cell filter?
        global_config.DEEP_FILTER_THRESHOLD = 0.7; %decision threshold for deep filter
        
        %classifier paths
        global_config.CELL_CLASSIFIER_PATH = '+ML/classifiers/deep_learning_model_v4.mat';  %cell classifier
        global_config.MORPHOLOGY_CLASSIFIER_PATH = '+Morph/classifiers/morph_classifier_v1.mat';  %morphology classifier.
 
    end
    if exist('param','var')
        value = global_config.(param);
    else
        value = [];
    end
end

