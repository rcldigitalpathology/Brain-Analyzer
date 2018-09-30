% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Gets our algorithm's output data in the same format as labelled data 

function [ data,dpids ] = get_extraction_data(dpids)

    all_data = {};
    
    for i=1:size(dpids,1)
        dpid = dpids(i);
        current_data= [];
        found_soma = Segment.Soma.extract_soma(DPImage(dpid));
        for j=1:size(found_soma,2) 
            soma = found_soma{j};
            if soma.isFalsePositive == 1
                continue;
            end
            current_data = [current_data; dpid soma.centroid(1) soma.centroid(2)];
        end
        all_data{i} = current_data;
        %fprintf('Finished analyzing %d of %d\n',i,size(dpids,1));
    end
    
    data=[];
    for j=1:size(all_data,2)
        data=[data; all_data{j}];
    end
end

