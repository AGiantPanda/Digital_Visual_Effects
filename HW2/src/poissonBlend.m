% INPUT:
% img_b : background image
% img_f : foreground image
% region_info : region to be blended(region_width, region_height, X_b, Y_b, X_f, Y_f)

function img_blended = poissonBlend(img_b, img_f, region, alpha)
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
X_b = COL - w +1;
Y_b = ROW - h +1;


%Blending mask
%msk = zeros(size(img_b));
%msk(Y_b:Y_b+h,X_b:X_b+w,:) = 1;

%Blending region -- Just paste it on (paste the pixel value and the gradient)
%img_blended = img_b;
NEW_ROW = h;
NEW_COL = 2*COL - w;
img_blended = zeros(NEW_ROW, NEW_COL, CHANNEL);
img_blended(:,1:end-(COL-w),:) = img_b(Y_b:end,:,:);
img_blended(:,COL-w+1:end,:) = img_f(1:h,:,:);

% Background gradient
[im1_GradY im1_GradX] = imgrad(img_b);
% Foreground gradient
[im2_GradY im2_GradX] = imgrad(img_f);

im_GradY_all = zeros(NEW_ROW, NEW_COL, CHANNEL);
im_GradX_all = zeros(NEW_ROW, NEW_COL, CHANNEL);


im_GradY_all(:,1:end-(COL-w),:) = im1_GradY(Y_b:end,:,:);
im_GradY_all(:,COL-w+1:end,:) = im2_GradY(1:h,:,:);

im_GradX_all(:,1:end-(COL-w),:) = im1_GradX(Y_b:end,:,:);
im_GradX_all(:,COL-w+1:end,:) = im2_GradX(1:h,:,:);


%img_blended(Y_b:Y_b+h,X_b:X_b+w,:) = img_f(Y_f:Y_f+h,X_f:X_f+w,:);

%im1_GradY(Y_b:Y_b+h,X_b:X_b+w,:)  = im2_GradY(Y_f:Y_f+h,X_f:X_f+w,:);
%im1_GradX(Y_b:Y_b+h,X_b:X_b+w,:)  = im2_GradX(Y_f:Y_f+h,X_f:X_f+w,:);


%compute the result after laplace operator (second order differential in x and y direction)
%lap = circshift(im1_GradY,[0,1]) - im1_GradY + circshift(im1_GradX,[1,0]) - im1_GradX; 
lap = circshift(im_GradY_all,[0,1]) - im_GradY_all + circshift(im_GradX_all,[1,0]) - im_GradX_all; 

img_blended0 = img_blended;
err0 = 1E32;

