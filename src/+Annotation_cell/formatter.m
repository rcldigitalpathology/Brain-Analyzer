% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Simple script to strip off leading zeros in filenames

files = dir
k= 1;
while k <= length(files)
    if endsWith(files(k).name,'.tif')
        movefile(files(k).name,strip(files(k).name,'left','0'));        
    end
    k = k + 1;
end