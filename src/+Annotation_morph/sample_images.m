% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis

% Takes a large set of cells and randomly samples N cells (saves them in
% another folder)

in_path = uigetdir('../data/','Choose input folder');
out_path = uigetdir('+Annotation_morph/morphology_analysis_utility/','Choose output folder');

N = 300;
files = dir(in_path);
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

B = randperm(length(files));

for i=1:N
    file = files(B(i));
    file_path = [file.folder,'/',file.name];
    copyfile(file_path,[out_path,'/',file.name]);
end