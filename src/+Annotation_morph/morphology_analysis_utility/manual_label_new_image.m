% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Opens a user interface that allows one to manually select microglia on
% DPImages so that they can be used for training data for CNNs or other
% classification frameworks

%This file in particular selects a new image that hasn't already been
%analyzed in the set specified by the .mat file where the training data is
%being saved to

%NOTE: the file that you are loading here should be the same file you are
%saving to in Verify.CreateData.manual_label(im)
clear;

global PATH;
PATH = ['images']; %CHANGE THIS

data=[];
if (~exist('labelling/annotation_morph_data.mat'))
	save('labelling/annotation_morph_data.mat','data');      
end
load('labelling/annotation_morph_data.mat','data');

if isempty(data)
    used = [];
else
    used = data(:,1);
end

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

global unused;
unused = [];
for i=1:length(files)
    file = files(i).name(1:end-4);
    if ~ismember(str2num(file),used)
        unused = [unused; files(i)];
    end
end

randind = randperm(length(unused));
unused = unused(randind);

getNewImage();

function clickKey (objectHandle , eventData )

    new_dpid = objectHandle.UserData;
    switch eventData.Key
        case '0'
            choice = 0;
        case '1'
            choice = 1;
        case '2'
            choice = 2;
        case '3'
            choice = 3;
        case '4'
            choice = 4;
        otherwise
            return
    end
    
    fprintf('Image id %d: %d\n',new_dpid,choice);
    
    data=[];
    load('labelling/annotation_morph_data.mat');
    data = [data; new_dpid, choice];
    save('labelling/annotation_morph_data.mat','data');
   
    close all;
    getNewImage();
end

function getNewImage()
    global unused;
    global PATH;
    
    if isempty(unused)
        msgbox('All images have been analyzed!','Good News!');
        return
    end
    
    id = unused(end).name(1:end-4);
    unused = unused(1:end-1);
    
    im_data = imread([PATH '/' id '.tif']);
    
    figure;
    subplot(2,1,1);
    b = imshow(im_data,'InitialMagnification',400);
    title(['Image id: ',id,' - ', num2str(length(unused)+1),' remaining']);

    subplot(2,1,2);
    imshow(imread('instructions.png'));
    
    

    hold on;    
    
    set (gcf, 'KeyPressFcn', @clickKey);
    set (gcf, 'UserData', str2num(id));

end

