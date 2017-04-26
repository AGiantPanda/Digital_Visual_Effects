% Harris detector
function imgOut=featureDetect(img)
	% basic spec
	[row, col, channel] = size(img);
	img_gray = rgb2gray(img);
	img_gray = single(img_gray);
	sigma = 1;
	gaussian_N = 1;
	[xx, yy] = meshgrid(-gaussian_N:gaussian_N, -gaussian_N:gaussian_N);
	threshold = 100000000;
	k = 0.04;


	% 1. Compute x and y derivatives of image
	Gxy = exp(-(xx .^2 + yy .^ 2) / (2 * sigma * sigma));
	Gxy	= Gxy/sum(Gxy(:));
	Gx = xx .* Gxy;
	Gy = yy .* Gxy;

	I_x = conv2(img_gray, xx, 'same');
	I_y = conv2(img_gray, yy, 'same');
	
	% 2. Compute products of derivatives at every pixel
	I_x2 = I_x .* I_x;
	I_y2 = I_y .* I_y;
	I_xy = I_x .* I_y;

	% 3. Compute the sums of the products of derivatives at each pixel
	S_x2 = conv2(I_x2, Gxy, 'same');
	S_y2 = conv2(I_y2, Gxy, 'same');
	S_xy = conv2(I_xy, Gxy, 'same');

	% 4. Define the matrix at each pixel 
	% 5. Compute the response of the detector at each pixel
	% 6. Threshold on value of R; compute nonmax suppression
	imgOut = img;
	for r = 1:row-1
		for c = 1:col-1
			M = [S_x2(r, c), S_xy(r, c); S_xy(r, c), S_y2(r, c)];
			R = det(M) - k * (trace(M) ^ 2);

			% draw circles red
			if (R > threshold)
				imgOut(r, c, 1) = 255;
				imgOut(r, c, 2) = 0;
				imgOut(r, c, 3) = 0;
				% imgOut = insertShape(imgOut, 'circle', [r, c, 3]);
			end
		end
	end

	% Show the imgOut
	imshow(imgOut);

	% Compare with the built-in method
	% C = corner(img, 'Harris');
end