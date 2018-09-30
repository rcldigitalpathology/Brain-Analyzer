% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% A more specific binary search algorithm that deals with the pixelList
% coordinate list format that is outputted by MATLAB's bwconncomp.

function [bool] = pixel_list_binary_search( pList, p )
    
    a = Tools.binary_search(pList(:,1),p(1));
    
    if ( a == -1)
        bool = 0;
        return;
    end
    
    b = a;
    while (b~=1 && pList(b-1,1) == p(1))
        b = b-1;
    end
    
    c = a;
    while (c~=size(pList,1) && pList(c+1,1) == p(1))
        c=c+1;
    end    
    
    d = Tools.binary_search(pList(b:c,2),p(2));
    
    if (d==-1)
        bool=0;
        return;
    end
    
    bool = 1;
end

