% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Performs a binary search on an array

function [ind] = binary_search(arr,val)

    dim = find(size(arr)==max(size(arr)));
    dim = dim(1);

    ind = recurse(arr,val);
    
    function [pos] = recurse(arr,val)
        if (isempty(arr) == 1)
            pos = -1;
            return; 
        end

        medianInd = ceil(size(arr,dim)/2);
        median = arr(medianInd);

        if (val == median)
            pos = medianInd;
            return;
        end

        if (val > median)
            rec = recurse(arr((medianInd+1):end),val);
            if (rec == -1)
                pos = -1;
                return;
            end
            pos =  rec + medianInd;
        else
            rec = recurse(arr(1:medianInd-1),val);
            if (rec == -1)
                pos = -1;
                return;
            end           
            pos = rec;
        end
    end
end