function imgOut = panoStitch(images, matches)
	K = 35;
	N = 3;
	num = size(matches, 1);
	[row, col, channel] = size(images(:,:,:,1));

	% 1. Warp image to cylindrical coordinate
	% 2. Compute pairwise alignments
	% only consider r and c offsets for now
	offsets = zeros(1, 2);
	inliers = 0;
	for k = 1:K
		% choose n samples
		n = randperm(num, N);
		r_off = 0;
		c_off = 0;
		ins_tmp = 0;

		% cal offsets and its total inliers
		for i = 1:N
			r_off = r_off + matches(n(i), 1) - matches(n(i), 3);
			c_off = c_off + matches(n(i), 2) - matches(n(i), 4);
		end
		r_off = floor(r_off / 3);
		c_off = floor(c_off / 3);

		for i = 1:num
			if(abs(matches(i, 1) - matches(i, 3) - r_off) < 10 && abs(matches(i, 2) - matches(i, 4) - c_off) < 10)
				ins_tmp = ins_tmp + 1;
			end
		end

		% compare its inliers
		if(ins_tmp > inliers)
			inliers = ins_tmp;
			offsets(1) = r_off;
			offsets(2) = c_off;
		end
	end

	% stitch the images
	imgOut = zeros(row*3, col*3, channel, 'uint8');
	imgOut(row+1:row*2, col+1:col*2, :) = images(:,:,:,1);
	imgOut(row+1+offsets(1):row*2+offsets(1), col+1+offsets(2):col*2+offsets(2), :) = images(:,:,:,2);
	nr = row+1;
	nc = col+1;
	if(offsets(1) < 0)
		nr = nr+offsets(1);
	end
	if(offsets(2) < 0)
		nc = nc+offsets(2);
	end
	imgOut = imcrop(imgOut, [nc, nr, col + abs(offsets(2)), row + abs(offsets(1))]);
	imshow(imgOut);
	% 3. Fix up the end-to-end alignments
	
	% 4. Blending
	
	% 5. Crop
end