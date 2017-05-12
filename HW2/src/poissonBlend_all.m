%INPUT:
% imgs: all images (double)
% regions: [region_1_w region_2_w ...		(col)
%			region_1_h region_2_h ....]		(row)	
% up : [1 0 1 0 1] 


function [ img_blended ] = poissonBlend_all(imgs, offsets)

	imgNum = length(imgs);
	for i=1:imgNum
		gradFeat{i} = imGradFeature(imgs{i});
    end

	%PASTING
	[ROW, COL, CHANNEL] = size(imgs{1});


	for p = 2:imgNum-1
		offsets(p,:) = offsets(p-1,:) + offsets(p,:);
    end
	min_r = 0;
	max_r = 0;
	min_c = COL;
	max_c = 0;
    for p = 1:imgNum-1
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
	imgPaste = zeros(ROW+min_r+max_r, COL+max_c, CHANNEL, 5);
	imgPaste(min_r+1:min_r+ROW, 1:COL, :,:) = gradFeat{1}(:,:,:,:);
	for p = 1:imgNum-1
		for r = 1:ROW
			for c = 1:COL
					imgPaste(min_r+offsets(p, 1)+r, offsets(p,2)+c, :,:) = gradFeat{p+1}(r,c,:,:);
			
			end
		end
    end



    %--------
	param = buildModPoissonParam( size(imgPaste) );

	img_blended = modPoisson( imgPaste, param);

	imshow(uint8(img_blended))

end