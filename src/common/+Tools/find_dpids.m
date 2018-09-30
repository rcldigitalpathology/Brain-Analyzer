% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Finds all the data images in a particular subset

function [found_dpids] = find_dpids(type)
    found_dpids = [];
    files = dir(['../data/',type,'/']);
    k= 1;
    while k <= length(files)
        if endsWith(files(k).name,'.tif')
            filename = strip(files(k).name,'left','0');
            num = str2num(filename(1:end-4));
            found_dpids = [found_dpids; num];
        end
        k = k + 1;
    end       
end

