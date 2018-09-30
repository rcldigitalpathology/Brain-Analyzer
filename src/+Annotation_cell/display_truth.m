% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Displays the labelled dataset superimposed on a random image in the set
% Specifcy which data set in the first load line

function display_truth(name)

    if ~exist('name','var')
        name = 'labeller1';
    end   
    
    path = strcat('+Annotation_cell/cell_detection_analysis_utility/labelling/annotation_data_',name,'.mat')

    load(path);

    dpid = dpids(randi(length(dpids)));

    points = data(data(:,1)==dpid,:);
    points = points(:,2:end);

    image_name = ['../data/v3/', num2str(dpid),'.tif']
    image = imread(image_name);
    imshow([image image],'InitialMagnification',400);
    hold on;

    for j=1:size(points,1)
        plot(points(j,1),points(j,2),'.','color','blue','MarkerSize',40);
    end
end