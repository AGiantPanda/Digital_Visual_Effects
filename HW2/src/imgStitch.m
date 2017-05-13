function [imgOut, alpha] = imgStitch(images, matches, alphas)
	K = 1000; 							% run K times in total
	N = 2; 								% number of randomly chosen points
	num_pic = size(images, 2); 		% number of pictures
	num_mat = size(matches{1,1}, 1); 	% number of matching points

	% only consider r and c offsets for now
	offsets = zeros(num_pic-1, 2);
	for p = 1:num_pic-1
		inliers = 0;
		for k = 1:K
			% choose n samples
			n = randperm(num_mat, N);
			r_off = 0;
			c_off = 0;
			ins_tmp = 0;

			% cal offsets and its total inliers
			for i = 1:N
				r_off = r_off + matches{1,p}(n(i), 1) - matches{1,p}(n(i), 3);
				c_off = c_off + matches{1,p}(n(i), 2) - matches{1,p}(n(i), 4);
			end
			r_off = floor(r_off / N);
			c_off = floor(c_off / N);

			for i = 1:num_mat
				if(abs(matches{1,p}(i, 1) - matches{1,p}(i, 3) - r_off) < 10 && abs(matches{1,p}(i, 2) - matches{1,p}(i, 4) - c_off) < 10)
					ins_tmp = ins_tmp + 1;
				end
			end

			% compare its inliers
			if(ins_tmp > inliers)
				inliers = ins_tmp;
				offsets(p,1) = r_off;
				offsets(p,2) = c_off;
			end
		end
	end

	[row, col, channel] = size(images{1,1});
	
	% image blending
	for p = 2:num_pic-1

	end

	double_images = images;
	for p = 1:num_pic
		double_images{p} = double(double_images{p});
	end
	img_blended = poissonBlend_all(double_images, offsets);

	for p = 2:num_pic-1
		offsets(p,:) = offsets(p-1,:) + offsets(p,:);
    end
	min_r = 0;
	max_r = 0;
	min_c = col;
	max_c = 0;
    for p = 1:num_pic-1
        if(offsets(p, 1) < min_r)
            min_r = offsets(p, 1);
        end
        if(offsets(p, 1) > max_r)
            max_r = offsets(p, 1);
        end
    end
    min_r = abs(min_r);
    max_c = offsets(p,2);

	% stitch the images
	alpha = zeros(row+min_r+max_r, col+max_c, 'uint8');
	alpha(min_r+1:min_r+row, 1:col) = alphas{1}(:,:);
	for p = 1:num_pic-1
		for r = 1:row
			for c = 1:col
				if (alphas{1}(r, c) > 0)
					alpha(min_r+offsets(p, 1)+r, offsets(p,2)+c) = alphas{1,p+1}(r,c);
				end
				% should put image blend here
			end
		end
    end

% 	imshow(alpha);
    imgOut = uint8(img_blended);
end
