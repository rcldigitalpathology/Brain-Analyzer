% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Trains a neural network classifier on our labelled set (in data/)
% returns the unthresholded classification decisions on a validation set
% (and the validation set labels) for further analysis.

% Architecture of network based on digit classification example in matlab
% docs.

function [decisions,result_labels] = nn_train(path)

    run init.m

    TRAINING_TESTING_SPLIT = 0.7;

    %find data folder
    out_path = path;

    %set categories
    categories = {'falsePositives', 'truePositives'};
    imds = imageDatastore(fullfile(out_path, categories), 'LabelSource', 'foldernames');
    imds.ReadFcn = @(filename)readAndPreprocessImage(filename);

    %split into equal pieces
    tbl = countEachLabel(imds);
    minSetCount = min(tbl{:,2}); % determine the smallest amount of images in a category
    imds = splitEachLabel(imds, minSetCount, 'randomize');

    % display count
    countEachLabel(imds)

    % Find the first instance of an image for each category
    falsePositives = find(imds.Labels == 'falsePositives', 1);
    truePositives = find(imds.Labels == 'truePositives', 1);

    decisions = [];
    result_labels = [];
    average = zeros(2,2);
    iterations = 3;
    for k=1:iterations
        [trainingSet, testSet] = splitEachLabel(imds, TRAINING_TESTING_SPLIT, 'randomize');

        %load cnn

        layers = [
            imageInputLayer([30 30 3])

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
%             'ValidationData',testSet,...
%             'ValidationFrequency',5,...
        options = trainingOptions('sgdm',...
            'MaxEpochs',12, ... 
            'ValidationData',testSet,...
            'ValidationFrequency',5,...
            'InitialLearnRate',0.0001);

        classifier = trainNetwork(trainingSet,layers,options);

        Yprob = predict(classifier, testSet);
        decisions = [decisions Yprob(:,1)];
        result_labels = [result_labels testSet.Labels];
        Yclass = Yprob(:,1) > 0.5;
        for i=1:length(Yclass)
            if Yclass(i) == 1
                predictedLabels(i) = "falsePositives";
            elseif Yclass(i) ==0
                predictedLabels(i) = "truePositives";
            end
        end

        [confMat,order] = confusionmat(testSet.Labels, categorical(predictedLabels));
        confMat = bsxfun(@rdivide,confMat,sum(confMat,2));

        average = average+confMat/iterations;
        fprintf('done iteration %d of %d\n',k,iterations);

    end
    average
end

function Iout = readAndPreprocessImage(filename)

    I = imread(filename);

    % Some images may be grayscale. Replicate the image 3 times to
    % create an RGB image.
    if ismatrix(I)
        I = cat(3,I,I,I);
    end
    Iout = I;
end