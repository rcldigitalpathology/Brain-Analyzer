% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Trains an SVM classifier on our labelled set (in data/formatted)
% returns the unthresholded classification decisions on a validation set
% (and the validation set labels) for further analysis.

function [decisions,result_labels] = svm_train(path)

    load(strcat(path,'/meta.mat')); % to get training_dpids
    load(strcat(path,'/features_alexnet.mat')); %to get feature_layer
    
    X = (features-mean(features))./std(features);
    Y = labels;
    
    %format X
    TRAINING_TESTING_SPLIT = 0.9;
    
    n = size(X,1);
    d = size(X,2);
    
    decisions = [];
    result_labels = [];
    average = zeros(2,2);
    iterations = 3;
    for k=1:iterations
        random_indeces = randperm(n);
        train_indeces = random_indeces(1:(floor(n*TRAINING_TESTING_SPLIT)));
        test_indeces = random_indeces((floor(n*TRAINING_TESTING_SPLIT)+1):end);

        Xtrain = X(train_indeces,:);
        Ytrain = Y(train_indeces,:);

        Xtest = X(test_indeces,:);
        Ytest = Y(test_indeces,:);

        classifier = fitcsvm(Xtrain,Ytrain,'KernelFunction','linear');

        [~,Yprob] = predict(classifier, Xtest);
        Yprob = (Yprob(:,1)/(2*max(max(Yprob(:,1)),min(-Yprob(:,1)))))+0.5;
        decisions = [decisions Yprob];
        result_labels = [result_labels Ytest];
        Yclass = Yprob > 0.5;
        for i=1:length(Yclass)
            if Yclass(i) == 1
                predictedLabels(i) = "falsePositives";
            elseif Yclass(i) ==0
                predictedLabels(i) = "truePositives";
            end
        end

        confMat = confusionmat(Ytest, categorical(string(predictedLabels)));
        average = average + bsxfun(@rdivide,confMat,sum(confMat,2))/iterations;
        fprintf('done iteration %d of %d\n',k,iterations);    
    end
    %save('+ML/deep_learning_model.mat','classifier','FEATURE_LAYER','training_dpids');
end