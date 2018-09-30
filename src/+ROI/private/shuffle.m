function Y = shuffle(X)
% randomize the order of the elements of a vector or matrix X
% Guy Nir, University of British Columbia, Vancouver, 2017

n = length(X(:));
rand_indx = randperm(n);
Y = zeros(size(X));
Y(rand_indx) = X;
return