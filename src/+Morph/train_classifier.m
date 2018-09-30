% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis

% Trains a classification model on all the data and outputs it.

[file,path] = uiputfile('+Morph/classifiers/*.mat','Save classifier as');

tic;
[features,labels] = Morph.extract_data();
toc

labels(labels==2) = 1;
labels(labels==3) = 4;

t = templateSVM('Standardize',1);

X = features;
Y = labels;

classifier = fitcecoc(X,Y,'Learners',t);
save(strcat(path,file),'classifier');

