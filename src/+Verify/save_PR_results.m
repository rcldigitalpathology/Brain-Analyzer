% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Calculates and saves precision recall curve of the automated algorithm by running
% evaluate_all with varying neural network decision thresholds

function [] = save_PR_results(set_type)

    [file,path] = uiputfile('+Verify/results/*.mat','Save a Precision-Recall analysis');

    X = linspace(0,1,20);
    precisions = [];
    recalls = [];
    for i = 1:length(X);
        thresh = X(i);
        Config.set_config('DEEP_FILTER_THRESHOLD',thresh);
        [GT,TP,FP,FN] = Verify.evaluate_all('union', 'algorithm', set_type);

        P = TP/(TP+FP);
        R = TP/(TP+FN);     

        if isnan(P)
            P = 1;
        end
        
        precisions = [precisions; P];
        recalls = [recalls; R];
        fprintf('Done %d of %d of save_PR_results',i,length(X));
    end
    save(strcat(path,file),'precisions','recalls');
end

