%INPUT:
% img_b: background (double)
% img_f: foreground (double)


function [ Y ] = poissonBlend_two(img_b, img_f, region, up)

	img_bF = imGradFeature(img_b);
	img_fF = imGradFeature(img_f);


	w = region(1);
	h = region(2);
	[ROW, COL, CHANNEL] = size(img_b);
	NEW_ROW = h;
	NEW_COL = 2*COL - w;
	img_blended = zeros(NEW_ROW, NEW_COL, CHANNEL,5);


	if (up==0)
	  Y_b = ROW - h +1;
	  img_blended(:,1:end-(COL-w),:) = img_bF(Y_b:end,:,:);
	  img_blended(:,COL-w+1:end,:) = img_fF(1:h,:,:);
	else
	  Y_f = ROW - h +1;
	  img_blended(:,1:end-(COL-w),:) = img_bF(1:h,:,:);
	  img_blended(:,COL-w+1:end,:) = img_fF(Y_f:end,:,:);
	 end
	

	X = img_blended(:,:,:,1);

	param = buildModPoissonParam( size(img_blended) );

	Y = modPoisson( img_blended, param);
	imwrite(uint8(X),'X.png');
	imwrite(uint8(Y),'Y.png');

end
