% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis

% Plots a collection of feature X vs. feature Y to visually determine what
% are good features.


tic;
[features,labels] = Morph.extract_data();
toc

labels(labels==2) = 1;
labels(labels==3) = 4;

d = size(features,2);
for i=1:d
    for j=1:d
        if i>j 
            subplot(d,d,sub2ind([d,d],i,j))
            gscatter(features(:,i),features(:,j),labels,'brgm','....');    
            grid on;
        end
    end
end
