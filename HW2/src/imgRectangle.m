function imgOut = imgRectangle(image, alpha)
	imgOut = image;

	% get initial sub image
	sub_region = getSubRegion(imgOut, alpha);

	% while loop until filling the image
	while(sub_region{5} > 0)
		rl = sub_region{1};
		cl = sub_region{2};
		rr = sub_region{3};
		cr = sub_region{4};  
		h = rr - rl + 1;
		w = cr - cl + 1;
		sub_image = imcrop(imgOut, [cl, rl, w-1, h-1]);
		sub_alpha = imcrop(alpha, [cl, rl, w-1, h-1]);

		% find seam in sub image
		tmp_img = double(sub_image)/255;
		orient = sub_region{6};
		E = findEnergy(tmp_img, sub_alpha);
		S = findSeamImg(E, orient);
		SeamVector = findSeam(S, orient);

%         figure(1)
%         imshow(E)
%         figure(2)
%         imshow(S, [min(S(:)) max(S(:))])
%         SeamedImg=SeamPlot(E,SeamVector,orient);
%         imshow(SeamedImg,[min(SeamedImg(:)) max(SeamedImg(:))]);
        
		% apply shift based on seam to the sub image
		shifted_img = sub_image;
		shifted_alpha = sub_alpha;
		if (strcmp(orient, 'up'))
			for c = 1:w
				shifted_img(1:SeamVector(1,c)-1, c, :) = sub_image(2:SeamVector(1,c), c, :);
				shifted_alpha(1:SeamVector(1,c)-1, c) = sub_alpha(2:SeamVector(1,c), c);
			end
		elseif (strcmp(orient, 'down'))
			for c = 1:w
				shifted_img(SeamVector(1,c)+1:h, c, :) = sub_image(SeamVector(1,c):h-1, c, :);
				shifted_alpha(SeamVector(1,c)+1:h, c) = sub_alpha(SeamVector(1,c):h-1, c);
			end
		elseif (strcmp(orient, 'left'))
			for r = 1:h
				shifted_img(r, 1:SeamVector(r,1)-1, :) = sub_image(r, 2:SeamVector(r,1), :);
				shifted_alpha(r, 1:SeamVector(r,1)-1) = sub_alpha(r, 2:SeamVector(r,1));
			end
		else
			for r = 1:h
				shifted_img(r, SeamVector(r,1)+1:w, :) = sub_image(r, SeamVector(r,1):w-1, :);
				shifted_alpha(r, SeamVector(r,1)+1:w) = sub_alpha(r, SeamVector(r,1):w-1);
			end
		end
			

		% cp sub image to the original image
		imgOut(rl:rr, cl:cr, :) = shifted_img(:,:,:);
		alpha(rl:rr, cl:cr) = shifted_alpha(:,:);

		% update the segments
		sub_region = getSubRegion(imgOut, alpha);
        imshow(imgOut);
	end
end

% return the region of the sub_region
% sub_region = [rl, cl, rr, cr, len, orientation(up, right, left, down)]
function sub_region = getSubRegion(image, alpha)
	[row, col, ch] = size(image);
	sub_region = {};
	sub_region{5} = 0;

	% up border
	for c = 1:col
		len = 0;
		
		tmp = c;
		while(tmp <= col && alpha(1, tmp) == 0)
			tmp = tmp + 1;
		end
		len = tmp - c;

		if(len > sub_region{5})
			sub_region{1} = 1;
			sub_region{2} = c;
			sub_region{3} = row;
			sub_region{4} = tmp-1;
			sub_region{5} = len;
			sub_region{6} = 'up';
		end
		c = tmp;
	end

	% down border
	for c = 1:col		
		len = 0;
		
		tmp = c;
		while(tmp <= col && alpha(row, tmp) == 0)
			tmp = tmp + 1;
		end
		len = tmp - c;

		if(len > sub_region{5})
			sub_region{1} = 1;
			sub_region{2} = c;
			sub_region{3} = row;
			sub_region{4} = tmp-1;
			sub_region{5} = len;
			sub_region{6} = 'down';
		end
		c = tmp;
	end

	% check left
	for r = 1:row
		len = 0;
		
		tmp = r;
		while(tmp <= row && alpha(tmp, 1) == 0)
			tmp = tmp + 1;
		end
		len = tmp - r;

		if(len > sub_region{5})
			sub_region{1} = r;
			sub_region{2} = 1;
			sub_region{3} = tmp-1;
			sub_region{4} = col;
			sub_region{5} = len;
			sub_region{6} = 'left';
		end
		r = tmp;
	end

	% check right border
	for r = 1:row 
		len = 0;
		
		tmp = r;
		while(tmp <= row && alpha(tmp, col) == 0)
			tmp = tmp + 1;
		end
		len = tmp - r;

		if(len > sub_region{5})
			sub_region{1} = r;
			sub_region{2} = 1;
			sub_region{3} = tmp-1;
			sub_region{4} = col;
			sub_region{5} = len;
			sub_region{6} = 'right';
		end
		r = tmp;
	end
end