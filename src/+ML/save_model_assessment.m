% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Compares all machine learning methods on one precision recall curve
% Prerequisites are to run: 
% ML.prepare_training.m and ML.feature_extraction.get_features_nn.m

save_name = '+ML/results/assess_models_intermediate_5.mat';

out_path = uigetdir('../data/','Choose output folder');

NMethods = 5;

TH = 0:0.05:1;
result = zeros(length(TH),2,NMethods);
    
[ld,ll] = ML.Models.Logistic.logistic_train(out_path);
fprintf('done Logistic');
[sd,sl] = ML.Models.SVM.svm_train(out_path);
fprintf('done SVM');
[rd,rl] = ML.Models.RF.rf_train(out_path);
fprintf('done RF');
[ad,al] = ML.Models.Adaboost.ada_train(out_path);
fprintf('doe ADA');
[nd,nl] = ML.Models.NN.nn_train(out_path);
fprintf('done neural network');

decisions = {ld,sd,rd,ad,nd};
labels = {ll,sl,rl,al,nl};

for b = 1:NMethods
    dec = decisions{b};
    lab = labels{b};

    for k = 1:length(TH)
        average = zeros(2,2);
        for j = 1:size(dec,2)
            Yclass = dec(:,j) > TH(k);
            clear predictedLabels;
            for i=1:length(Yclass)
                if Yclass(i) == 1
                    predictedLabels(i) = "falsePositives";
                elseif Yclass(i) ==0
                    predictedLabels(i) = "truePositives";
                end
            end
            confMat = confusionmat(lab(:,j), categorical(string(predictedLabels)));
            average = average + bsxfun(@rdivide,confMat,sum(confMat,2))/size(dec,2);
        end

        TP = average(2,2);
        FP = average(1,2);
        FN = average(2,1);

        precision = TP/(TP+FP);
        recall = TP/(TP+FN);

        if isnan(precision)
           precision = 1; 
        end

        result(k,1,b) = precision;
        result(k,2,b) = recall;
    end
    fprintf('done %d of %d\n',b,NMethods);
end

save(save_name,'result');