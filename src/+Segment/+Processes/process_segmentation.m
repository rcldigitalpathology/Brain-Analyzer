% University of British Columbia, Vancouver, 2017
%   William Choi
%   Alex Kyriazis
% 
% The main entry point into process (cell branch) segmentation. Uses
% multithresholding techniques

function [ bwIm ] = process_segmentation( rgbCellImage, cellCentroid )
%   dpsoma - input soma object
%   PRE-CONDITIONS: cellCentroid is in the object of interest
%                   cellCentroid is in x y format


    cellIm = imadjust(rgbCellImage(:,:,3));
    averageIntensity = sum(sum(cellIm))/(size(cellIm,1)*size(cellIm,2));
    cellIm = imadjust(cellIm,[0; averageIntensity/255],[0; 1]); % removing pixels above average intensity
    
    centroid = [cellCentroid(2) cellCentroid(1)];
    centroid = round(centroid);
    
    % IMAGE QUANTIZATION using Otsu's mutilevel iamge thresholding
    N = 10; % number of thresholds % temporary changed to 13 from 20
    thresh = multithresh(cellIm, N);
    quantIm = imquantize(cellIm, thresh);
    
    averageIntensity = sum(sum(cellIm))/(size(cellIm,1)*size(cellIm,2));
%     averageIntensity = median(cellIm(:));

    % SOMA DETECTION
    minSomaSize = 50;
    newQuantIm = zeros(size(cellIm));

    addedObjects = zeros(size(cellIm));
    numCountedObjects = zeros(1, N+1);
    for i = 1:N+1
        levelIm = quantIm == i;
        levelIm = levelIm + addedObjects + (newQuantIm>0);

        countedObjects = bwareaopen(levelIm, minSomaSize)- (newQuantIm>0);
        addedObjects = xor(levelIm, countedObjects); % removing objects greater than soma size
    %     CC = bwconncomp(countedObjects);
    %     numCountedObjects(i) = CC.NumObjects;

        % size filtered level added to the newly quantized image
        newQuantIm = newQuantIm + (countedObjects*i);
        B = newQuantIm ~= 0;
        CC = bwconncomp(B);
        numCountedObjects(i) = CC.NumObjects;
    end
     
%     x = 1:N+1;
%     figure, scatter(x,numCountedObjects);

    % Determining the Backgound level
    backgroundLevel = sum(thresh < averageIntensity)-1;

    % Determining the level at which soma appears
    firstSomaLevel = find(numCountedObjects > 0, 1, 'first');
    if firstSomaLevel >= backgroundLevel
        somaLevel = backgroundLevel;
    else
        lastSomaLevel = firstSomaLevel;
        for i = firstSomaLevel+1:backgroundLevel
            if numCountedObjects(i) == numCountedObjects(lastSomaLevel)
                lastSomaLevel = i;
            end
            if lastSomaLevel == backgroundLevel
                lastSomaLevel = round((firstSomaLevel+backgroundLevel)/2); % could potentially be changed
            end
        end
        somaLevel = round((firstSomaLevel + lastSomaLevel)/2);
    end



% % % % % % %     
%     ext = round(0.5*(size(quantIm,2)-size(quantIm,1)));
%     padsize = [ext*(ext>0) -ext*(ext<0)];
%     
%     subplot(6,9,[5,15],'replace'), imshow(padarray(rgbCellImage,padsize)), title('Original Image');
%     subplot(6,9,[23,33],'replace'), imshow(padarray(label2rgb(newQuantIm),padsize)), title('Quantized Image');
%     subplot(6,9,[41,51],'replace'), imshow(padarray(zeros(size(quantIm))+255,padsize,1)), title('Final Binarized Image');
%     subplot(6,9,[34,54],'replace'), imshow(padarray(zeros(size(newQuantIm)),padsize));
%     subplot(6,9,[7,27], 'replace'), imshow(padarray(zeros(size(newQuantIm)),padsize));
%     hold on;

    % REMOVING UNNECESSARY COMPONENTS
    bwNewQuantIm = newQuantIm < backgroundLevel;
            
    filtered = 0;
    comp = bwconncomp(bwNewQuantIm);
    for i=1:comp.NumObjects
        [row,col] = ind2sub(comp.ImageSize,comp.PixelIdxList{i}); 
        
        good = Tools.pixel_list_binary_search([col,row],round(cellCentroid));
        if(good == 1)
            tempIm = ones(size(newQuantIm));
            tempIm(comp.PixelIdxList{i}) = 0;
            newQuantIm(logical(tempIm)) = 0;
            filtered = 1;
            break;
        end
    end
    

    %In the event that centroid is not in the component
