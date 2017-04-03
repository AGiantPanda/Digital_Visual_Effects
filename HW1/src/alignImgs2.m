% Use the two photos with the nearest expo to compute the result
% it "should" be better
% but it doesn't

% Using MTB to align images.
% Reference: Fast, Robust Image Registration for Compositing High Dynamic Range Photographs from Handheld Exposures
% ================================================================
% Parameters:
% images = original images
% levels = level of image pyramids used to align, set to 6 on default
% 
% Returns:
% imgsOut = aligned images
% x_shifts = shifts for each image along x axis
% y_shifts = shifts for each image along y axis
% ================================================================

function [imgsOut, x_shifts, y_shifts] = alignImgs(images, levels)
    [row, col, channel, imgNum] = size( images );

    % convert all images to grayscale
    % it's ok to use the built-in rgb2gray func, but i chose the formula from the paper
    gray_images = zeros(row, col, imgNum, 'uint8');
    gray_images(:,:,:) = (54 * single(images(:,:,1,:)) + 183 * single(images(:,:,2,:)) + 19 * single(images(:,:,3,:))) / 256;

    % img shifts for all the imgs, the first img is set as a reference hence it's shifts are always 0
    x_shifts = zeros(1, imgNum);
    y_shifts = zeros(1, imgNum);

    % image pyramid level size, the default is 6
    if(nargin < 2)
        levels = 6;
    end

    for it = 1:imgNum - 1
        for l = 1:levels
            cur_l = levels - l + 1;

            % the tb and eb of the image with current level
            sml_image1 = imresize(gray_images(:,:,it), 1 / power(2, cur_l - 1));
            sml_image2 = imresize(gray_images(:,:,it+1), 1 / power(2, cur_l - 1));
            [tb1, eb1] = getBitmaps(sml_image1);
            [tb2, eb2] = getBitmaps(sml_image2);

            min_err = row*col;
            x_shift = 0;
            y_shift = 0;
            for x = -1:1
                for y = -1:1
                    xs = x_shifts(it+1) + x;
                    ys = y_shifts(it+1) + y;
                    tb_shifted = imtranslate(tb2, [xs, ys]);
                    eb_shifted = imtranslate(eb2, [xs, ys]);
                    % XOR to find the noise and AND to disregard them
                    diff_b = xor(tb1, tb_shifted);
                    diff_b = and(diff_b, eb1);
                    diff_b = and(diff_b, eb_shifted);
                    err = sum(diff_b(:));
                    if(err < min_err)
                        x_shift = xs;
                        y_shift = ys;
                        min_err = err;
                    end
                end
            end
            x_shifts(it+1) = x_shift;
            y_shifts(it+1) = y_shift;

            % double it if it is not the first level
            if(l < levels)
                x_shifts(it+1) = x_shifts(it+1) * 2;
                y_shifts(it+1) = y_shifts(it+1) * 2;
            end
        end
    end

    % compute the aligned images of the original, the border is set to 0
    imgsOut = zeros(row, col, channel, imgNum, 'uint8');
    for i = 1:imgNum
        if(i > 1)
            x_shifts(i) = x_shifts(i - 1) + x_shifts(i);
            y_shifts(i) = y_shifts(i - 1) + y_shifts(i);
        end
        imgsOut(:,:,:,i) = imtranslate(images(:,:,:,i), [x_shifts(i), y_shifts(i)]);
    end
end