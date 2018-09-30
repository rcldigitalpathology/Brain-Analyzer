% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% The cost function the gradient descent optimizes

function [cost,parameter_labels,TP,FP,FN] = cost(P,label_set, prediction_set,set_type)

    parameter_labels = {"LOWER_SIZE_BOUND","MUMFORD_SHAH_LAMBDA"};
    
    Config.set_config('USE_DEEP_FILTER',0);

    Config.set_config('LOWER_SIZE_BOUND',P(1));
    Config.set_config('MUMFORD_SHAH_LAMBDA',P(2));
    
    FALSE_NEGATIVE_BIAS=8;

    [GT,TP,FP,FN] = Verify.evaluate_all(label_set, prediction_set,set_type,0);
    cost = FP + FALSE_NEGATIVE_BIAS*FN;
end

