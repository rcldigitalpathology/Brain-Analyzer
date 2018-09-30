% University of British Columbia, Vancouver, 2018
%   Alex Kyriazis

% Samples a group of white matter patches and puts them into train and test folders

%PLEASE TAKE CARE IN SETTING THE NEXT 2 PARAMETERS

SAMPLE_SIZE = 10; %samples PER brain slide
SPLIT = 3; %X, where 1/X becomes the test set and (X-1)/X becomes the training set. This should a divisible factor of the number of white matter patches are sampled

filePath = uigetdir('','Choose the folder');

mkdir(filePath,'train');
mkdir(filePath,'test');

imageList = dir(strcat(filePath,'/*.tif'));

for j=1:size(imageList,1)

    [pathstr,name,ext] = fileparts(strcat(strcat(filePath,'/',imageList(j).name)));
    num = str2double(name);
    full_path = strcat(pathstr,'/',name,ext);

    X = (mod(floor((num-1)/SAMPLE_SIZE),3) == 2);
    if X
        destination = 'test';
    else
        destination = 'train';
    end
    copyfile(full_path,strcat(filePath,'/',destination,'/',name,ext));
end