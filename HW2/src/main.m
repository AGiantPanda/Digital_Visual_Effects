close all;
clear all;
%Parameters for finding corners (HarrisTop)
SIGMA = 1.5;  K =0.04; LOCAL_RADIUS= 20; THRESHOLD = 50;
CORNER_NUM = 400;MARGIN = 50;

%Parameters for matching (knnMatch)
MATCH_NUM = 20;

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

CornerDescription = {};
for i=1:N
	% Get grayscale image
	disp(['For image ',num2str(i),', finding feature points......'])
	Y = rgb2ycbcr(dataset{i});
	Y = Y(:,:,1);
	Corner(i) = HarrisTop(Y, SIGMA, K, THRESHOLD, CORNER_NUM, LOCAL_RADIUS, MARGIN);
	featureSize = size(Corner(i).c,1);
	CornerDescription{i} = FeatureDescriptor(Y,Corner(i));
	figure, imagesc(dataset{i}), axis image, colormap(gray), hold on
	plot(Corner(i).c,Corner(i).r ,'ys'), title('corners detected');
end

PointMatched = {};
PointDistance = {};
for i=1:(N-1)
    disp(['Matching Image ',num2str(i),'and Image ', num2str(i+1), '......'])
	[ PointMatched{i} PointDistance{i}] = knnMatch(CornerDescription{i},CornerDescription{i+1},MATCH_NUM);
	figure, imagesc(dataset{i}), axis image, colormap(gray), hold on
	plot(Corner(i).c,Corner(i).r ,'ys'), plot(PointMatched{i}(:,2),PointMatched{i}(:,1) ,'rs'),title('corners detected');
	figure, imagesc(dataset{i+1}), axis image, colormap(gray), hold on
	plot(Corner(i+1).c,Corner(i+1).r ,'ys'), plot(PointMatched{i}(:,4),PointMatched{i}(:,3) ,'rs'),title('corners detected');
end
