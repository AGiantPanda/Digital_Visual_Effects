% use cylindrical coordination
function imgOut = imgWarp(img, f)
	[row, col, channel] = size(img);
	col_warped = 2 * ceil(f * atan(col / 2 / f));
	imgOut = zeros(row, col_warped, channel, 'uint8');
	for r = 1:row
		for c = 1:col
			r_tmp = row / 2 - r;
			c_tmp = c - col / 2;
			cw = floor(f * atan(c_tmp / f));
			rw = floor(f * (r_tmp / sqrt(c_tmp ^ 2 + f ^ 2)));
			cw = col_warped / 2 + cw;
			rw = row / 2 - rw;
			imgOut(rw, cw, :) = img(r, c, :);
		end
	end

	imshow(imgOut);
end