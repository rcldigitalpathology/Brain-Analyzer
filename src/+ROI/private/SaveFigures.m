% University of British Columbia, Vancouver, 2017
%   Dr. Guy Nir
%   Shahriar Noroozi Zadeh
%   Amir Refaee
%   Lap-Tak Chu
function SaveFigures(figureFolder)
    [fpath, ~, ~,~,~,~,~] = RunTimeInformation([],[],'r',0,0,0);
    
    fpath = strcat(fpath,figureFolder);
    if ~exist(fpath, 'dir')
        mkdir(fpath);
    end
    
    % Plots and Figures Saving
    disp('Saving Figures ...');
    h = get(0,'children');
    for i=1:length(h)
        saveas(h(i), fullfile(fpath,['figure' num2str(length(h)+1-i)]), 'jpg');
    end
    disp('Figures Saved!');
end