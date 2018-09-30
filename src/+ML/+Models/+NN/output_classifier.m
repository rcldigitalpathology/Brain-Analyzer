% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Very similar to nn_train.m except that it doesn't compare against a
% validation set and it outputs the classifier at the end for use in the
% end-to-end process.

%CHANGE THE 

function [] = output_classifier()

    run init.m

    %find data folder
    out_path = strcat(uigetdir('../data/','Choose output folder'),'/');

    [file,path] = uiputfile('+ML/classifiers/*.mat','Save classifier as');

    load(strcat(out_path,'meta.mat'));
    
    %set categories
    categories = {'falsePositives', 'truePositives'};
    imds = imageDatastore(fullfile(out_path, categories), 'LabelSource', 'foldernames');

    %split into equal pieces
    tbl = countEachLabel(imds);
    minSetCount = min(tbl{:,2}); % determine the smallest amount of images in a category
    imds = splitEachLabel(imds, minSetCount, 'randomize');

    % display count
    countEachLabel(imds)

    layers = [
        imageInputLayer([30 30 1])

        convolution2dLayer(3,16,'Padding',1)
        batchNormalizationLayer
        reluLayer  

        maxPooling2dLayer(2,'Stride',2) 
        convolution2dLayer(3,16,'Padding',1)
        batchNormalizationLayer
        reluLayer

        maxPooling2dLayer(2,'Stride',2) 
        convolution2dLayer(3,16,'Padding',1)
        batchNormalizationLayer
        reluLayer

        fullyConnectedLayer(2)
        softmaxLayer
        classificationLayer];

    options = trainingOptions('sgdm',...
        'MaxEpochs',9, ... 
        'InitialLearnRate',0.0001);

    classifier = trainNetwork(imds,layers,options);
    decision_threshold = 0.5;
    save(strcat(path,file),'classifier','decision_threshold','training_dpids');
end