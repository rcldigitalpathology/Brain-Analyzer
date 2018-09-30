% University of British Columbia, Vancouver, 2017
%   Dr. Guy Nir
%   Shahriar Noroozi Zadeh
%   Amir Refaee
%   Lap-Tak Chu

[fpath, NumSVSslides,~,~,~,~,~] = RunTimeInformation([],[],'r',0,0,0);

disp('Saving Results ...');

if ~exist(fpath, 'dir')
    mkdir(fpath);
end

% Slide Based Analysis Data Saving
disp('Saving Each Slides Confusion Matrix (%) Data ...');
fid = fopen(fullfile(fpath,'SlideResults.txt'), 'wt'); % Open for writing
for i=1:NumSVSslides
    fprintf(fid,'Slide Number #%d', i);
    fprintf(fid,'\n    Specificity: \n');
    spc = bsxfun(@rdivide,conf_mat_leaveout(:,:,i),sum(conf_mat_leaveout(:,:,i)+eps,2));
    for j=1:size(spc,1)
        fprintf(fid, '   %0.4f ', spc(j,:));
        fprintf(fid, '\n');
    end
    fprintf(fid,'\n    Precision: \n');
    prc = bsxfun(@rdivide,conf_mat_leaveout(:,:,i),sum(conf_mat_leaveout(:,:,i)+eps,1));
    for j=1:size(prc,1)
        fprintf(fid, '   %0.4f ', prc(j,:));
        fprintf(fid, '\n');
    end
    x = trace(conf_mat_leaveout(:,:,i))/sum(sum(conf_mat_leaveout(:,:,i)));
    fprintf(fid,'\n    Accuracy: \n');
    fprintf(fid,  '  Correct:    %0.4f', x);
    fprintf(fid,'\n    Error:    %0.4f', (1-x));
    fprintf(fid,'\n======================\n');
end
fclose(fid);
disp('Each Slide Confusion Matrix (%) Data Saved!');

% Total Classification Analysis Data Saving
disp('Saving Confusion Matrix (%) ...');
fid = fopen(fullfile(fpath,'TotalResults.txt'), 'wt'); % Open for writing
fprintf(fid,'All Slides Average Results)\n');
fprintf(fid,'\n    Specificity: \n');
for i=1:size(percentResultClassify,1)
    fprintf(fid, '   %0.4f ', percentResultClassify(i,:));
    fprintf(fid, '\n');
end
fprintf(fid,'\n======================\n');
fclose(fid);
disp('Confusion Matrix (%) Saved!');