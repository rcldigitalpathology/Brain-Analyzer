% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Evaluates one dataset against another in images from the class specified in set_type

% label_set: the ground truth set (labeller1/labeller2/union/intersect)
% prediction_set: set compared against ground truth (almost always 'algorithm')

% set_type: the data being compared (train,test,validate). 
    %train - the training data that the CNN trained on
    %validate - the training data that the CNN DIDNT train on.
    %test - the testing set
    
% verbose: (OPTIONAL), 0 if you want to suppress output, 1 otherwise

%Typical use: evaluate_all('union', 'algorithm' ,'validate')

function [GT,TP,FP,FN] = evaluate_all(label_set, prediction_set,set_type,verbose)

    if ~exist('verbose','var')
        verbose = 1;
    end   
    if ~exist('set_type','var')
        set_type = 'validate';
    end   
    if ~exist('label_set','var')
        label_set = 'intersect';
    end   
    if ~exist('prediction_set','var')
        prediction_set = 'algorithm';
    end   
    
    training_dpids = [];
    load('+ML/classifiers/deep_learning_model_v4.mat');
    
    training_set_dpids = find_dpids('train_v3');
    testing_set_dpids = find_dpids('test_v3');
    
    %%%
    %GET LABEL DATA
    %%%%
    switch label_set
        case 'labeller1'
            load('+Annotation_cell/cell_detection_analysis_utility/labelling/annotation_data_labeller1.mat');
        case 'labeller2'
            load('+Annotation_cell/cell_detection_analysis_utility/labelling/annotation_data_labeller2.mat');
        case 'intersect'
            load('+Annotation_cell/cell_detection_analysis_utility/labelling/annotation_data_intersect.mat');
        case 'union'
            load('+Annotation_cell/cell_detection_analysis_utility/labelling/annotation_data_union.mat');
        case 'algorithm'
            %only training folder
            dpids = training_set_dpids;
            
            if strcmp(set_type,'validate')
                dpids = setdiff(dpids,training_dpids);
            elseif strcmp(set_type,'train')
                dpids = intersect(dpids,training_dpids);
            elseif strcmp(set_type,'test')
                dpids = testing_set_dpids;
            else
                error('invalid evaluation set');
            end
                        
            %remove bad images
            dpids = remove_edge_images(dpids);
            
            data = get_extraction_data(dpids);
        otherwise
            error('invalid parameter');
    end
    label_dpids = dpids;
    label_data = data;
    
    %%%
    %GET PREDICTION DATA
    %%%
    switch prediction_set
        case 'labeller1'
            load('+Annotation_cell/cell_detection_analysis_utility/labelling/annotation_data_labeller1.mat');
        case 'labeller2'
            load('+Annotation_cell/cell_detection_analysis_utility/labelling/annotation_data_labeller2.mat');
        case 'intersect'
            load('+Annotation_cell/cell_detection_analysis_utility/labelling/annotation_data_intersect.mat');
        case 'union'
            load('+Annotation_cell/cell_detection_analysis_utility/labelling/annotation_data_union.mat');
        case 'algorithm'
            %only training folder
            dpids = training_set_dpids;
            
            if strcmp(set_type,'validate')
                dpids = setdiff(dpids,training_dpids);
            elseif strcmp(set_type,'train')
                dpids = intersect(dpids,training_dpids);                
            elseif strcmp(set_type,'test')
                dpids = testing_set_dpids;
            else
                error('invalid evaluation set');
            end
            
            %remove bad images
            dpids = remove_edge_images(dpids);
            
            data = get_extraction_data(dpids);
        otherwise
            error('invalid parameter');
    end
    prediction_dpids = dpids;
    prediction_data = data;
    
    %discard testing set
    
    %now make sure we are only working on the validation set
 
    if strcmp(set_type,'validate')
        %take entire training set
        label_dpids = intersect(label_dpids,training_set_dpids);
        prediction_dpids = intersect(prediction_dpids,training_set_dpids);
        
        %take validation part of training set
        label_dpids = setdiff(label_dpids,training_dpids);    
        prediction_dpids = setdiff(prediction_dpids,training_dpids);
    elseif strcmp(set_type,'train')
        %take entire training set
        label_dpids = intersect(label_dpids,training_set_dpids);
        prediction_dpids = intersect(prediction_dpids,training_set_dpids);
        
        %take training part of training set
        label_dpids = intersect(label_dpids,training_dpids);    
        prediction_dpids = intersect(prediction_dpids,training_dpids); 
    elseif strcmp(set_type,'test')
        
        %get entire testing set
        label_dpids = intersect(label_dpids,testing_set_dpids);
        prediction_dpids = intersect(prediction_dpids,testing_set_dpids);
    else
        error('BAD');
    end
    
    %get only data contained in dpids
    if ~isempty(label_data)
        label_data = label_data(ismember(label_data(:,1),label_dpids),:);
    end
    if ~isempty(prediction_data)
        prediction_data = prediction_data(ismember(prediction_data(:,1),prediction_dpids),:);
    end
    %only take the common dpids between them;
    common_dpids = intersect(label_dpids,prediction_dpids);
    if ~isempty(label_data)
        label_data = label_data(ismember(label_data(:,1),common_dpids),:);
    end
    if ~isempty(prediction_data)
        prediction_data = prediction_data(ismember(prediction_data(:,1),common_dpids),:);
    end
    
    
    [GT,TP,FP,FN] = Verify.compare_data(common_dpids,label_data,prediction_data);
    
    if (verbose)
        fprintf('on %d images\n',length(common_dpids));
        fprintf('GT TP FP FN (%d,%d,%d,%d)\n',GT,TP,FP,FN);
        fprintf('Precision: %f, Recall: %f',TP/(TP+FP),TP/(TP+FN));        
    end

end
