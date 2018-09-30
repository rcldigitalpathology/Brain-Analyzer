% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Visualizes a segmentation in stages.

% Accepts 'dp' which is a DPImage, and 'cells' which is a list of segmented
% cells.

function [] = display_segment(dp,cells)

    if Tools.is_edge_image(dp)
       fprintf('edge image\n');
    end
    
    found_soma = cells;

    %PLOT SUCCESS VISUALISATION
    figure('units','normalized','outerposition',[0 0 1 1]);

    grayIm = rgb2gray(dp.image);
    grayIm = grayIm + (255-mean(grayIm(grayIm<200)));

    totalIm = [dp.image repmat(grayIm,1,1,3) repmat(dp.preThresh,1,1,3) repmat(dp.somaMask*255,1,1,3),dp.image];
    imshow(totalIm,'InitialMagnification','fit');

    hold on;

    for j=1:size(found_soma,2)
        soma = found_soma{j};

        plot(4*size(dp.image,2)+soma.centroid(1)+0*size(dp.image,2),soma.centroid(2),'.','MarkerSize',20,'color','green');  

        if (soma.isClump)
            plot(4*size(dp.image,2)+soma.centroid(1)+0*size(dp.image,2),soma.centroid(2),'.','MarkerSize',10,'color','cyan');
        end
    end  

    %ALLOWS FOR CUSTOM LEGEND
    h = zeros(2, 1);
    h(1) = plot(NaN,NaN,'.','color','green','MarkerSize',20);
    h(2) = plot(NaN,NaN,'.','color','cyan','MarkerSize',20);
    legend(h, 'Positive','Positive clump','Location','southeast');
end

