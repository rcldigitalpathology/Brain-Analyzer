% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Helper function to get the average soma intensity

function [av] = get_av_soma_intensity(soma)
    intensities = 0;
    gray = rgb2gray(soma.subImage);
    for i=1:size(soma.pixelList,1)
        
        A = soma.pixelList(i,:);
        
        A = round(A-soma.TL)+[1,1]; %adjust for soma image

        intensities = [intensities double(gray(A(2),A(1)))];
    end
    av = prctile(intensities,15); %gets lower nth percentile intensity
end

