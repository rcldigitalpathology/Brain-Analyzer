%%
% Author: Tegy J. Vadakkan
% Date: 09/08/2009
% Gliding box lacunarity algorithm based on the ideas presented in the
% paper by Tolle et al., Physica D, 237, 306-315, 2008
% input is the binary file with 0's and 1's. 0's represent the holes or the
% lacunae
% the output M gives the lacunarity at various box lengths (edge sizes are multiples of 2)

%%
function M = lacunarity_glbox(im)
    a = im;
    [rows, cols] = size(a);
    a = 1 - a;
    %%
    n = 2;
    while(n <= rows)
    nn = n-1;
    rnn = rows - nn;
    index = uint8(log2(n));
    count(index)= power(rnn,2);
    sigma(index) = 0.0;
    sigma2(index) = 0.0;
    for i=1:rnn
        for j=1:rnn
            sums = sum(sum(a(i:i+nn,j:j+nn)));
            sigma(index) = sigma(index) + sums;
            sigma2(index) = sigma2(index) + power(sums,2);
        end
    end
    n = n * 2;
    end
    %%
    for i=1:index
        M(i,1)= (count(i)*sigma2(i))/(power(sigma(i),2));
    end
end