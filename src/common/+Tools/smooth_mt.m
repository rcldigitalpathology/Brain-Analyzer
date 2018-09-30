% University of British Columbia, Vancouver, 2018
%   Alex Kyriazis

% Multithresholding helper function.

function [ out ] = smooth_mt( image, N)
%SMOOTH_MT Summary of this function goes here
%   Detailed explanation goes here

    cellIm = image;
    averageIntensity = sum(sum(cellIm))/(size(cellIm,1)*size(cellIm,2));
    cellIm = imadjust(cellIm,[0; averageIntensity/255],[0; 1]); % removing pixels above average intensity
    
    % IMAGE QUANTIZATION using Otsu's mutilevel iamge thresholding
    N; % number of thresholds % temporary changed to 13 from 20
    thresh = multithresh(cellIm, N);
    quantIm = imquantize(cellIm, thresh);

    % SOMA DETECTION
    minSomaSize = 100;
    newQuantIm = zeros(size(cellIm));

    addedObjects = zeros(size(cellIm));
    numCountedObjects = zeros(1, N+1);
    for i = 1:N+1
        levelIm = quantIm == i;
        levelIm = levelIm + addedObjects + (newQuantIm>0);

        countedObjects = bwareaopen(levelIm, minSomaSize)- (newQuantIm>0);
        addedObjects = xor(levelIm, countedObjects); % removing objects greater than soma size
        
        % size filtered level added to the newly quantized image
        newQuantIm = newQuantIm + (countedObjects*i);
        B = newQuantIm ~= 0;
        CC = bwconncomp(B);
        numCountedObjects(i) = CC.NumObjects;
    end
    
    out = uint8((newQuantIm-1)*(255/N));
end

