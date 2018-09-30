% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% batch_pathology_analysis - a batch processing script to perform analysis on multiple
%   brain slides

function [] = batch_pathology_analysis( analysis_type )

    filePath = uigetdir('','Choose the folder containing the images to be analyzed.');
    
    imageList = dir(strcat(filePath,'/*.tif'));
    
    outPath = uigetdir('','Choose the folder to output the results.');
    
    for i=1:size(imageList,1)
        [pathstr,name,ext] = fileparts(imageList(i).name);
        saveDir = strcat(outPath,'/','analysis_',name);
        Pipeline.pathology_analysis(analysis_type, strcat(imageList(i).folder,'/',imageList(i).name), saveDir);
    end
end

