% INPUT:
% img_b : background image
% img_f : foreground image
% region_info : region to be blended(region_width, region_height, X_b, Y_b, X_f, Y_f)

function img_blended = poissonBlend(img_b, img_f, region)
% PARAMETERS for poisson blending
%----------------------------------
THRESHOLD = 1E-3;
ITERATION_TIMES = 1240;
STEP = 1.85;
[ROW, COL, CHANNEL] = size(img_b);
%Blending region
%----------------------------------
% Region width and height
%----------------------------------
w = region(1);
h = region(2);
%----------------------------------
% Position for image to be blended(b:background & f:foreground)
%----------------------------------
X_b = region(3);
Y_b = region(4);
X_f = region(5);
Y_f = region(6);

%Blending mask
%msk = zeros(size(img_b));
%msk(Y_b:Y_b+h,X_b:X_b+w,:) = 1;

%Blending region (+-1 pixels) -- Just paste it on (paste the pixel value and the gradient)
img_blended = img_b;

% Background gradient
[im1_GradY im1_GradX] = imgrad(img_b);
% Foreground gradient
[im2_GradY im2_GradX] = imgrad(img_f);

img_blended(Y_b:Y_b+h,X_b:X_b+w,:) = img_f(Y_f:Y_f+h,X_f:X_f+w,:);

im1_GradY(Y_b:Y_b+h,X_b:X_b+w,:)  = im2_GradY(Y_f:Y_f+h,X_f:X_f+w,:);
im1_GradX(Y_b:Y_b+h,X_b:X_b+w,:)  = im2_GradX(Y_f:Y_f+h,X_f:X_f+w,:);


%compute the result after laplace operator (second order differential in x and y direction)
lap = circshift(im1_GradY,[0,1]) - im1_GradY + circshift(im1_GradX,[1,0]) - im1_GradX; 

img_blended0 = img_blended;
err0 = 1E32;

% Start Blending
for i = 1:ITERATION_TIMES
  % Consider blending in each position 
  % ----------------------------------------------------------------------------------------
  row = 1;
  
  col = 1;
  for cha=1:CHANNEL
    if( msk(row,col,cha) > 0 )
      tmp_x = ( lap(row,col,cha) + img_blended(row+1,col,cha) + img_blended(row,col+1,cha) ) / 2;
      img_blended( row, col, cha ) = img_blended( row, col, cha ) + STEP * (tmp_x - img_blended( row, col, cha ));
    end
  end
   
  for col=2:COL-1
    for cha=1:CHANNEL
      if( msk(row,col,cha) > 0 )
        tmp_x = ( lap(row,col,cha) + img_blended(row+1,col,cha) + img_blended(row,col-1,cha) + img_blended(row,col+1,cha) ) / 3;
        img_blended( row, col, cha ) = img_blended( row, col, cha ) + STEP * (tmp_x - img_blended( row, col, cha ));
      end
    end
  end

  col = COL;
  for cha=1:CHANNEL
    if( msk(row,col,cha) > 0 )
      tmp_x = ( lap(row,col,cha) + img_blended(row+1,col,cha) + img_blended(row,col-1,cha) ) / 2;
      img_blended( row, col, cha ) = img_blended( row, col, cha ) + STEP * (tmp_x - img_blended( row, col, cha ));
    end
  end
  % ----------------------------------------------------------------------------------------
  for row=2:ROW-1  
    col = 1;
    for cha=1:CHANNEL
      if( msk(row,col,cha) > 0 )
        tmp_x = ( lap(row,col,cha) + img_blended(row+1,col,cha) + img_blended(row-1,col,cha) + img_blended(row,col+1,cha) ) / 3;
        img_blended( row, col, cha ) = img_blended( row, col, cha ) + STEP * (tmp_x - img_blended( row, col, cha ));
      end
    end
    
    for col=2:COL-1
      for cha=1:CHANNEL
        if( msk(row,col,cha) > 0 )
          tmp_x = ( lap(row,col,cha) + img_blended(row+1,col,cha) + img_blended(row-1,col,cha) + img_blended(row,col-1,cha) + img_blended(row,col+1,cha) ) / 4;
          img_blended( row, col, cha ) = img_blended( row, col, cha ) + STEP * (tmp_x - img_blended( row, col, cha ));
        end
      end
    end
    
    col = COL;
    for cha=1:CHANNEL
      if( msk(row,col,cha) > 0 )
        tmp_x = ( lap(row,col,cha) + img_blended(row+1,col,cha) + img_blended(row-1,col,cha) + img_blended(row,col-1,cha) ) / 3;
        img_blended( row, col, cha ) = img_blended( row, col, cha ) + STEP * (tmp_x - img_blended( row, col, cha ));
      end
    end
  end
  % ----------------------------------------------------------------------------------------
  row = ROW;
  col = 1;
  for cha=1:CHANNEL
    if( msk(row,col,cha) > 0 )
      tmp_x = ( lap(row,col,cha) + img_blended(row-1,col,cha) + img_blended(row,col+1,cha) ) / 2;
      img_blended( row, col, cha ) = img_blended( row, col, cha ) + STEP * (tmp_x - img_blended( row, col, cha ));
    end
  end

  for col=2:COL-1
    for cha=1:CHANNEL
      if( msk(row,col,cha) > 0 )
        tmp_x = ( lap(row,col,cha) + img_blended(row-1,col,cha) + img_blended(row,col-1,cha) + img_blended(row,col+1,cha) ) / 3;
        img_blended( row, col, cha ) = img_blended( row, col, cha ) + STEP * (tmp_x - img_blended( row, col, cha ));
      end
    end
  end

  col = COL;
  for cha=1:CHANNEL
    if( msk(row,col,cha) > 0 )
      tmp_x = ( lap(row,col,cha) + img_blended(row-1,col,cha) + img_blended(row,col-1,cha) ) / 2;
      img_blended( row, col, cha ) = img_blended( row, col, cha ) + STEP * (tmp_x - img_blended( row, col, cha ));
    end
  end
  % ----------------------------------------------------------------------------------------
  dif = abs(img_blended-img_blended0);
  err = max(dif(:));
      
  if( abs(err0 - err)/err0 < THRESHOLD )
    break;
  end
  img_blended0 = img_blended;
  err0 = err;
end

function [GradY GradX] = imgrad(X)
GradY = imfilter(X,[ 0,-1, 1 ],'replicate');
GradX = imfilter(X,[ 0;-1; 1 ],'replicate');
