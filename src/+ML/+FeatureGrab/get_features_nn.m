% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Takes the contents of /data/formatted, which should contain the result of
% a call to ML.prepare_training.m, and injects a set of AlexNet features.

% This requires having the AlexNet convnet in assets/

run init.m

%find data folder
out_path = uigetdir('../data/','Choose training folder');

%set categories
categories = {'falsePositives', 'truePositives'};
imds = imageDatastore(fullfile(out_path, categories), 'LabelSource', 'foldernames');

%split into equal pieces
tbl = countEachLabel(imds);
minSetCount = min(tbl{:,2}); % determine the smallest amount of images in a category
imds = splitEachLabel(imds, minSetCount, 'randomize');
imds.ReadFcn = @(filename)readAndPreprocessImage(filename);

% display count
countEachLabel(imds)

% Find the first instance of an image for each category
falsePositives = find(imds.Labels == 'falsePositives', 1);
truePositives = find(imds.Labels == 'truePositives', 1);

%load cnn
cnnMatFile = 'assets/imagenet-caffe-alex.mat';
convnet = helperImportMatConvNet(cnnMatFile);

FEATURE_LAYER = 'fc6';
features = activations(convnet, imds, FEATURE_LAYER, ...
   'MiniBatchSize', 32, 'OutputAs', 'rows');
labels = imds.Labels;

save('../data/formatted/features_alexnet.mat','features','labels');

function Iout = readAndPreprocessImage(filename)

    I = imread(filename);

    % Some images may be grayscale. Replicate the image 3 times to
    % create an RGB image.
    if ismatrix(I)
        I = cat(3,I,I,I);
    end

    Iout = imresize(I, [227 227]);
end