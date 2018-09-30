% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi
% 
% Sets the 'subimage' property of the cell by dynamically determining a
% bounding box around the cell based on its size.
%

function [soma] = soma_bound_box( soma )

    bigImage = soma.referenceDPImage.image;
    ocbrcImage = soma.referenceDPImage.preThresh;
       
    maxh = size(bigImage,1);
    maxw = size(bigImage,2);

    LENGTH = 40;
    
    newTL = soma.centroid - LENGTH/2; %x,y
    newBR = soma.centroid + LENGTH/2; %x,y
    
    TL = [-1 -1];
    BR = [-1 -1];
    
    if newTL(1) < 1
        diff = 1-newTL(1);
        newTL(1) = 1;
        newBR(1) = newBR(1)+diff;
    end
    if newTL(2) < 1
        diff = 1-newTL(2);
        newTL(2) = 1;
        newBR(2) = newBR(2)+diff;
    end    
    if newBR(1) > maxw
        diff = newBR(1) - maxw;
        newBR(1) = maxw;
        newTL(1) = newTL(1)-diff;
    end    
    if newBR(2) > maxh
        diff=newBR(2)-maxh;
        newBR(2) = maxh;
        newTL(2) = newTL(2)-diff;
    end 
        
    TL = newTL;
    BR = newBR;
    C = round(BR-TL);
    
    relCentroid = soma.centroid - TL + [1,1];
    
    relCentroid(relCentroid>LENGTH) = LENGTH;
    relCentroid(relCentroid<1) = 1;
    
    oim = imcrop(ocbrcImage,[TL, C(1), C(2)]);

    soma.subImage = imcrop(bigImage,[TL, C(1)-1, C(2)-1]);
    soma.oImage = oim;
    soma.rCentroid = relCentroid;
    soma.TL = TL;
    A = size(soma.subImage);
    assert(A(1)==LENGTH);
    assert(A(2)==LENGTH);
    assert(relCentroid(1)>0 && relCentroid(1)<=LENGTH && relCentroid(2)>0 && relCentroid(2)<=LENGTH)

end

