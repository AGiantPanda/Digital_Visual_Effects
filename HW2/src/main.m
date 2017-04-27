clear all;
%Parameters
sigma = 1.5;  k =0.04; localRadius= 20; threshold = 50;

keypointNum = 400;

margin = 50;

% Get input images from input directory, and store them in dataset{}
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

CornerDescription = {}
for i=1:N
	% Get grayscale image
	disp(['For image',num2str(i),':'])
	Y = rgb2ycbcr(dataset{i});
	Y = Y(:,:,1);
	Corner(i) = HarrisTop(Y, sigma, k, threshold, keypointNum, localRadius, margin);
	featureSize = size(Corner(i).c,1);
	CornerDescription{i} = FeatureDescriptor(Y,Corner(i));
	figure, imagesc(dataset{i}), axis image, colormap(gray), hold on
	plot(Corner(i).c,Corner(i).r ,'ys'), title('corners detected');
end


[ point_matched point_distance] = knnMatch(CornerDescription{1},CornerDescription{2},10);
%[matched point in 1_r , matched point in 1_c , matched point in 2_r, matched point in 2_c]

%[ point_matched point_distance] = knnMatch(HarrisDiscriptor_1,HarrisDiscriptor_2,10);

figure, imagesc(dataset{1}), axis image, colormap(gray), hold on
plot(Corner(1).c,Corner(1).r ,'ys'), plot(point_matched(:,2),point_matched(:,1) ,'rs'),title('corners detected');
figure, imagesc(dataset{2}), axis image, colormap(gray), hold on
plot(Corner(2).c,Corner(2).r ,'ys'), plot(point_matched(:,4),point_matched(:,3) ,'rs'),title('corners detected');

%figure, imagesc(dataset{1}), axis image, colormap(gray), hold on
%plot(Corner_1.c,Corner_1.r ,'ys'), plot(point_matched(:,2),point_matched(:,1) ,'ys'),title('corners detected');

%Corner = Harris_Laplace_fn(I,threshold);
%Corner = Harris(I,sigma,k,threshold,localRadius,margin);
%Corner = HarrisNMS(I,sigma,k,threshold,localRadius,keypointNum,margin);
