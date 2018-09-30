% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Finds the euclidian distance between two 2D points

function distance = calc_distance(p1, p2) 
    distance = sqrt((p1(1)-p2(1))^2+(p1(2)-p2(2))^2); 
end