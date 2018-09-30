% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis

% Prepares features for the morphology dataset


function [features,labels] = extract_data()
    data = Morph.get_set();
    data = data(randperm(size(data,1)),:);
    features = [];
    labels = [];
    
    B = randperm(size(data,1));
    for i=1:length(B)

        item = data(B(i),:);

        image_name = ['+Annotation_morph/morphology_analysis_utility/images/', num2str(item(1)),'.tif'];
        image = imread(image_name);
        centroid = mock_segment(image);
        
        extracted_features = Morph.get_cell_data(image,centroid);
        features = [features; extracted_features];
                
        labels = [labels; item(2)];
        
    end
    
%     m = mean(features(features~=Inf));
%     s = std(features(features~=Inf));
%     
%     features=(features-m)./s;


end

