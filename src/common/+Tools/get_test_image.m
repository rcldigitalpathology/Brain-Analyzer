% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Simple helper function to grab one of our test images

function [ im ] = get_test_image(dpid)
	PATH = ['images'];
	im = DPImage([PATH '/' dpid '.tif']);
end