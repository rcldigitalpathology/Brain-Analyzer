% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Takes the contents of the chosen path, which should contain the result of
% a call to ML.prepare_training.m, and injects a set of manually extracted
% features.

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

features = [];
for i=1:length(imds.Files)
    im  = imread(imds.Files{i});
    features = [features; extract_features(im)];
    fprintf('extracted features for %d out of %d\n',i,length(imds.Files));
end
labels = imds.Labels;

save('../data/formatted/features_calculated.mat','features','labels');

function [ allfeatures ] = extract_features( im )   

    %format image
    RGB = imgaussfilt(im,1);
    R = RGB(:,:,1);
    G = RGB(:,:,2);
    B = RGB(:,:,3);
    
    %caclulate mean, std and histogram standard deviations
    colour_features = [mean2(R),mean2(G),mean2(B),std2(R),std2(G),std2(B),...
        std(imhist(R,10)),std(imhist(G,10)),std(imhist(B,10))];
    
    %process grayscale and bimary images
    grayIm = rgb2gray(im);
    binIm = imbinarize(grayIm); %using Otsu's
    mask = ~imerode(~binIm,strel('disk',1)); %remove some noise
    mask =  ~bwareafilt(~mask,1); %only get largest component
    
    gray_features = [mean2(grayIm), std2(grayIm)];
    binary_features = [sum(mask(:))];
    
    %find median-centroid of cell mass
    centroid_mask = mask;
    count = 1;
    while (count < 3)
        count = count+1;
        temp = imdilate(centroid_mask,strel('disk',1));
        if all(temp(:)) %if no black
            break;
        end
        centroid_mask = temp;
    end
    centroid_mask =  ~bwareafilt(~centroid_mask,1);

    xs = [];
    ys = [];
    for i=1:size(centroid_mask,1)
        for j=1:size(centroid_mask,2)
            if (centroid_mask(i,j) == 0)
                xs = [xs j];
                ys = [ys i];
            end
        end
    end
    centroid = round([median(xs) median(ys)]); %[column from left,row from top]
    
    %calculate 2nd moment from centroid
    sq = 0;
    for i=1:size(mask,1)
        for j=1:size(mask,2)
            if (mask(i,j) == 0)
                sq = sq + (i-centroid(2))^2 + (j-centroid(1))^2;
            end
        end
    end
    moment = sq/count;
    
    %max inscribed circle from centroid
    flag = true;
    r=0;
    while (flag)
        r = r+1;
        nump = 2*pi*r;
        for a=1:nump
            rad = a/r;
            point = round(r*[cos(rad) sin(rad)])+[centroid(1) centroid(2)];
            
            if (point(1)<1 || point(1)>size(mask,1) || point(2)<1 || point(2)>size(mask,2))
                flag = false;
                break;
            end
            if (any(isnan(point)))
                flag = false;
                break;
            end
            if (mask(point(2),point(1)) == 1)
                flag = false;
                break;
            end
        end
    end
    
    %circularity
    perim = bwperim(mask);
    circularity = sum(perim(:))/sum(mask(:));
    
    %Discrete Cosine transform
    [f1,f2,f3,f4,f5,f6] = DCT(grayIm);
    dct_features = [mean2(f1),mean2(f2),mean2(f3),mean2(f4),mean2(f5),...
        mean2(f6),std2(f1),std2(f2),std2(f3),std2(f4),std2(f5),std2(f6)];
    
    allfeatures = [colour_features,gray_features,binary_features,...
                    moment,r,circularity,...
                    dct_features];
end


function [f1,f2,f3,f4,f5,f6] = DCT(grayim)
    % Divide patch into 4 blocks and take Discrete Cosine Transform of it
    D = cell(4);
    endr = size(grayim,1);
    endc = size(grayim,2);
    for i = 1:4
        for j = 1:4
            D{i,j} = dct(im2single(grayim((i-1)*floor(endr/4)+1 : i*floor(endr/4), ...
                                           (j-1)*floor(endc/4)+1 : j*floor(endc/4))));
        end
    end

    f1 = D{1,1};
    f2 = abs(D{2,1});
    f3 = abs(D{1,2});

    f4 = 0;
    for i = 3:4
        for j = 1:2
            f4 = f4+abs(D{i,j})/4;
        end
    end

    f5 = 0;
    for i = 1:2
        for j = 3:4
            f5 = f5+abs(D{i,j})/4;
        end
    end

    f6 = 0;
    for i = 3:4
        for j = 3:4
            f6 = f6+abs(D{i,j})/4;
        end
    end
end

