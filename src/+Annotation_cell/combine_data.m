% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Creates Union and Intersect data set based on our two independent data
% sets

[file_name_1,path_name_1] = uigetfile('annotation file 1');
[file_name_2,path_name_2] = uigetfile('annotation file 2');

intersect_data = [];
union_data = [];

set1 = load(strcat(path_name_1,file_name_1));
data1=set1.data;
dpids1=set1.dpids;

set2 = load(strcat(path_name_2,file_name_2));
data2=set2.data;
dpids2=set2.dpids;

common_dpids = intersect(dpids1,dpids2);

data1 = data1(ismember(data1(:,1),common_dpids),:);
data2 = data2(ismember(data2(:,1),common_dpids),:);

for i=1:size(common_dpids,1)
    dpid = common_dpids(i);
    
    dpid_data1 = data1(data1(:,1) == dpid, :);
    dpid_data1 = dpid_data1(:,2:end);

    dpid_data2 = data2(data2(:,1) == dpid, :);
    dpid_data2 = dpid_data2(:,2:end);

    unique_to_1 = ones(size(dpid_data1,1),1);
    unique_to_2 = ones(size(dpid_data2,1),1);
    
    for k=1:size(unique_to_1,1)
        for j=1:size(unique_to_2,1) 
            point1 = round(dpid_data1(k,:));
            point2 = round(dpid_data2(j,:));     

            if (unique_to_2(j) == 0)
                continue
            end

            d = Tools.calc_distance(point1,point2);
            if (d < 15)
               unique_to_1(k) = 0;
               unique_to_2(j) = 0;
               if randi(2) == 1
                  intersect_data = [intersect_data; dpid point1(1) point1(2)]; 
               else
                  intersect_data = [intersect_data; dpid point2(1) point2(2)];                   
               end
               break;                 
            end
        end
    end
    
    for k=1:size(unique_to_1,1)
        if (unique_to_1(k) == 1)
            point1 = round(dpid_data1(k,:));
            union_data = [union_data; dpid point1(1) point1(2)]; 
        end
    end
    for k=1:size(unique_to_2,1)
        if (unique_to_2(k) == 1)
            point2 = round(dpid_data2(k,:));
            union_data = [union_data; dpid point2(1) point2(2)]; 
        end
    end
    fprintf('done %d of %d\n',i,size(common_dpids,1));
end

union_data = [union_data; intersect_data];


dpids = common_dpids;
data = intersect_data;
save('+Annotation_cell/cell_detection_analysis_utility/labelling/annotation_data_intersect.mat','dpids','data');
size(data)

dpids = common_dpids;
data = union_data;
save('+Annotation_cell/cell_detection_analysis_utility/labelling/annotation_data_union.mat','dpids','data');
size(data)




 