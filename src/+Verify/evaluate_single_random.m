% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Runs evaluate_image_performance with a random image

labeller_name = inputdlg('Enter the labeller name you want to compare against (eg. labeller1,labeller2,union,intersect)');
close all;
found_dpids = [];
files = dir('../data/v3/');
k= 1;
while k <= length(files)
    if endsWith(files(k).name,'.tif')
        filename = strip(files(k).name,'left','0');
        num = str2num(filename(1:end-4));
        found_dpids = [found_dpids num];
    end
    k = k + 1;
end

for i = 1:1 %can change to more if desired
    Verify.evaluate_image_performance(found_dpids(randi(length(found_dpids))),labeller_name{1},2);
end