list=[];
% Start Blending
for i = 1:ITERATION_TIMES
  % Consider blending in each position 
  % ----------------------------------------------------------------------------------------
  
  row = 1;
  
   
  for col=COL-w+1:NEW_COL-1
    if(alpha(row,col) ~= 0 )
      for cha=1:CHANNEL
        if(alpha(row+1,col) ~= 0 )
          list(end+1) = img_blended(row+1,col,cha);
        end
        if(alpha(row,col-1) ~= 0)
          list(end+1) = img_blended(row,col-1,cha);
        end
        if(alpha(row,col+1) ~= 0 )
          list(end+1) = img_blended(row,col+1,cha);
        end
        tmp_x = ( lap(row,col,cha) + sum(list)) / length(list);
        img_blended( row, col, cha ) = img_blended( row, col, cha ) + STEP * (tmp_x - img_blended( row, col, cha ));
        list = [];
      end
    end
  end

  col = NEW_COL;
  if(alpha(row,col) ~= 0 )
    for cha=1:CHANNEL
      if(alpha(row+1,col) ~= 0 )
        list(end+1) = img_blended(row+1,col,cha);
      end
      if(alpha(row,col-1) ~= 0)
        list(end+1) = img_blended(row,col-1,cha);
      end
      tmp_x = ( lap(row,col,cha) + sum(list)) / length(list);
      img_blended( row, col, cha ) = img_blended( row, col, cha ) + STEP * (tmp_x - img_blended( row, col, cha ));
      list = [];
    end
  end
  % ----------------------------------------------------------------------------------------
  for row=2:NEW_ROW-1  
    %col = COL-w+1;
    %for cha=1:CHANNEL
    %	tmp_x = ( lap(row,col,cha) + img_blended(row+1,col,cha) + img_blended(row-1,col,cha) + img_blended(row,col+1,cha) ) / 3;
    %    img_blended( row, col, cha ) = img_blended( row, col, cha ) + STEP * (tmp_x - img_blended( row, col, cha ));
    %end
    
    for col=COL-w+1:NEW_COL-1
      if(alpha(row,col) ~= 0 )
        for cha=1:CHANNEL
          if(alpha(row+1,col) ~= 0 )
            list(end+1) = img_blended(row+1,col,cha);
          end
          if(alpha(row,col-1) ~= 0)
            list(end+1) = img_blended(row,col-1,cha);
          end
          if(alpha(row-1,col) ~= 0 )
            list(end+1) = img_blended(row-1,col,cha);
          end
          if(alpha(row,col+1) ~= 0)
            list(end+1) = img_blended(row,col+1,cha);
          end
          tmp_x = ( lap(row,col,cha) + sum(list)) / length(list);          
          img_blended( row, col, cha ) = img_blended( row, col, cha ) + STEP * (tmp_x - img_blended( row, col, cha ));
          list = [];
        end
      end
    end
    
    col = NEW_COL;
    if(alpha(row,col) ~= 0 )
      for cha=1:CHANNEL
          if(alpha(row+1,col) ~= 0 )
            list(end+1) = img_blended(row+1,col,cha);
          end
          if(alpha(row,col-1) ~= 0)
            list(end+1) = img_blended(row,col-1,cha);
          end
          if(alpha(row-1,col) ~= 0 )
            list(end+1) = img_blended(row-1,col,cha);
          end
          tmp_x = ( lap(row,col,cha) + sum(list)) / length(list);          
          img_blended( row, col, cha ) = img_blended( row, col, cha ) + STEP * (tmp_x - img_blended( row, col, cha ));
          list = [];
      end
    end
  end
  % ----------------------------------------------------------------------------------------
  row = NEW_ROW;
  %col = COL-w+1;;
  %for cha=1:CHANNEL
%	tmp_x = ( lap(row,col,cha) + img_blended(row-1,col,cha) + img_blended(row,col+1,cha) ) / 2;
%	img_blended( row, col, cha ) = img_blended( row, col, cha ) + STEP * (tmp_x - img_blended( row, col, cha ));
%  end

  for col=COL-w+1:NEW_COL-1
    if(alpha(row,col) ~= 0 )
      for cha=1:CHANNEL
        if(alpha(row-1,col) ~= 0 )
          list(end+1) = img_blended(row-1,col,cha);
        end
        if(alpha(row,col-1) ~= 0)
          list(end+1) = img_blended(row,col-1,cha);
        end
        if(alpha(row,col+1) ~= 0 )
          list(end+1) = img_blended(row,col+1,cha);
        end
        tmp_x = ( lap(row,col,cha) + sum(list)) / length(list);          
        img_blended( row, col, cha ) = img_blended( row, col, cha ) + STEP * (tmp_x - img_blended( row, col, cha ));
        list = [];
      end
    end
  end

  col = NEW_COL;
  if(alpha(row,col) ~= 0 )
    for cha=1:CHANNEL
      if(alpha(row-1,col) ~= 0 )
        list(end+1) = img_blended(row-1,col,cha);
      end
      if(alpha(row,col-1) ~= 0)
        list(end+1) = img_blended(row,col-1,cha);
      end
      tmp_x = ( lap(row,col,cha) + sum(list)) / length(list);          
      img_blended( row, col, cha ) = img_blended( row, col, cha ) + STEP * (tmp_x - img_blended( row, col, cha ));
      list = [];
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
