% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Extracts cell features given its RGB image and a centroid


function [features] = get_cell_data(image,centroid)

    bwim = Segment.Processes.process_segmentation(image,centroid);

    %only take biggest component
    comp = bwconncomp(imcomplement(bwim));
    numOfPixels = cellfun(@numel,comp.PixelIdxList);
    [unused,indexOfMax] = max(numOfPixels);
    [row,col] = ind2sub(comp.ImageSize,comp.PixelIdxList{indexOfMax});
    L = [col,row];
    dim = size(image);
    mask = true(dim(1:2));          
    for i=1:size(L,1)
        mask(round(L(i,2)),round(L(i,1))) = 0;                
    end
    bwim = mask;

    [endpoints, junctions, skelIm] = Tools.skeleton_analysis(bwim);
    fractalDim = hausDim(bwim);

    %how branchy is it
    branch_size = sum(skelIm(:));

    %how bushy it is
    bushiness = sum(imcomplement(bwim(:)));

    %calculate 2nd moment from centroid
    sq = 0;
    count = 1;
    for i=1:size(mask,1)
        for j=1:size(mask,2)
            if (mask(i,j) == 0)
                count = count+1;
                sq = sq + (i-centroid(2))^2 + (j-centroid(1))^2;
            end
        end
    end
    moment = sq/count;

    %2nd moment skel
    sq = 0;
    count = 1;
    for i=1:size(skelIm,1)
        for j=1:size(skelIm,2)
            if (skelIm(i,j) == 1)
                count = count+1;
                sq = sq + (i-centroid(2))^2 + (j-centroid(1))^2;
            end
        end
    end
    moment_skel = sq/count;

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
    max_radius = r;

    %bwdist
    edtImage = bwdist(skelIm);
    maxDiam = 2 * max(edtImage(:));  % Max() will give the radius.

    if maxDiam == Inf
        maxDiam = 100;
    end

    %circularity
    perim = bwperim(mask);
    circularity = sum(perim(:))/sum(mask(:));
    
    assert(size(skelIm,1)==size(skelIm,2));

    lacunarity = lacunarity_glbox(skelIm);

    features = [fractalDim, moment,lacunarity(end),bushiness,circularity,moment_skel];
    %,maxDiam];%,circularity, bushiness, branch_size, r];%, branch_size, circularity,r];

end

