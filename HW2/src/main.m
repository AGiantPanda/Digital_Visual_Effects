close all;
clear all;
%Parameters for finding corners (HarrisTop)
SIGMA = 1.5;  K =0.04; LOCAL_RADIUS= 20; THRESHOLD = 50;
%CORNER_NUM = 400;
MARGIN = 25;

%Parameters for matching (knnMatch)
MATCH_NUM = 40;

% Get input images from input directory, and store them in dataset{}
InputDir = 'C:\Users\panda\Desktop\VFXHW2\2pic\';
files = dir(InputDir);
files = files(3:end);

N = numel(files);
dataset = {};
cnt = 1;
for i = 1:N
    if files(i).name(1) ~= '.'
    I = imread(strcat(InputDir,files(i).name));
    %I = imrotate(imresize(I, [480, 640]), 270);
    dataset{cnt} = I;
    % imshow(I);
    % drawnow;
    cnt = cnt + 1;
    end
end

CORNER_NUM = round(size(dataset{1},1)*size(dataset{1},2)/1000)*2;
LOCAL_RADIUS= round(min(size(dataset{1},1),size(dataset{1},2))/CORNER_NUM);

CornerDescription = {};
AlphaInfo = {};
for i=1:N
	% Get grayscale image
	disp(['For image ',num2str(i),', finding feature points......'])
	Y = rgb2ycbcr(dataset{i});
	Y = Y(:,:,1);
	%%Harris Corner Detector - Top 
	Corner(i) = HarrisTop(Y, SIGMA, K, THRESHOLD, CORNER_NUM, LOCAL_RADIUS, MARGIN);
	
	%%Harris Corner Detector - NMS 
        CornerNMS(i) = HarrisTop(Y, SIGMA, K, THRESHOLD, CORNER_NUM, LOCAL_RADIUS, MARGIN,1);
	
	featureSize = size(CornerNMS(i).c,1);
	CornerDescription{i} = FeatureDescriptor(Y,Corner(i));
	[warpedImg, CornerDescription{i}, AlphaInfo{i}] = imgWarp(dataset{i}, CornerDescription{i}, 820);

	% fill the black region in the warped image
	[tmp_r, tmp_c, ch] = size(warpedImg);
	dataset{i} = imresize(dataset{i}, [tmp_r, tmp_c]);
	for r = 1:tmp_r
		for c = 1:tmp_c
			if(AlphaInfo{i}(r, c) > 0)
				dataset{i}(r, c, :) = warpedImg(r, c, :);
			end
		end
	end
	% figure, imagesc(dataset{i}), axis image, colormap(gray), hold on
	% plot(Corner(i).c,Corner(i).r ,'ys'), title('corners detected');
end

PointMatched = {};
PointDistance = {};
for i=1:(N-1)
    disp(['Matching Image ',num2str(i),'and Image ', num2str(i+1), '......'])
	[ PointMatched{i} PointDistance{i}] = knnMatch(CornerDescription{i},CornerDescription{i+1},MATCH_NUM);
	% figure, imagesc(dataset{i}), axis image, colormap(gray), hold on
	% plot(Corner(i).c,Corner(i).r ,'ys'), plot(PointMatched{i}(:,2),PointMatched{i}(:,1) ,'rs'),title('corners detected');
	% figure, imagesc(dataset{i+1}), axis image, colormap(gray), hold on
	% plot(Corner(i+1).c,Corner(i+1).r ,'ys'), plot(PointMatched{i}(:,4),PointMatched{i}(:,3) ,'rs'),title('corners detected');
end

pano = imgStitch(dataset, PointMatched, AlphaInfo);
imwrite(pano, './out.jpg');
