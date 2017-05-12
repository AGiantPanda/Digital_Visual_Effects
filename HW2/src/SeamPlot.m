function x=SeamPlot(x,SeamVector,orient)
% SEAMPLOT takes as input an image and the SeamVector array and produces
% an image with the seam line superimposed upon the input image, x, for
% display purposes.
%
% Author: Danny Luong
%         http://danluong.com
%
% Last updated: 12/20/07


value=1.5*max(x(:));
if(strcmp(orient, 'left') || strcmp(orient, 'right'))
	for i=1:size(SeamVector,1)
	    x(i,SeamVector(i))=value;
	end
else
	for j=1:size(SeamVector,2)
	    x(SeamVector(j),j)=value;
	end
end