% INPUT:    img     Gray scale image
%	Corner 	corners found by HarrisTop.m
% OUTPUT:   description   (64+2)xn matrix of double values and the last 2xn are the positions of the corners
function [description] = FeatureDescriptor(img, Corner)
% parameters
DESC_SIZE = 40; % desc size must be divided by 8
SIGMA = 1;

H = size(img, 1);
W = size(img, 2);
N = numel(Corner.c);

% convert 2d to 1d  idx = (x-1)*H+y
get_idx = @(x, y) (x-1)*H+y;
description = zeros(64, N);

for i = 1:N
	[xx, yy] = meshgrid(Corner.c(i)-DESC_SIZE/2+1:Corner.c(i)+DESC_SIZE/2, Corner.r(i)-DESC_SIZE/2+1:Corner.r(i)+DESC_SIZE/2);
	xx(xx<=0) = 1;
	xx(xx>W) = W;
	yy(yy<=0) = 1;
	yy(yy>H) = H;

	idx  = get_idx(xx(:), yy(:));
	feat = img(idx);
	feat = reshape(feat, [DESC_SIZE, DESC_SIZE]);
	G = fspecial('gaussian', fix(SIGMA*6), SIGMA);
	Sx2 = imfilter(feat,G, 'replicate', 'conv');
	feat = feat(1:DESC_SIZE/8:DESC_SIZE, 1:DESC_SIZE/8:DESC_SIZE);
	feat = double(feat);
	feat = (feat(:) - mean(feat(:)))/std(feat(:));
	description(:, i) = feat;
end
description = description';

% Record the positions for corners
description(:,65) = Corner.r;
description(:,66) = Corner.c;
end
