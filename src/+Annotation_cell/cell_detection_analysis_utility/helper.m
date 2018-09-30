% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Opens a user interface that allows one to manually select microglia on
% DPImages so that they can be used for training data for CNNs or other
% classification frameworks

%NOTE: the file to read and write to should be modified

function [ output_args ] = manual_label( dp,id_param )

    figure;
    b = imshow([dp],'InitialMagnification',400);
    hold on;
    
    %brings in 'data'
    data=[];
    dpids=[];
    load('labelling/annotation_data.mat');

    global P;
    P = [];

    set (gcf, 'WindowButtonDownFcn', @clickPoint);

    btn = uicontrol('Style', 'pushbutton', 'String', 'Save',...
        'Callback', @savePoints, 'HorizontalAlignment','center');
    
    fprintf('Image %s\n',strcat(num2str(id_param),'.tif'));

    function savePoints (objectHandle, eventData)
        
        for j=1:size(P,1)
          data = [data; id_param P(j,1) P(j,2)];  
        end
        dpids = [dpids; id_param];

        fprintf('Saving data\n');
        
        close all;
        save('annotation_data.mat','data','dpids');
    end

    function clickPoint (objectHandle , eventData )
        coordinates = get (gca, 'CurrentPoint');
        coordinates = coordinates(1,1:2);      

        type = get(gcf,'Selectiontype');

        if (strcmp(type,'normal')) %% left click

            x = coordinates(1);
            y = coordinates(2);
            
            if (x>0 && y>0 && x<256 && y<256)
                plot(x,y,'.','MarkerSize',40,'color','green','tag',encode([x y]));
                P = [P; x y];
                fprintf('Added point (%.1f,%.1f)\n',x,y);
            end
        end

        if(strcmp(type,'alt')) %% right click
            closestPointInd = -1;
            minTest = intmax;
            for i=1:size(P,1)
                point = P(i,:);
                d = norm(point-coordinates);
                if d < minTest
                    minTest = d;
                    closestPointInd = i;
                end
            end

            if(closestPointInd ~= -1)
                point = P(closestPointInd,:);

                id = encode(point);
                obj = (findobj(gca,'tag',id));

                delete(obj);
                P(closestPointInd,:) = [];

                fprintf('Deleted point (%.1f,%.1f)\n',point(1),point(2));
            end               
        end
    end

    function b = encode(coord)
        b = strcat(num2str(coord(1,1)),'|',num2str(coord(1,2)));
    end
end

