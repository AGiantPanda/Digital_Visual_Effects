% use cylindrical coordination
function [imgOut, descriptor, alpha] = imgWarp(img, description, f)
	[row, col, channel] = size(img);
	col_warped = 2 * ceil(f * atan(col / 2 / f));
	imgOut = zeros(row, col_warped, channel, 'uint8');
	alpha = zeros(row, col_warped, 'uint8');
	for r = 1:row
		for c = 1:col
			r_tmp = row / 2 - r;
			c_tmp = c - col / 2;
			cw = floor(f * atan(c_tmp / f));
			rw = floor(f * (r_tmp / sqrt(c_tmp ^ 2 + f ^ 2)));
			cw = col_warped / 2 + cw;
			rw = row / 2 - rw;
			imgOut(rw, cw, :) = img(r, c, :);
			alpha(rw, cw) = 255;
		end
	end
	descriptor = description;
	num = size(description, 1);
	for i = 1:num
		r_tmp = row/2 - description(i, 65);
		c_tmp = description(i, 66) - col/2;
		cw = floor(f * atan(c_tmp / f));
		rw = floor(f * (r_tmp / sqrt(c_tmp ^ 2 + f ^ 2)));
		cw = col_warped / 2 + cw;
		rw = row / 2 - rw;
		descriptor(i, 65) = rw;
		descriptor(i, 66) = cw;
	end
	imgOut = imcrop(imgOut, [1, 1, col_warped-2, row]); % gonna fix this later
	alpha = imcrop(alpha, [1, 1, col_warped-2, row]); % gonna fix this later
	% imshow(imgOut);
end
