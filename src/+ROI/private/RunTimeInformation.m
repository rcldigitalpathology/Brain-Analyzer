% University of British Columbia, Vancouver, 2017
%   Dr. Guy Nir
%   Shahriar Noroozi Zadeh
%   Amir Refaee
%   Lap-Tak Chu

function [fpath, NumSVSslides, trainDirectory, testDirectory, Blk_X, Blk_Y, scl, NumTestSlides] ...
                = RunTimeInformation(trainDir, testDir, mode, Xsize, Ysize, scale)
% RunTimeInformation  Saves the Information to textfile.
%   Output:
%       fpath
%       NumSVSslides
%       trainDirectory
%       testDirectory
%       Blk_X
%       Blk_Y
%       scl
%       NumTestSlides
%
    global RESULTS_PATH
    if (mode == 'w')
        trainDirectory = trainDir;
        testDirectory  = testDir;
        Blk_X = Xsize;
        Blk_Y = Ysize;
        scl   = scale;
        
        %trainInfo = strsplit(trainDir,'/');
        %trainInfo = trainInfo{end-1};
        
        fpath = strcat(RESULTS_PATH,datestr(datetime('now'),'yyyymmdd-hhMM'));
        
        D = [dir([trainDirectory, '/*.svs']); dir([trainDirectory, '/*.tif']);];
        NumSVSslides = length(D(not([D.isdir])));
        if (NumSVSslides == 0)
            D = dir([trainDirectory, '/*.mat']);
            NumSVSslides = length(D(not([D.isdir])));
        end
        
        E = [dir([trainDirectory, '/*.svs']); dir([trainDirectory, '/*.tif']);];
        NumTestSlides = length(E(not([E.isdir])));
        if (NumTestSlides == 0)
            E = dir([testDirectory, '/*.mat']);
            NumTestSlides = length(E(not([E.isdir])));
        end

        fid = fopen('RunTimeInfo.txt', 'wt');
        fprintf(fid,'%s\n',trainDir);
        fprintf(fid,'%s\n',fpath);
        fprintf(fid,'%d\n',NumSVSslides);
        fprintf(fid,'%s\n',testDir);
        fprintf(fid,'%d\n',Xsize);
        fprintf(fid,'%d\n',Ysize);
        fprintf(fid,'%d\n',scale);
        fprintf(fid,'%d\n',NumTestSlides);
        fclose(fid);
        %mkdir(fpath);
        
    elseif (mode == 'r')
        fid = fopen('RunTimeInfo.txt', 'r');
        data = textscan(fid,'%s','delimiter','\n');
        trainDirectory = data{1}{1};
        fpath = data{1}{2};
        NumSVSslides = str2double(data{1}{3});
        testDirectory = data{1}{4};
        Blk_X = str2double(data{1}{5});
        Blk_Y = str2double(data{1}{6});
        scl   = str2double(data{1}{7});
        NumTestSlides = str2double(data{1}{8});
        fclose(fid);
    end
end