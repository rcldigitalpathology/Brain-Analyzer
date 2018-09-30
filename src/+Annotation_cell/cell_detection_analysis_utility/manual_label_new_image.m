% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Opens a user interface that allows one to manually select microglia on
% DPImages so that they can be used for training data for CNNs or other
% classification frameworks

%This file in particular selects a new image that hasn't already been
%analyzed in the set specified by the .mat file where the training data is
%being saved to

data=[];
dpids=[];
if (~exist('labelling/annotation_data.mat'))
	save('labelling/annotation_data.mat','data','dpids');      
end

load('labelling/annotation_data.mat');

if (isempty(dpids))
    used = [];
else
    used = unique(dpids(:));
end

PATH = ['images'];
files = dir(PATH);
inds = [];
n    = 0;
k    = 1;
while n < 2 && k <= length(files)
    if any(strcmp(files(k).name, {'.', '..'}))
        inds(end + 1) = k;
        n = n + 1;
    end
    k = k + 1;
end
files(inds) = [];
if (size(files) == size(used))
    h = msgbox('All images have been analyzed!','Good News!');
    warning('Be sure to rename labelling/annotation_data.mat to labelling/annotation_data_[YOUR NAME].mat');
    return
end

num = files(randi(length(files))).name(1:end-4);
while (ismember(str2num(num),used))
    num = files(randi(length(files))).name(1:end-4);
end

im = imread([PATH '/' num '.tif']);

helper(im,str2num(num));
