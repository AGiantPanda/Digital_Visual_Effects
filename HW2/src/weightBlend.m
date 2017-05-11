function [ img_blended ] = weightBlend( imgs, offsets, up)
    %weight_l = ones(size(img_l,1),size(img_l,2),3);
    %weight_r = ones(size(img_r,1),size(img_r,2),3);
    imgNum = size(imgs,2);
    [ROW, COL, CHANNEL] = size(imgs{1});
    w = COL-offsets(1,2)+1;
    w_inverse = 1/w;
    h = ROW-offsets(1,1)+1;

    weight_l = repmat([(1-w_inverse):-w_inverse:0],[h 1 3]);
    weight_r = repmat([0:w_inverse:(1-w_inverse)],[h 1 3]);


    NEW_ROW = h;
    NEW_COL = 2*COL - w;
    img_blended = zeros(NEW_ROW, NEW_COL, CHANNEL,5);

    %middle : 1:h/COL-w+1:COL

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
    imgPaste = zeros(ROW+min_r+max_r, COL+max_c, CHANNEL);
    imgPaste(min_r+1:min_r+ROW, 1:COL, :) = imgs{1}(:,:,:);
    for p = 1:imgNum-1
      for r = 1:ROW
        for c = 1:COL
          imgPaste(min_r+offsets(p, 1)+r, offsets(p,2)+c, :) = imgs{p+1}(r,c,:);
        end
      end
    end

    Y_b = ROW - h +1;
    img_mid_l = imgs{1}(Y_b:end, (COL-w+1):end,:);
    img_mid_r = imgs{2}(1:h, 1:w, :); 

    imgPaste(ROW-h+1:ROW,COL-w+1:COL,:) = weight_l.*img_mid_l+weight_r.*img_mid_r;

%{
    if (up==0)
      Y_b = ROW - h +1;
      img_blended(:,1:end-(COL-w),:) = img_l(Y_b:end,:,:);
      img_blended(:,COL-w+1:end,:) = img_r(1:h,:,:);
      img_mid_l = img_l(Y_b:end, (COL-w+1):end,:);
      img_mid_r = img_r(1:h, 1:w, :); 
    else
      Y_f = ROW - h +1;
      img_blended(:,1:end-(COL-w),:) = img_l(1:h,:,:);
      img_blended(:,COL-w+1:end,:) = img_r(Y_f:end,:,:);
      img_mid_l = img_l(1:h, (COL-w+1):end,:);
      img_mid_r = img_r(Y_f:end, 1:w, :); 
    end

    img_blended(:,COL-w+1:COL,:) = weight_l.*img_mid_l+weight_r.*img_mid_r;
%}
end
