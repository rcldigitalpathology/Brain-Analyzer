% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Saves false positive and true positive cell images in distinct folders

% Takes a specificed training set of the annotated images, uses automated algorithm to 
% compare against the annotated data set. Uses this to generate classes of false positive 
% and true positive cell identifications

% True positives are based on the data set specified in the load command
% below. Change as required.

%label_set: the ground truth to compare against (intersect, union, Asma, Tom, etc.)
%training_percentage: (if running on the final test set should
%be 1.0, else if you want a validation set, then <1.0, eg. 0.7)


function [] = prepare_training(label_set, training_percentage)
    out_path = uigetdir('../data/','Choose output folder');

    tp_class = 'truePositives';
    fp_class = 'falsePositives';

    mkdir(out_path,tp_class);
    mkdir(out_path,fp_class);

    path_tp = strcat(out_path,strcat('/',tp_class));
    path_fp = strcat(out_path,strcat('/',fp_class));
    meta_path = strcat(out_path,strcat('/','meta.mat'));

    data=[];
    dpids=[];
    load(strcat('+Annotation_cell/cell_detection_analysis_utility/labelling/annotation_data_',label_set,'.mat'));

    found_dpids = Tools.find_dpids('train_v3');
    dpids = intersect(found_dpids,dpids);
    data = data(ismember(data(:,1),found_dpids),:);

    %create a training/testing split in dpids
    setlength = randperm(size(dpids,1));

    training_dpids = dpids(setlength(1:floor(size(setlength,2)*training_percentage)),:);

    save(meta_path,'training_dpids');

    Config.set_config('USE_DEEP_FILTER',0);

    count = 1;
    for i=1:size(training_dpids,1)
        dpid = training_dpids(i);
        dpim = DPImage(dpid); 

        found_soma = Segment.Soma.extract_soma(dpim);

        ground_truth = data(data(:,1) == dpid, :);
        ground_truth = ground_truth(:,2:end);

        fp = ones(size(found_soma,2),1);
        for i=1:size(ground_truth,1)
            true_point = round(ground_truth(i,:));
            for j=1:size(found_soma,2) 
                soma = found_soma{j};      
                d = Tools.calc_distance(true_point,soma.centroid);
                if (d < soma.maxRadius)
                    inside_mask = pixelListBinarySearch(round(soma.pixelList),round(true_point));
                    if (d < 15 || inside_mask)
                       fp(j) = 0;
                       break;                 
                    end
                end
            end
        end

        for j=1:size(found_soma,2)
            soma = found_soma{j};      

            newim = Tools.get_block(dpim.image,soma.centroid);

            image_array = Tools.rotate_image(newim);
            for k=1:size(image_array,1)
                image_name = strcat(num2str(count),'.tif');
                count = count+1;
                if (fp(j) == 1)
                    imwrite(image_array{k},strcat(path_fp,'/',image_name));
                else
                    imwrite(image_array{k},strcat(path_tp,'/',image_name));
                end
            end
        end
    end

    %evens out the classes to remove variability when assessing different
    %models, since alexnet features takes a different set than what neural
    %network might take if there were more FP than TP
    size_tp = 0;
    k= 1;
    files_tp = dir(path_tp);
    while k <= length(files_tp)
        if endsWith(files_tp(k).name,'.tif')
            size_tp = size_tp + 1;
        end
        k = k + 1;
    end

    size_fp = 0;
    k= 1;
    files_fp = dir(path_fp);
    while k <= length(files_fp)
        if endsWith(files_fp(k).name,'.tif')
            size_fp = size_fp + 1;
        end
        k = k + 1;
    end       

    number_to_delete = abs(size_fp - size_tp);


    if size_fp > size_tp
        rand_index = randperm(size(files_fp,1));
        mixed_files = files_fp(rand_index);
        delete_path = path_fp;
    else
        rand_index = randperm(size(files_tp,1));
        mixed_files = files_tp(rand_index);
        delete_path = path_tp;    
    end

    k= 1;
    l= 1;
    while l <= number_to_delete
        if endsWith(mixed_files(k).name,'.tif')
            delete([delete_path,'/',mixed_files(k).name]);
            l = l+1;
        end
        k = k + 1;
    end     
end










 