%     if filtered == 0
%         stat = regionprops(bwNewQuantIm,'centroid');
%         centroidList = cat(1,stat.Centroid);
%         distList = zeros(1,size(centroidList,1));
%         for i=1:size(centroidList,1)
%             distList(i) = Tools.calc_distance(centroidList(i,:),centroid);
%         end
%         minDist = find(distList == min(distList),1);
%         tempIm = ones(size(newQuantIm));
%         tempIm(comp.PixelIdxList{minDist}) = 0;
%         newQuantIm(logical(tempIm)) = 0;
%     end
    
    % SEED SAMPLING at each quantized level
    seedIm = zeros(size(cellIm));
    for i = somaLevel:backgroundLevel
        levelIm = newQuantIm == i; 
        if i == somaLevel
            A = newQuantIm > 0;
            B = newQuantIm <= somaLevel;
            levelIm = and(A,B);
            % seeds will be sampled from the perimeter of the soma 
            levelIm = bwperim(levelIm); % 4 connectivity (default)
        end
        originalIm = cellIm;
        originalIm(imcomplement(levelIm)) = 255; % overlaying binary mask on the original image
        compositeIm = cat(3,levelIm,originalIm);

%         blockSize = [i+2-somaLevel i+2-somaLevel];
        blockSize = [2*i+3-2*somaLevel 2*i+3-2*somaLevel];
        func = @generate_seeds;
        seeds = blockproc(compositeIm, blockSize, func);
        
        seedIm = seedIm + seeds*i;

%         subplot(6,9, [7,27]);
%         imshow(padarray(seedIm,padsize)); % uncomment to see seeds at each stage
%         hold on;
%         pause(0.02);

    end

    % Minimum spanning tree
%     cellCentroid = zeros(size(cellIm));
%     cellCentroid(centroid) = 1; 

