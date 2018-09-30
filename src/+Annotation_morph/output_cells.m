% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis

% Runs microglia detection on the specified patches and outputs cell bodies

out_path = uigetdir('../data/','Choose output folder');

dpids = Tools.find_dpids('test_v3');

Config.set_config('DEEP_FILTER_THRESHOLD',0.1); %obtain a stricter set for morph analysis

count = 1;
for i=1:size(dpids,1)
    dpid = dpids(i);
    dpim = DPImage(dpid); 
    
    found_soma = Segment.Soma.extract_soma(dpim);

    for j=1:size(found_soma,2)
        soma = found_soma{j};      
        
        [newim, isSide] = get_block_modified(dpim.image,soma.centroid);

        if (isSide == 0)
            image_name = strcat(num2str(count),'.tif');
            count = count+1;
            imwrite(newim,strcat(out_path,'/',image_name));
        end
    end
end

warning('this could generate a lot of images, consider deleting the generated folder after running sample_images.m');

function [newim, isSide] = get_block_modified(image,cent)

    isSide = 0;
    
    box_side = Config.get_config('MORPHOLOGY_ANALYSIS_BOX_SIZE');

    W = size(image,2);
    H = size(image,1);

    L = cent(1) - box_side/2+1;
    R = cent(1) + box_side/2;
    T = cent(2) - box_side/2+1;
    B = cent(2) + box_side/2;

    L_adj = L+max(0,-L+1);
    R_adj = R-max(0,R-W);
    T_adj = T+max(0,-T+1);
    B_adj = B-max(0,B-H);

    newim = imcrop(image,[[L_adj,T_adj],R_adj-L_adj, B_adj-T_adj]);

    if (-L+1 > 0 || -T+1 > 0 || R-W > 0 || B-H > 0)
        isSide = 1;
    end
end






 