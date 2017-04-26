% Adaptive Non-Maximal Suppression
% INPUT:    img     double (height)x(width) array (grayscale image) with
%                   values in the range 0-255
%           x       nx1 vector representing the column coordinates of corners
%           y       nx1 vector representing the row coordinates of corners
% OUTPUT:   descs   64xn matrix of double values with column i being the 64
%                   dimensional descriptor computed at location (xi, yi) in im
function [descs] = FeatureDescriptor(img, Corner)
DESC_SIZE = 40; % desc size must be divided by 8
SIGMA = 1;
H = size(img, 1);
W = size(img, 2);
N = numel(Corner.c);
% convert 2d to 1d  idx = (x-1)*H+y
get_idx = @(x, y) (x-1)*H+y;
descs = zeros(64, N);

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
	% feat = imresize(feat, [8, 8]);
	feat = feat(1:DESC_SIZE/8:DESC_SIZE, 1:DESC_SIZE/8:DESC_SIZE);
	feat = double(feat);
	feat = (feat(:) - mean(feat(:)))/std(feat(:));
	descs(:, i) = feat;
end
descs = descs';
descs(:,65) = Corner.r;
descs(:,66) = Corner.c;
end