% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi
% 
% A preparation that all cells go through after they are discovered. This
% sets some key properties in the class that are important for further
% analysis
%

function [dpsomas ] = prepare_soma( dpsoma )

        flag = 0;
        
        MIN_CLUMP_AREA = Config.get_config('MIN_CLUMP_AREA');
        MAX_CLUMP_AREA = Config.get_config('MAX_CLUMP_AREA');

        dpsoma = soma_bound_box(dpsoma); %adds box properties to the soma       
        
        dpsoma.cnnBox = Tools.get_block(dpsoma.referenceDPImage.image,round(dpsoma.centroid));
        if (dpsoma.area > MAX_CLUMP_AREA)
            dpsomas = {};
            return
        end
               
        % now try to resolve clumps
        if (dpsoma.isClump == 0)
            if(dpsoma.area > MIN_CLUMP_AREA)
                %fprintf('CLUMP RESOLVE\n');
                [flag,somas] = resolve_clump(dpsoma); 
                
                if flag == 0
                   dpsomas = {};
                   return
                end
            end
        end
        
        if (flag == 1)
            dpsomas = somas;
        else
            dpsomas = {dpsoma}; 
        end
end

