function [BlkFeat] = ExtractBlkFeat(BlkRgb,ImgScale)
% University of British Columbia, Vancouver, 2017
%   Dr. Guy Nir
%   Shahriar Noroozi Zadeh
%   Amir Refaee
%   Lap-Tak Chu

if (nargin<4)
    ImgScale = 1;
end
%Extracting Different Colour intensities===================================  
R = BlkRgb(:,:,1);
G = BlkRgb(:,:,2);
B = BlkRgb(:,:,3);
%==========================================================================

%Blurring==================================================================
sigma=15;
R = imgaussfilt(R,sigma);
G = imgaussfilt(G,sigma);
B = imgaussfilt(B,sigma);
% BlkRgb=rgb2gray(BlkRgb);
% test=medfilt2(BlkRgb,[15 15]);
% test2=imgaussfilt(BlkRgb,sigma);
%==========================================================================

%Intensity_Stats===========================================================
avg_R=mean2(R);
avg_G=mean2(G);
avg_B=mean2(B);
std_R=std2(R);
std_B=std2(B);
std_G=std2(G);

% avg_R_b=mean2(R_b);
% avg_G_b=mean2(G_b);
% avg_B_b=mean2(B_b);
% std_R_b=std2(R_b);
% std_B_b=std2(B_b);
% std_G_b=std2(G_b);
%==========================================================================

%Normalizing===============================================================
% R=double(R);
% G=double(G);
% B=double(B);
% R_N=R(:,:)./sqrt(R(:,:).^2+G(:,:).^2+B(:,:).^2);
% G_N=G(:,:)./sqrt(R(:,:).^2+G(:,:).^2+B(:,:).^2);
% B_N= B(:,:)./sqrt(R(:,:).^2+G(:,:).^2+B(:,:).^2);
% 
% norm(:,:,1) = R_N(:,:);
% norm(:,:,2) = G_N(:,:);
% norm(:,:,3) = B_N(:,:);
%==========================================================================

%Kmeans Clustering=========================================================
% cform = makecform('srgb2lab');
% lab_Blk= applycform(kill, cform);
% ab = double(lab_Blk(:,:,2:3));
% nrows=size(ab,1);
% ncols=size(ab,2);
% ab=reshape(ab,nrows*ncols,2);
% 
% nColors=3;
% [cluster_idx, cluster_center]=kmeans(ab,nColors,'distance','sqEuclidean','Replicates',3);
% pixel_labels = reshape(cluster_idx,nrows,ncols);
%==========================================================================

%Hough Transform===========================================================
% I=rgb2gray(BlkRgb);
% [~, threshold]=edge(I, 'sobel');
% fudgeFactor=0.5;
% BWs = edge(I, 'sobel', threshold*fudgeFactor);
%==========================================================================
%Seeing different colour intensities=======================================
% a = zeros(size(BlkRgb, 1), size(BlkRgb, 2));
% just_red = cat(3, R, a, a);
% just_green = cat(3, a, G, a);
% just_blue = cat(3, a, a, B);
%==========================================================================


%Displaying the Blocks for Analysis========================================
% figure
% subplot(2,2,1);
% imshow(test)
% subplot(2,2,2);
% imshow(test2)
% subplot(2,2,3);
% imshow(BlkRgb)
% pause;
%==========================================================================
[counts_r,binLocations_r] = imhist(R,10);
[counts_g,binLocations_g] = imhist(G,10);
[counts_b,binLocations_b] = imhist(B,10);


std_cr=std(counts_r);
std_cg=std(counts_g);
std_cb=std(counts_b);


%TODO AVERAGE THESE
% [Gxr,Gyr] = imgradientxy(R_b);
% [Gxg,Gyg] = imgradientxy(G_b);
% [Gxb,Gyb] = imgradientxy(B_b);

grayImg = rgb2gray(BlkRgb);

% Divide patch into 4 blocks and take Discrete Cosine Transform of it
D = cell(4);
for i = 1:4
    for j = 1:4
        D{i,j} = dct(im2single(grayImg((i-1)*end/4+1 : i*end/4, ...
                                       (j-1)*end/4+1 : j*end/4)));
    end
end

f1 = D{1,1};
f2 = abs(D{2,1});
f3 = abs(D{1,2});

f4 = 0;
for i = 3:4
    for j = 1:2
        f4 = f4+abs(D{i,j})/4;
    end
end

f5 = 0;
for i = 1:2
    for j = 3:4
        f5 = f5+abs(D{i,j})/4;
    end
end

f6 = 0;
for i = 3:4
    for j = 3:4
        f6 = f6+abs(D{i,j})/4;
    end
end

mean_f1 = mean2(f1);
mean_f2 = mean2(f2);
mean_f3 = mean2(f3);
mean_f4 = mean2(f4);
mean_f5 = mean2(f5);
mean_f6 = mean2(f6);

std_f1 = std2(f1);
std_f2 = std2(f2);
std_f3 = std2(f3);
std_f4 = std2(f4);
std_f5 = std2(f5);
std_f6 = std2(f6);

% I2 = imgaussfilt(grayImg,20);
% [Gmag,Gdir] = imgradient(I2);
% 
% % for more than 40 of pixels being slide
% if length(I2(I2>240)) > 0.4*length(I2(:))
%     f7a = 0;
%     f7b = 0;
% else
%     f7a = 10*mean2(Gmag);
%     f7b = 10*mean2(Gdir);
% end


BlkFeat = [...f7a, f7b, ...
           mean_f1, std_f1, mean_f2, std_f2, mean_f3, std_f3, ...
           mean_f4, std_f4, mean_f5, std_f5, mean_f6, std_f6, ...
           avg_R  , avg_G , avg_B  , std_R , std_B  , std_G , ...
           std_cr , std_cg, std_cb , ...
           counts_r(:)', counts_g(:)', counts_b(:)'];

%BlkFeat=[f1(:)',f2(:)',f3(:)',f4(:)',f5(:)',f6(:)',avg_R,avg_G,avg_B,std_R,std_B,std_G];
%BlkFeat=[avg_R,avg_G,avg_B,std_R,std_B,std_G,std_cr,std_cg,std_cb,counts_r(:)',counts_g(:)',counts_b(:)'];
%feat{2} = 0; % put your feature extraction algorithm here...

%BlkFeat = [feat(:)];