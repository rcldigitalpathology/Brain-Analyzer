% University of British Columbia, Vancouver, 2017
%   William Choi
%   Alex Kyriazis

%visualize_slide - helper function for GUI/main.m to display data. 

function [ output_args ] = visualize_slide( vis_type )

    %   vis_type = 1 cell count
    %   vis_type = 2 cell morphology

    global outputData1; global outputData2; global im; global blockSize; global DPslide;
    
    if vis_type == 1
        a = outputData1;
    else
        a = outputData2;
    end

    bg = find(a==-2);
    gm = find(a==-1);
    
    owm = a(a>=0);

    maxval = max(owm(:)); %find maximum intensity
    minval = min(owm(:)); %find minimum intensity

    map = colormap; %get current colormap (usually this will be the default one)
    a_copy = floor((a-minval)./(maxval-minval)*length(map));
    a_copy=ind2rgb(a_copy, map);

    [xbg, ybg] = ind2sub(size(a_copy),bg);
    [xgm, ygm] = ind2sub(size(a_copy),gm);


    for indx = 1:length(xbg)
        a_copy(xbg(indx),ybg(indx),:) = [1 1 1];
    end
    for indx = 1:length(xgm)
        a_copy(xgm(indx),ygm(indx),:) = [0.5 95/255 101/255]; %colour scheme choice
    end

    if vis_type == 1
        
        UM_PER_PIXEL = 0.496; %microns
        BLOCK_PIXEL_LENGTH = 256; %pixels 
        BLOCK_AREA_UM_SQ = (BLOCK_PIXEL_LENGTH*UM_PER_PIXEL)^2; %microns squared
        UM_SQ_PER_MM_SQ = 10^6;
        
        SCALING_FACTOR = 100;
       
        a=a/BLOCK_AREA_UM_SQ*UM_SQ_PER_MM_SQ/SCALING_FACTOR; %100s per mm^2
    end

    ggg= image(a_copy,'Tag','slideImage');
    hold on
    b=surf(a);
    alpha(b,0);
    shading('interp');
    
    hc=colorbar;
    
    
    if vis_type == 1
        title(hc,{"100 per","mm^2"});
    else
        title(hc,"Percent Ramified");
        %TODO, fix colour bar from 0 to 1
    end
    
    ax = gca;
    box on;
    set(ax,'xtick',[],'ytick',[]);
    ax.XColor = [1 1 1];
    ax.YColor = [1 1 1];
        
    set (gcf, 'WindowButtonMotionFcn', @mouseMoveSimple);

    
    function [ output_args ] = mouseMoveSimple( src, event )
    %MOUSEMOVESIMPLE Summary of this function goes here
    %   Detailed explanation goes here

        handles = guidata(src);

        cursor = get (handles.axes1, 'CurrentPoint');
        curX = round(cursor(1,1));
        curY = round(cursor(1,2));

        xLimits = get(handles.axes1, 'xlim');
        yLimits = get(handles.axes1, 'ylim');

        if (curX > min(xLimits) && curX < max(xLimits) && curY > min(yLimits) && curY < max(yLimits))
            set(handles.text1, 'String', ['(' num2str(curX) ', ' num2str(curY) ').'])
            
            axes(handles.axes2);
            
            ySize = size(outputData1,1);
            linInd = (curX-1)*ySize +curY;
            currentIm = imcrop(im,[DPslide(linInd).Pos{1}(1), DPslide(linInd).Pos{1}(2),... 
                                    DPslide(linInd).Pos{2}(1)-DPslide(linInd).Pos{1}(1), DPslide(linInd).Pos{2}(2)-DPslide(linInd).Pos{1}(2)]);
                                
            if outputData1(curY,curX) >= 0
                imshow(currentIm);
            else
                imshow('../assets/imunavail.png');
            end
            
            if handles.visCount
                set(handles.text2, 'String', ['Cell Count:  ' num2str(outputData1(curY, curX))])
            elseif handles.visMorph
                set(handles.text2, 'String', ['Cell Morphology:  ' num2str(outputData2(curY, curX))])
            end
        else
            set(handles.text1, 'String', 'Cursor is outside bounds of image.')
        end
    end

end



