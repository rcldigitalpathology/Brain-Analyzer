% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Helper function to normalize the intensity distribution of an image.

function [im_out] = normalize_image(im_in)        
    gray = rgb2gray(im_in);
    mid = 255/2;

    temp = double(gray);
    temp = temp-mean(temp(:))+mid;

    bot = temp(temp<mid);
    top = temp(temp>=mid);

    bot = (bot-mid)*(mid/(mid - min(bot)))+mid;
    top = (top-mid)*(mid/(max(top) - mid))+mid;

    new = temp;
    new(new<mid) = bot;
    new(new>=mid) = top;

    final = (new-mean2(new))/std2(new)*30+mean2(new);
    final = (final-mean2(final))+mid;
    
    im_out = uint8(final);
end

