clear all;
%Parameters
sigma = 1.5;  k =0.04; localRadius= 20;

sigma_smooth = 1; threshold = 50;

keypointNum = 400;
%mode = 'strongest';

margin = 50;


InputDir = 'csie/';
files = dir(InputDir);
files = files(4:end);

N = numel(files);
dataset = {};
cnt = 1;
for i = 1:N
    if files(i).name(1) ~= '.'
    I = imread(strcat(InputDir,files(i).name));
    %I = imrotate(imresize(I, [480, 640]), 90);
    dataset{cnt} = I;
    imshow(I);
    drawnow;
    cnt = cnt + 1;
    end
end

% Get grayscale image
Y = rgb2ycbcr(dataset{1});
Y = Y(:,:,1);

tic
Corner_1 = HarrisTop(Y, sigma, k, threshold, keypointNum, localRadius, margin);%, mode);
figure, imagesc(dataset{1}), axis image, colormap(gray), hold on
plot(Corner_1.c,Corner_1.r ,'ys'), title('corners detected');

CornerDescription_1 = FeatureDescriptor(Y,Corner_1);


% Get grayscale image
Y = rgb2ycbcr(dataset{2});
Y = Y(:,:,1);

tic
Corner_2 = HarrisTop(Y, sigma, k, threshold, keypointNum, localRadius, margin);%, mode);
figure, imagesc(dataset{2}), axis image, colormap(gray), hold on
plot(Corner_2.c,Corner_2.r ,'ys'), title('corners detected');

CornerDescription_2 = FeatureDescriptor(Y,Corner_2);

[ point_matched point_distance] = knnMatch(CornerDescription_1,CornerDescription_2,10);
%[matched point in 1_r , matched point in 1_c , matched point in 2_r, matched point in 2_c]

%[ point_matched point_distance] = knnMatch(HarrisDiscriptor_1,HarrisDiscriptor_2,10);

figure, imagesc(dataset{1}), axis image, colormap(gray), hold on
plot(Corner_1.c,Corner_1.r ,'ys'), plot(point_matched(:,2),point_matched(:,1) ,'rs'),title('corners detected');
figure, imagesc(dataset{2}), axis image, colormap(gray), hold on
plot(Corner_2.c,Corner_2.r ,'ys'), plot(point_matched(:,4),point_matched(:,3) ,'rs'),title('corners detected');

%figure, imagesc(dataset{1}), axis image, colormap(gray), hold on
%plot(Corner_1.c,Corner_1.r ,'ys'), plot(point_matched(:,2),point_matched(:,1) ,'ys'),title('corners detected');

%Corner = Harris_Laplace_fn(I,threshold);
%Corner = Harris(I,sigma,k,threshold,localRadius,margin);
%Corner = HarrisNMS(I,sigma,k,threshold,localRadius,keypointNum,margin);
toc
