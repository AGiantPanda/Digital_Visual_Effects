function SeamImg=findSeamImg(x, orient)
% FINDSEAMIMG finds the seam map from which the optimal (vertical running) 
% seam can be calculated. Input is gradient image found from findEnergy.m.
%
% The indexing can be interpreted as in this example image:
%   [(i-1,j-1)  (i-1,j)  (i-1,j+1)]
%   [(i,j-1)    (i,j)    (i,j+1)  ]
%   [(i+1,j-1)  (i+1,j)  (i+1,j+1)]
%
% Author: Danny Luong
%         http://danluong.com
%
% Last updated: 12/20/07


[rows cols]=size(x);

SeamImg=zeros(rows,cols);
SeamImg(1,:)=x(1,:);

if(strcmp(orient, 'left') || strcmp(orient, 'right'))
	for i=2:rows
	    for j=1:cols
	        if j-1<1
	            SeamImg(i,j)= x(i,j)+min([SeamImg(i-1,j),SeamImg(i-1,j+1)]);
	        elseif j+1>cols
	            SeamImg(i,j)= x(i,j)+min([SeamImg(i-1,j-1),SeamImg(i-1,j)]);
	        else
	            SeamImg(i,j)= x(i,j)+min([SeamImg(i-1,j-1),SeamImg(i-1,j),SeamImg(i-1,j+1)]);
	        end
	    end
	end
else
	for j=2:cols
		for i=1:rows
			if i-1<1
				SeamImg(i,j)= x(i,j)+min([SeamImg(i,j-1),SeamImg(i+1,j-1)]);
			elseif i+1>rows
				SeamImg(i,j)= x(i,j)+min([SeamImg(i-1,j-1),SeamImg(i,j-1)]);
			else
				SeamImg(i,j)= x(i,j)+min([SeamImg(i-1,j-1),SeamImg(i,j-1),SeamImg(i+1,j-1)]);
			end
		end
	end
end
				