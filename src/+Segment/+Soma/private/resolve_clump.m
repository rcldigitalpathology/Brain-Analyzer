% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi
% 
% Separates a large clump of cells into its constituent cells
%
function [ flag, somas ] = resolve_clump( dpcell )

    somas = 0;
    flag = 0;

    Iobrcbr = dpcell.oImage;
    rgbIm = dpcell.subImage;
    

    adjusted = imadjust(rgb2gray(rgbIm),[0; Config.get_config('CLUMP_ADJUST_THRESHOLD')],[0; 1]);
    
    mumfordIm = smooth_ms(adjusted, Config.get_config('CLUMP_MUMFORD_SHAH_LAMBDA'), Inf);
    
    out = imbinarize(mumfordIm,Config.get_config('CLUMP_THRESHOLD'));
    
    %find the mask of the actual cell clump
    dim = size(adjusted);
    mask = false(dim(1:2));          
    for i=1:size(dpcell.pixelList,1)
        A = dpcell.pixelList(i,:);
        A = round(A-dpcell.TL)+[1,1]; %adjust for soma image
        
        X = round(A(2));
        Y = round(A(1));
        
        if X>0 && X<=size(adjusted,2) && Y>0 && Y<=size(adjusted,1)
            mask(X,Y) = 1;  
        end         
    end  
    c = out;
    out = ~((~c) .* mask);

    comp = bwconncomp(~out);

    somas = {};
    for i=1:comp.NumObjects
        [row,col] = ind2sub(comp.ImageSize,comp.PixelIdxList{i}); 
        
        row = row + dpcell.TL(2)-1; %convert to image coordinates
        col = col + dpcell.TL(1)-1; %convert to image coordinates

        if (size(row,1) < Config.get_config('CLUMP_THRESHOLD_MIN_SIZE'))
           continue;  %vtoo small- discard
        end
        
        centr = round(sum([col,row],1)/size(row,1)); %x-y coordinates
        good = Tools.pixel_list_binary_search(round(dpcell.pixelList),round(centr));
        
        if (good == 0)
           continue; %not part of original soma
        end
        
        soma = DPCell([col,row],dpcell.referenceDPImage);
        
        soma.isClump = 1;
        soma = prepare_soma(soma);
        somas{end+1} = soma{1};
    end
    
    r = dpcell.area/size(somas,1); %average area per soma
    if (r < 150) %probably too small
        somas = 0;
        return;
    end
    
    if (size(somas,1) > 0)
       flag = 1; 
    end
end