%     centroidDistTrans = bwdist(cellCentroid, 'quasi-euclidean');
%     somaLayer = seedIm == somaLevel;
%     somaSeedDist = centroidDistTrans.*somaLayer;
%     minVal = min(somaSeedDist(somaSeedDist > 0));
%     minVal
%     [rootRow, rootCol] = find(somaSeedDist == minVal, 1); % root node;
% 
%     seed = zeros(size(cellIm));
%     seed(rootRow, rootCol) = 1;
%     currRow = rootRow;
%     currCol = rootCol;

    
    
    % CREATING A WEIGHTED MASK USED TO DETERMINE GEODESIC DISTANCE
    lastLevel = backgroundLevel+1;
    for i = somaLevel:lastLevel
        if i ~= somaLevel
            levelIm = newQuantIm == i;
            if i <= round((somaLevel*2+lastLevel)/3)
                cellArea = cellArea + levelIm.*(i+1-somaLevel);
            elseif i <= round((somaLevel+2*lastLevel)/3)
                cellArea = cellArea + levelIm.*(i+1-somaLevel)^2;
            else
                cellArea = cellArea + levelIm.*(i+1-somaLevel)^3;
            end
        else
            A = newQuantIm <= somaLevel;
            B = newQuantIm > 0;
            cellArea  = and(A,B);
        end
    end
            
    mask = double(cellArea);
    mask(mask == 0) = inf;
    
    currRow = centroid(1);
    currCol = centroid(2);
    seed = zeros(size(cellIm));
    seed(currRow, currCol) = 1;
    finalTree = zeros(size(cellIm));
    finalTree(currRow, currCol) = 1;
    % 
    for i = somaLevel:backgroundLevel
        seeds = seedIm == i;
        seeds(currRow,currCol) = 0; %removing the centroid, in case of an overlap.
        
        numSeeds = sum(sum(seeds));
        
        for j = 1:numSeeds
            offset = 5;
            seeds(currRow, currCol) = 0;
            [croppedSeeds, rowCoord, colCoord] = crop_image(seeds,currRow,currCol,offset);
            while sum(sum(croppedSeeds)) == 0
                offset = offset + 5;
                [croppedSeeds, rowCoord, colCoord] = crop_image(seeds,currRow,currCol,offset);
            end
            croppedMask = crop_image(mask,currRow,currCol,offset);
            croppedSeed = crop_image(logical(seed),currRow,currCol,offset);
            
            distTrans1 = graydist(croppedMask,croppedSeed,'quasi-euclidean');
            
            seedDist = distTrans1.*croppedSeeds; % no need to worry about inf as seeds are all in the mask area
            seedDist(isnan(seedDist)) = 0;
            minVal = min(seedDist(seedDist > 0));    
            [croprow, cropcol] = find(seedDist == minVal, 1);
            nxtRow = croprow+rowCoord-1;
            nxtCol = cropcol+colCoord-1;

            seed(currRow, currCol) = 0;
            seed(nxtRow, nxtCol) = 1;
            
            [rowSize, colSize] = size(croppedSeed);
            croppedSeed = zeros(rowSize,colSize);
            croppedSeed(croprow,cropcol) = 1;

            distTrans2 = graydist(croppedMask, logical(croppedSeed), 'quasi-euclidean');

            if minVal ~= inf
                sumDistTrans = distTrans1 + distTrans2;
                sumDistTrans = round(sumDistTrans.*8) / 8;
                path = imregionalmin(sumDistTrans);

                thinnedPath = bwmorph(path, 'thin', inf);

                %draw line bettween current coordinates and next coordinate
                croppedTree = finalTree(rowCoord:rowCoord+rowSize-1,colCoord:colCoord+colSize-1);
                croppedTree = or(croppedTree,thinnedPath);
                finalTree(rowCoord:rowCoord+rowSize-1,colCoord:colCoord+colSize-1) = croppedTree;
            end

            finalTree(nxtRow, nxtCol) = 1;
            currRow = nxtRow;
            currCol = nxtCol;
        end

%         subplot(6,9,[34,54]);
%         imshow(padarray(finalTree,padsize)); % uncomment to see the tree at each stage
%         hold on;
%         pause(0.001);

    end

    % overlaying the soma image on the tree
    A = newQuantIm > 0;
    B = newQuantIm <= somaLevel;
    somaIm = and(A,B);
    
    
    temp = finalTree;
    finalTree =  or(temp, somaIm); 

    % filling small holes
    filled = imfill(finalTree,'holes');
    holes = and(filled, ~finalTree);
    bigHoles = bwareaopen(holes, 15); % 15 pixel size limit on holes
    smallHoles = and(holes, ~bigHoles);
    bwIm = imcomplement(or(finalTree, smallHoles));

    % pruning - should be improved
    bwIm = bwmorph(bwIm, 'spur', 5);
    

% % % % % % % 
%     subplot(6,9,[41,51]), imshow(padarray(bwIm,padsize,1)), title('Final Connected Tree');
%     hold on;
%     pause(0.3);
% % % % % % % 
%     figure; 
%     subplot(2,3,1), imshow(rgbCellImage), title('Original Image');
%     subplot(2,3,2), imshow(label2rgb(quantIm,'jet')), title('Quantized Image');
%     subplot(2,3,3), imshow(label2rgb(newQuantIm)), title('Newly Quantized Image');
%     subplot(2,3,4), imshow(seedIm), title('Seed Image');
%     subplot(2,3,5), imshow(bwIm), title('Final Connected Tree');
    
%     close all;
%     imshow(rgbCellImage)
%     set(gcf,'renderer','Painters')
%     print('-depsc','MicrogliaTracingE.eps');    
%     
%     close all;
%     imshow(label2rgb(quantIm,'jet'))
%     set(gcf,'renderer','Painters')
%     print('-depsc','MicrogliaTracingF.eps');
%     
%     close all;
%     imshow(seedIm)
%     set(gcf,'renderer','Painters')
%     print('-depsc','MicrogliaTracingG.eps');
%     
%     close all;
%     imshow(bwIm)
%     set(gcf,'renderer','Painters')
%     print('-depsc','MicrogliaTracingH.eps');

        
end

