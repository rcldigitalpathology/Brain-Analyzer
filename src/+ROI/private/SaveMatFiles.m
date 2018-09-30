% University of British Columbia, Vancouver, 2017
%   Dr. Guy Nir
%   Shahriar Noroozi Zadeh
%   Amir Refaee
%   Lap-Tak Chu
function SaveMatFiles(t)
    [fpath, ~, trainDirectory,testDirectory,~,~,~] = ...
                                       RunTimeInformation([],[],'r',0,0,0);
    switch t
        case 'train'
            slideDirectory = trainDirectory;
        case 'test'
            slideDirectory = testDirectory;
    end
    
    if ~exist(fpath, 'dir')
        mkdir(fpath);
    end

    % Mat Files Generated Being Saved
    disp('Saving *.mat Files ...');
    matPath = strcat(fpath,'/Mat files');
    
    if ~exist(matPath, 'dir')
        mkdir(matPath);
    end
    
    files = dir(strcat(slideDirectory,'*.mat'));
    for i = 1:length(files)
        copyfile([slideDirectory, files(i).name],matPath);
    end
    disp('*.mat Files Saved!');
end