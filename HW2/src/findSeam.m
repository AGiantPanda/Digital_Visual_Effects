function SeamVector=findSeam(x, orient);
% FINDSEAM returns a column vector of coordinates for the pixels to be
% removed (the seam), given the SeamImage resulting from findSeamImg.m
% each element "j" of SeamVector is the column number of the pixel in 
% row i to be removed.
%
% Author: Danny Luong
%         http://danluong.com
%
% Last updated: 12/20/07


[rows cols]=size(x);
if(strcmp(orient, 'left') || strcmp(orient, 'right'))
    for i=rows:-1:1
        if i==rows
            [value, j]=min(x(rows,:));  %finds min value of last row
        else    %accounts for boundary issues
            if SeamVector(i+1)==1
                Vector=[Inf x(i,SeamVector(i+1)) x(i,SeamVector(i+1)+1)];
            elseif SeamVector(i+1)==cols
                Vector=[x(i,SeamVector(i+1)-1) x(i,SeamVector(i+1)) Inf];
            else
                Vector=[x(i,SeamVector(i+1)-1) x(i,SeamVector(i+1)) x(i,SeamVector(i+1)+1)];
            end
            
            %find min value and index of 3 neighboring pixels in prev. row.
            [Value Index]=min(Vector);
            IndexIncrement=Index-2;
            j=SeamVector(i+1)+IndexIncrement;
        end
        SeamVector(i,1)=j;
    end
else
    for j=cols:-1:1
        if j==cols
            [vallue, i]=min(x(:,cols));
        else
            if SeamVector(1,j+1)==1
                Vector=[Inf x(SeamVector(j+1),j) x(SeamVector(j+1)+1,j)];
            elseif SeamVector(j+1)==rows
                Vector=[x(SeamVector(j+1)-1,j) x(SeamVector(j+1),j) Inf];
            else
                Vector=[x(SeamVector(j+1)-1,j) x(SeamVector(j+1),j) x(SeamVector(j+1)+1,j)];
            end
            
            %find min value and index of 3 neighboring pixels in prev. row.
            [Value Index]=min(Vector);
            IndexIncrement=Index-2;
            i=SeamVector(j+1)+IndexIncrement;
        end
        SeamVector(1,j)=i;
    end
end