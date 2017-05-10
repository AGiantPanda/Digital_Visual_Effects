function [ img_blended ] = weightBlend( img_l, img_r, region, up)
    %weight_l = ones(size(img_l,1),size(img_l,2),3);
    %weight_r = ones(size(img_r,1),size(img_r,2),3);

    %????????º§æ¨?    
    w = region(1);
    w_inverse = 1/w;
    h = region(2);

    weight_l = repmat([1-w_inverse:-w_inverse:0],[h 1 3]);
    weight_r = repmat([0:w_inverse:1-w_inverse],[h 1 3]);


    [ROW, COL, CHANNEL] = size(img_l);
    NEW_ROW = h;
    NEW_COL = 2*COL - w;
    img_blended = zeros(NEW_ROW, NEW_COL, CHANNEL);

    %middle : 1:h/COL-w+1:COL

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

end