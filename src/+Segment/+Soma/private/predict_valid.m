% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi
% 
% A function that classifies the cell based on the passed in model
%

function [ good, best ] = predict_valid(classifier, cell)   

    if isempty(classifier)
        error('USE_DEEP_FILTER is TRUE, but no classifier was found');
        good = 1;
        return;
    end

    I = cell.cnnBox;
    score = predict(classifier, I);
    Yclass = score(:,1) > Config.get_config('DEEP_FILTER_THRESHOLD');
    for i=1:length(Yclass)
        if Yclass(i) == 1
            good = 0;
            best = 0;
        elseif Yclass(i) ==0
            good = 1;
            best = 0;
            if score(:,1) < Config.get_config('STRICT_CELL_CONDITION')
                best = 1;
            end
        end
    end
end

