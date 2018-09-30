% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Evaluates a previously annotated image to determine effectiveness
% of segmentation algorithm.

%Labeller name could be 'labeller1','labeller2', whatever name has been saved, or
%possibly 'union' and 'intersect' if +Annotation_Cell/combine_data.mat has
%been run

function [GT,TP,FP,FN] = evaluate_image_performance(dpid,labeller_name,shouldPlot)

    if ~exist('shouldPlot','var')
        shouldPlot = 0;
    end   

    dp = DPImage(dpid);
    if Tools.is_edge_image(dp)
       fprintf('Probably an edge slide\n');
    end
    
    mat1 = load(Config.get_config('CELL_CLASSIFIER_PATH'));
    cell_classifier = mat1.classifier;
    
    [found_soma,dp] = Segment.Soma.extract_soma(dp,cell_classifier);

    data=[];
    dpids=[];
    
    GROUND_TRUTH_PATH = strcat('+Annotation_cell/cell_detection_analysis_utility/labelling/annotation_data_',labeller_name,'.mat');
    load(GROUND_TRUTH_PATH);

    if (~any(dpids==dpid))
        error('cant evaluate an image that hasnt been annotated')
    end

    if (~ischar(dpid)) %in case we are looking at visualization images that don't have ground truth
        ground_truth = data(data(:,1) == dpid, :);
        ground_truth = ground_truth(:,2:end);       
    else
        ground_truth = [];
    end

        
    fp = ones(size(found_soma,2),1);
    fn = ones(size(ground_truth,1),1);
    
    num_extracted_fp = 0;
    for j=1:size(found_soma,2) 
        soma = found_soma{j};
        if soma.isFalsePositive == 1
            num_extracted_fp = num_extracted_fp + 1;
        end   
    end
    
    for i=1:size(ground_truth,1)
        if (fn(i) == 0)
            continue;
        end
        true_point = round(ground_truth(i,:));
        for j=1:size(found_soma,2) 
            if (fp(j) == 0)
               continue;
            end
            soma = found_soma{j};
            d = Tools.calc_distance(true_point,soma.centroid);

            if soma.isFalsePositive == 1
                continue;
            end
            
            if (d < 20)
               fp(j) = 0;
               fn(i) = 0;
               break;                 
            end
            
%             if (d < soma.maxRadius)
%                 inside_mask = Tools.pixel_list_binary_search(round(soma.pixelList),round(true_point));
%                 if (d < 15 || (inside_mask && d<30))
%                    fp(j) = 0;
%                    fn(i) = 0;
%                    break;                 
%                 end
%             end
        end
    end
    
    %PLOT SUCCESS VISUALISATION
    if (shouldPlot == 2)
        figure('units','normalized','outerposition',[0 0 1 1]);

        grayIm = rgb2gray(dp.image);
        grayIm = grayIm + (255-mean(grayIm(grayIm<200)));
        
         totalIm = [dp.image repmat(grayIm,1,1,3) repmat(dp.preThresh,1,1,3) repmat(dp.somaMask*255,1,1,3),dp.image];
         imshow(totalIm,'InitialMagnification','fit');

         hold on;

         for j=1:size(fp,1)
            soma = found_soma{j};

            if (fp(j) == 1)
                if soma.isFalsePositive == 1
                    plot(4*size(dp.image,2)+soma.centroid(1)+0*size(dp.image,2),soma.centroid(2),'.','MarkerSize',20,'color','yellow');  
                else
                    plot(4*size(dp.image,2)+soma.centroid(1)+0*size(dp.image,2),soma.centroid(2),'.','MarkerSize',20,'color','red');   
                end
            elseif (fp(j) == 0)
                plot(4*size(dp.image,2)+soma.centroid(1)+0*size(dp.image,2),soma.centroid(2),'.','MarkerSize',20,'color',[1 0 1]);
            end
            
            if (soma.isClump)
                plot(4*size(dp.image,2)+soma.centroid(1)+0*size(dp.image,2),soma.centroid(2),'.','MarkerSize',10,'color',[0 0 0]);
            end
        end  
        for j=1:size(fn,1)
            if (fn(j) == 1)
                tp = round(ground_truth(j,:));
                plot(4*size(dp.image,2)+tp(1)+0*size(dp.image,2),tp(2),'.','MarkerSize',20,'color','blue');
            end
        end

        %ALLOWS FOR CUSTOM LEGEND
        h = zeros(3, 1);
        h(1) = plot(NaN,NaN,'.r','MarkerSize',20);
        h(2) = plot(NaN,NaN,'.b','MarkerSize',20);
        h(3) = plot(NaN,NaN,'.','color',[1 0 1],'MarkerSize',20);
        h(4) = plot(NaN,NaN,'.','color','yellow','MarkerSize',20);
        h(5) = plot(NaN,NaN,'.','color',[0,0,0],'MarkerSize',20);

        legend(h, 'False Positive','False Negative','Match','Rejected by NN','Clump constituent','Location','southeast');
    end
    
    %CALCULATE STATISTICS
    GT = size(ground_truth,1); % # GROUND TRUTH
    FP = sum(fp==1)-num_extracted_fp; % # FALSE POSITIVES
    FN = sum(fn==1); % # FALSE NEGATIVES
    TP = sum(fp==0); % TRUE POSITIVE

    score = -1;
    
    if (shouldPlot ~= 0)
        fprintf('For image %s : GT:%d, FP:%d, FN:%d, TP:%d \n',dp.filename,GT,FP,FN,TP);
    end
end

