% Calculate the tb (threshold bitmaps) and eb (exclusion bitmaps) of the image
% Reference: Fast, Robust Image Registration for Compositing High Dynamic Range Photographs from Handheld Exposures
% ================================================================
% Parameters:
% image = original grayscale image
% exclusion = exclusion size, default size is 4
% 
% Returns:
% tb = final threshold bitmaps
% eb = final exclusion bitmaps
% ================================================================

function [tb, eb] = getBitmaps(image, exclusion)
    [row, col] = size(image);
    tb = zeros(row, col, 'uint8');
    eb = zeros(row, col, 'uint8');

    if(nargin < 2)
        exclusion = 6;
    end

    med_val = median(image(:));
    for i = 1:row
        for j = 1:col
            if(image(i, j) > med_val)
                tb(i, j) = 255;
            else
                tb(i, j) = 0;
            end

            if(abs(single(image(i, j)) - single(med_val)) <= exclusion)
                eb(i, j) = 0;
            else
                eb(i, j) = 255;
            end
        end
    end
end