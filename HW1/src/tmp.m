    %%
    clear all;
    folder = 'C:\Users\panda\Desktop\VFXHW1\HW1\photos\lib6'; 

    %smoothness factor for gsolve
    lambda = 10;


    disp('Read in images with different exposures...');
    [images, exposures] = readImg(folder);
    [row, col, channel, imgNum] = size(images);
    ln_deltaT = log(exposures);

    disp('Aligning images now...');
    [images, x_shifts, y_shifts] = alignImgs(images);

    %sample for doing gsolve (need to be distributed well)
    disp('Shrink the image to get well-distributed sample pixels...');
    ratio = col/row;
    sample_row = ceil(sqrt(256/(ratio*(imgNum-1))));
    sample_col = ceil(ratio*sample_row);

    sample_img = zeros(sample_row, sample_col, channel, imgNum);
    for i = 1:imgNum
       sample_img(:,:,:,i) = round(imresize(images(:,:,:,i), [sample_row sample_col], 'bilinear'));
    end

    disp('Use gsolve to calculate camera response function...');
    g = zeros(256, channel);
    ln_E = zeros(sample_row*sample_col, channel);
    % weight function for gsolve
    w = [0:1:255];
    w = min(w, 255-w);
    w = w/max(w);


    for ch = 1:channel
       rsimages = reshape(sample_img(:,:,ch,:), sample_row*sample_col, imgNum);
        [g(:,ch), ln_E(:,ch)] = gsolve(rsimages, ln_deltaT, lambda, w);
    end

    disp('Build HDR radiance map...');
    imgHDR = buildHDR(images, g, ln_deltaT, w);
    hdrwrite(imgHDR, strcat(folder, '\test2_align_bilinear.hdr'));
    
    imgTM = tonemapLocal(imgHDR,0.54,4,4.0,0.05);
    hdrwrite(imgTM, strcat(folder, '\test_KCFML_tonemapped_local.hdr'));
    imwrite(imgTM, strcat(folder, '\test2_align_018_4_4_005_bilinear.png'));

