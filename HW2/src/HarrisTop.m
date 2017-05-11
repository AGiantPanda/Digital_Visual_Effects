function Corner = HarrisTop(I, sigma, k, threshold, keypointNum, localRadius, margin, NMS)
	%Matrix for computing vertical gradient dy
	%-----------------------------------------
	%prewitt
	%-----------------------------------------
	%[ 1  1  1 
	%  0  0  0 
	% -1 -1 -1 ]
	%-----------------------------------------
	dy = fspecial('prewitt'); 
	dx = dy';

	Ix = imfilter(double(I), dx, 'replicate', 'conv');
	Iy = imfilter(double(I), dy, 'replicate', 'conv');
	  
	Ix2 = Ix.^2;
	Iy2 = Iy.^2;
	Ixy = Ix.*Iy;

	G = fspecial('gaussian', fix(sigma*6), sigma);
	Sx2 = imfilter(Ix2,G, 'replicate', 'conv');
	Sy2 = imfilter(Iy2,G, 'replicate', 'conv');
	Sxy = imfilter(Ixy,G, 'replicate', 'conv');

	%----------------------------
	% Matrix M
	%----------------------------
	%[Sx2, Sxy
	% Sxy, Sy2]
	%----------------------------
	disp('Computing R scores......')
	R = (Sx2.*Sy2-Sxy.*Sxy) - k*(Sx2+Sy2).^2;
    %imshow(R)
	%Find local maxima
	localSize = 2*localRadius+1;
	% Grey-scale dilate
	localMax = ordfilt2(R,localSize^2,ones(localSize)); 

	disp('Start finding corners!')

	R(find(R~=localMax))=0;
	[R_sort, Index] = sort(R(:),'descend');
	tempCorner.c = ceil(Index(1:keypointNum)./size(I,1));
    tempCorner.r = Index(1:keypointNum) - (tempCorner.c-1)*size(I,1);

	if(NMS==0)
		%TOP feature
		%cornerList [C R]

		% Remove some near-to-border corner points
		Index = find(tempCorner.r<(size(I,1)-margin)&tempCorner.r>margin&tempCorner.c<(size(I,2)-margin)&tempCorner.c>margin);	

		Corner.r = tempCorner.r(Index(:));
		Corner.c = tempCorner.c(Index(:));
	else
	% NMS
		FEATNUM = keypointNum/2;
		R_sort = R_sort(1:keypointNum);
		cornerList = NonMaximalSuppresion(tempCorner.r, tempCorner.c, R_sort, FEATNUM);
		cornerList = cornerList(1:FEATNUM,:);
        % Remove some near-to-border corner points
		
		Index = find(cornerList(:,2)<(size(I,1)-margin)&cornerList(:,2)>margin&cornerList(:,1)<(size(I,2)-margin)&cornerList(:,1)>margin);	
		Corner.r = cornerList(Index(:),2);
		Corner.c = cornerList(Index(:),1);
		
		%Corner.r = cornerList(:,2);
		%Corner.c = cornerList(:,1);
	end

	

end
