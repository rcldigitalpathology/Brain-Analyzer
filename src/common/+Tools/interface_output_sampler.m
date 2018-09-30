% University of British Columbia, Vancouver, 2018
%   Alex Kyriazis

% Takes a folder of interface outputs and produces a collection 
% of SAMPLE_SIZE WM patches from each.

SAMPLE_SIZE = 10;
OUTPUT_NAME = 'output';
INFO_NAME = 'info';

filePath = uigetdir('','Choose the Interface Output');

if exist(strcat(filePath,'/',OUTPUT_NAME),'dir')
    rmdir(strcat(filePath,'/',OUTPUT_NAME),'s');
end
if exist(strcat(filePath,'/',INFO_NAME,'.txt'),'file')
    delete(strcat(filePath,'/',INFO_NAME,'.txt'))
end
slideList = dir(filePath);

ids_to_remove = [];
for i=1:size(slideList,1)
    if startsWith(slideList(i).name,'.')
        ids_to_remove = [ids_to_remove i];
    end
end
slideList(ids_to_remove) = [];

mkdir(filePath,OUTPUT_NAME);

fileID = fopen(strcat(filePath,'/',INFO_NAME,'.txt'),'w');

id = 1;
set_count = 0;
sampled = [];
for i=1:size(slideList,1)
    
    imageList = dir(strcat(slideList(i).folder,'/',slideList(i).name,'/BlockImg','/*.tif'));
    DPslide = load(strcat(slideList(i).folder,'/',slideList(i).name,'/DP_Slide.mat'));
    DPslide = DPslide.DPslide;
    
    while(set_count < SAMPLE_SIZE)
        
        j = randi(size(imageList,1),1); %random number
        [pathstr,name,ext] = fileparts(strcat(strcat(slideList(i).folder,'/',slideList(i).name,'/BlockImg/'),imageList(j).name));
        num = str2double(name);
        full_path = strcat(pathstr,'/',name,ext);
        
        image = imread(full_path);
               
        flag1 = ~any(ismember(sampled,num)); % if there is no duplicate
        flag2 = DPslide([DPslide.Id] == num).Label == 1; %if it is indeed white matter
        flag3 = ~is_edge_image(image);  %if it's not an edge image
           
        if (flag1 && flag2 && flag3)
            sampled = [sampled; num]; 
            copyfile(full_path,strcat(filePath,'/',OUTPUT_NAME,'/',num2str(id),'.tif'));
            fprintf(fileID,'======= %d-%d\n',num,id);
            set_count = set_count+1;
            id = id+1;
        else
            continue;
        end
    end
    fprintf(fileID,'%s --> %d-%d\n',slideList(i).name,id-SAMPLE_SIZE,id-1);
    set_count = 0;
    sampled = [];
end
fclose(fileID);

function [isEdge] = is_edge_image(image)
    isEdge = 0;
    im = rgb2gray(image);
    whites = im>220;
    if sum(whites(:)) > 2000
        isEdge = 1;
    end
end