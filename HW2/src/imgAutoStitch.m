% images: original (or warped) simgle images
% matches: NxN images corner points matches
% alphas: alpha channel of each images
function imgOut = imgAutoStitch(images, matches, alphas)
	[row, col, ch] = size(images{1});
	K = 1000; 							% run K times in total
	N = 2; 								% number of randomly chosen points
	num_pic = size(images, 2); 		% number of pictures

	% use RUNSAC to count inliers
	inliers = {};
	offsets = {};
	for p = 1:num_pic-1
		for q = p+1:num_pic
			inliers{p,q} = 0;
			offset = zeros(1,2);
			num_mat = size(matches{p,q}, 1);% number of matching points
			for k = 1:K
				% choose n samples
				n = randperm(num_mat, N);
				r_off = 0;
				c_off = 0;
				ins_tmp = 0;

				% cal offsets and its total inliers
				for i = 1:N
					r_off = r_off + matches{p,q}(n(i), 1) - matches{p,q}(n(i), 3);
					c_off = c_off + matches{p,q}(n(i), 2) - matches{p,q}(n(i), 4);
				end
				r_off = floor(r_off / N);
				c_off = floor(c_off / N);

				for i = 1:num_mat
					if(abs(matches{p,q}(i, 1) - matches{p,q}(i, 3) - r_off) < 10 && abs(matches{p,q}(i, 2) - matches{p,q}(i, 4) - c_off) < 10)
						ins_tmp = ins_tmp + 1;
					end
				end

				% compare its inliers
				if(ins_tmp > inliers{p,q})
					inliers{p,q} = ins_tmp;
					inliers{q,p} = ins_tmp;
					offset(1) = r_off;
					offset(2) = c_off;
				end
			end
			offsets{p,q} = offset;
			offsets{q,p} = -offset;
		end
	end

	% check if the offset and inliers are from the right image match
	for p = 1:num_pic-1
		for q = p+1:num_pic
			if(inliers{p,q} <= 0.8 * (5.9 + 0.22*size(matches{p,q},1)))
				inliers{p,q} = 0;
				inliers{q,p} = 0;
                offsets{p,q} = [0,0];
                offsets{q,p} = [0,0];
			end
		end
	end

	% stitch the offsets so that each offsets is based on image{1}
	off_bits = zeros(1, num_pic);
	off_bits(1) = 1;
    accu = [0, 0];
	[offsets, off_bits] = getOffsets(1, off_bits, offsets, inliers, accu);
	minr = 0;
	maxr = 0;
	minc = 0;
	maxc = 0;
		% for q = 2:num_pic
		% 	if(total_offsets{q}(1) < minr)
		% 		minr = total_offsets{q}(1);
		% 	end
		% 	if(total_offsets{q}(1) > maxr)
		% 		maxr = total_offsets{q}(1);
		% 	end
		% 	if(total_offsets{q}(2) < minc)
		% 		maxr = total_offsets{q}(2);
		% 	end
		% 	if(total_offsets{q}(2) > maxc)
		% 		maxr = total_offsets{q}(2);
		% 	end
		% end

	% stitch imgs from images{1}

	imshow(imgOut);
end

%% findOffset: function description
function [offsets, off_bits] = getOffsets(p, off_bits, offsets, inliers, accu)
    num_pic = size(offsets,2);
    off_b = ones(1, num_pic);
    if (off_bits == off_b)
        return;
    end
	for q = 1:num_pic
		if(off_bits(q) == 1)
			% already have q's offsets based on image{1}
			continue;
		end

		if(inliers{p, q} > 0)
			accu = accu + offsets{p,q};
			offsets{1, q} = accu;
			off_bits(q) = 1;
			[offsets, off_bits] = getOffsets(q, off_bits, offsets, inliers, accu);
		end
	end
end