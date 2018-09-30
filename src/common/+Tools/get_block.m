% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Crops and normalizes a box of an image centered at the specified
% centroid, with a specificed box length

function [newim] = get_block(image,cent)

    %TODO read this from config file
    BOX_SIDE = 30;

    W = size(image,2);
    H = size(image,1);

    L = cent(1) - BOX_SIDE/2+1;
    R = cent(1) + BOX_SIDE/2;
    T = cent(2) - BOX_SIDE/2+1;
    B = cent(2) + BOX_SIDE/2;

    L_adj = L+max(0,-L+1);
    R_adj = R-max(0,R-W);
    T_adj = T+max(0,-T+1);
    B_adj = B-max(0,B-H);

    newim = imcrop(image,[[L_adj,T_adj],R_adj-L_adj, B_adj-T_adj]);

    if (-L+1 > 0)
        newim = [fliplr(newim(:,1:(L_adj-L),:)) newim];
    end
        
    if (-T+1 > 0)
        newim = [flipud(newim(1:(T_adj-T),:,:)); newim];
    end
        
    if (R-W > 0)
        newim = [newim fliplr(newim(:,end-(R-R_adj-1):end,:))];      
    end
        
    if (B-H > 0)
        newim = [newim; flipud(newim(end-(B-B_adj-1):end,:,:))];
    end
    
    assert(all(size(newim)==[BOX_SIDE,BOX_SIDE,3]));
    newim = newim(:,:,3);
    
%     newim = rgb2gray(newim);
%     newim = imadjust(newim,[0; double(prctile(newim(:),75))/255],[0; 1]);
%     
%     newim = Tools.normalize_image(newim);
end