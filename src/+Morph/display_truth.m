% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis

% Opens a random image and displays its labelled morphology classification.

load('+Annotation_morph/morphology_analysis_utility/labelling/annotation_morph_data.mat');

item = data(randi(size(data,1)),:);

image_name = ['+Annotation_morph/morphology_analysis_utility/images/', num2str(item(1)),'.tif'];
image = imread(image_name);
imshow(image,'InitialMagnification',800);
hold on;
item(2)