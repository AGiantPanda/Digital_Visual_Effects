% Radiometric Self Calibration HDR
% by Tomoo Mitsunaga & Shree K. Nayar
% Ahhhhhhhhh, sooooooo anooooooooying...

function [imgHDR, Coeffs, Ratios] = buildHDR2(images, exposures, max_order)
	[row, col, channel, imgNum] = size(images);
    
    % sample pixels then normalize it to [0, 1]
    pixels = 1000;
    sampled_r = randi(row, 1, pixels);
    sampled_c = randi(col, 1, pixels);
    sampled_pixels = zeros(pixels, channel, imgNum);
    for p = 1:pixels
        sampled_pixels(p,:,:) = double(images(sampled_r(p), sampled_c(p), :, :)) / 255.0;
    end
    [v,o] = sort(exposures);
    sampled_pixels = sampled_pixels(:,:,o);

	% max_order size, the default is 10
    if(nargin < 3)
        max_order = 10;
    end

    % try errors with different orders
    min_err = realmax('double');
    order = 0;
    coeffs = cell(1);
    ratios = cell(1);
    for N = 1:max_order
        R = zeros(imgNum, channel);
        R(1, :) = 0.5;
        c = zeros(N+1, channel);
        D_M = zeros(pixels+1, 1);
        D_M(pixels+1, 1) = 1.0;
    	P_Mq0 = zeros(pixels, N+1, channel);
    	P_Mq1 = zeros(pixels, N+1, channel);
        P_M = zeros(pixels+1, N+1, channel);
    	for q = 1:imgNum - 1
    		for p = 1:pixels
    			for k = 1:N+1
    				M0 = power(sampled_pixels(p,:,q),k-1);
    				M1 = power(sampled_pixels(p,:,q+1),k-1);
    				P_Mq0(p, k, :) = M0;
					P_Mq1(p, k, :) = M1;
					P_M(p, k, :) = M0(1,:) - R(q,:).*M1(1,:);
    			end
    		end
    		P_M(pixels+1,:,:) = 1.0;

            % do this to 3 channels seperately
            for s = 1:channel
    	    	% P_Matrix * C_Matrix = D_Matrix
                % {(pixels+1) * (N+1)} * {c0~cn} = {0,..., 0, 1}
                % calculate {c0~cn}
                c(:,s) = P_M(:,:,s)\D_M;

                % update R
                for p = 1:pixels
                    M0 = 0;
                    M1 = 1;
                    for k = 1:N+1
                        M0 = M0 + power(sampled_pixels(p,s,q), k-1) * c(k,s);
                        M1 = M1 + power(sampled_pixels(p,s,q+1), k-1) * c(k,s);
                    end
                    R(q+1, s) = R(q+1, s) + M0 / M1;
                end
            end
        end

    	% calculate combined order's error, choose the minimum
    	err = 0;
    	for q = 1:imgNum - 1
            for p = 1:pixels
				M0 = zeros(1,3);
    			M1 = zeros(1,3);
    			for k = 1:N+1
    				M0(1,:) = M0(1,:) + c(k,:).*power(sampled_pixels(p,:,q),k-1);
					M1(1,:) = M1(1,:) + c(k,:).*power(sampled_pixels(p,:,q+1),k-1);
    			end
                for s = 1:channel
        			err = err + sum(power(M0(1,s) - R(q+1,s).*M1(1,s), 2));
                end
            end
        end

	    if(err < min_err)
	        % replace min_err, order, {c0~cn} & R(order) for 3 channels
	        min_err = err;
	        order = N;
	        coeffs{1} = c;
	        ratios{1} = R;
	    end
	end
    
    imgHDR = images;
    Coeffs = coeffs(1);
    Ratios = ratios(1);
	% use {c1~cn} with the least error to compute hdr photo

end