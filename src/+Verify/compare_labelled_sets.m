% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Compare Labeller1 and Labeller2's data set to visually see what the biases are
% with both 

set1 = load('+Annotation/cell_detection_analysis_utility/labelling/annotation_data_labeller1.mat');
data1=set1.data;
dpids1=set1.dpids;

set2 = load('+Annotation/cell_detection_analysis_utility/labelling/annotation_data_labeller2.mat');
data2=set2.data;
dpids2=set2.dpids;

common_dpids = intersect(dpids1,dpids2);

length(common_dpids)

for l=1:5
    dpid = common_dpids(randi(length(common_dpids)));

    dpid_data1 = data1(data1(:,1) == dpid, :);
    dpid_data2 = data2(data2(:,1) == dpid, :);

    dpid_data1 = dpid_data1(:,2:end);
    dpid_data2 = dpid_data2(:,2:end);

    unique_to_1 = ones(size(dpid_data1,1),1);
    unique_to_2 = ones(size(dpid_data2,1),1);

    for i=1:size(unique_to_1,1)
        point1 = round(dpid_data1(i,:));
        for j=1:size(unique_to_2,1) 
            if (unique_to_2(j) == 0)
                continue
            end
            point2 = round(dpid_data2(j,:));     

            d = Tools.calc_distance(point1,point2);
            if (d < 15)
               unique_to_1(i) = 0;
               unique_to_2(j) = 0;
               break;                 
            end
        end
    end

    I = sum(unique_to_1==0);
    U1 = sum(unique_to_1==1);
    U2 = sum(unique_to_2==1);

    train_dpids = [];
    files = dir('../data/train/');
    k= 1;
    while k <= length(files)
        if endsWith(files(k).name,'.tif')
            filename = strip(files(k).name,'left','0');
            num = str2num(filename(1:end-4));
            train_dpids = [train_dpids num];
        end
        k = k + 1;
    end

    test_dpids = [];
    files = dir('../data/test/');
    k= 1;
    while k <= length(files)
        if endsWith(files(k).name,'.tif')
            filename = strip(files(k).name,'left','0');
            num = str2num(filename(1:end-4));
            test_dpids = [test_dpids num];
        end
        k = k + 1;
    end

    if ismember(dpid,train_dpids)
        filename = strcat('../data/train/',num2str(dpid),'.tif');
    elseif ismember(dpid,test_dpids)
        filename = strcat('../data/test/',num2str(dpid),'.tif');
    else
        error('image file cant be found');
    end

    image = imread(filename);

    figure('units','normalized','outerposition',[0 0 1 1]);

    imshow(image,'InitialMagnification','fit');
    hold on;

    for j=1:size(unique_to_1,1)
        if (unique_to_1(j) == 1)
            plot(dpid_data1(j,1),dpid_data1(j,2),'.','MarkerSize',40,'color','red');   
        elseif (unique_to_1(j) == 0)
            plot(dpid_data1(j,1),dpid_data1(j,2),'.','MarkerSize',40,'color',[1 0 1]);   
        end
    end

    for j=1:size(unique_to_2,1)
        if (unique_to_2(j) == 1)
            plot(dpid_data2(j,1),dpid_data2(j,2),'.','MarkerSize',40,'color','blue');   
        end
    end

    %ALLOWS FOR CUSTOM LEGEND
    h = zeros(3, 1);
    h(1) = plot(NaN,NaN,'.r','MarkerSize',20);
    h(2) = plot(NaN,NaN,'.b','MarkerSize',20);
    h(3) = plot(NaN,NaN,'.','color',[1 0 1],'MarkerSize',20);

    legend(h, 'Unique to Labeller1','Unique to Labeller2','Match','Location','southeast');

end


 