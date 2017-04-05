% Radiometric Self Calibration HDR
% by Tomoo Mitsunaga & Shree K. Nayar
% Ahhhhhhhhh, sooooooo anooooooooying...

function [imgHDR, Coeffs, Ratios] = buildHDR2(images, exposures, max_order)
	[row, col, channel, imgNum] = size(images);
    pixels = row*col;

	% normalize the images values to [0, 1]
	% i should add normally distributed noise later
    imgsNorm = zeros(row, col, channel, imgNum);
    imgsNorm(:,:,:,:) = images(:,:,:,:) / 255;
    [v,o] = sort(exposures);
    imgsNorm = imgsNorm(:,:,:,o);
	% max_order size, the default is 10
    if(nargin < 3)
        max_order = 10;
    end

    % try errors with different orders
    min_err = realmax('double');
    order = 0;
    coeffs = cell(1);
    ratios = cell(1);
    for N = 0:max_order
        R = zeros(imgNum, channel);
        R(1, :) = 0.5;
        c = zeros(N+1, channel);
        D_M = zeros(pixels+1, 1);
        D_M(pixels+1, 1) = 1.0;
    	P_Mq0 = zeros(pixels, N+1, channel);
    	P_Mq1 = zeros(pixels, N+1, channel);
        P_M = zeros(pixels+1, N+1, channel);
    	for q = 1:imgNum - 1
    		for i = 1:row
    			for j = 1:col
    				for k = 1:N+1
    					M0 = power(imgsNorm(i, j, :, q), k-1);
    					M1 = power(imgsNorm(i, j, :, q+1), k-1);
    					P_Mq0(i*col+j, k, :) = M0;
    					P_Mq1(i*col+j, k, :) = M1;
    					P_M(i*col+j, k, :) = M0(1,:) - R(q,:).*M1(1,:);
    				end
    			end
    		end
    		P_M(pixels+1,:,:) = 1.0;

            % do this to 3 channels seperately
            for s = 1:channel
    	    	% P_Matrix * C_Matrix = D_Matrix
                % {(pixels+1) * (N+1)} * {c0~cn} = {0,..., 0, 1}
                % calculate {c0~cn}
                c(:,s) = P_M\D_M;

                % update R
                R(q+1, s) = sum(P_Mq0(:,:,s)*c(:,s) ./ P_Mq1(:,:,s)*c(:,s));
            end
        end

    	% calculate combined order's error, choose the minimum
    	err = 0;
    	for q = 1:imgNum - 1
    		for i = 1:row
    			for j = 1:col
    				M0 = zeros(1,3);
    				M1 = zeros(1,3);
    				for k = 1:N+1
    					M0(1,:) = M0(1,:) + c(n,:)*power(imgsNorm(i,j,:,q),k-1);
    					M1(1,:) = M1(1,:) + c(n,:)*power(imgsNorm(i,j,:,q+1),k-1);
    				end
    				err = err + sum(power(M0(1,:) - R(q+1,:).*M1(1,:), 2));
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
    
    imgHDR = imgsNorm;
    Coeffs = coeffs(1);
    Ratios = ratios(1);
	% use {c1~cn} with the least error to compute hdr photo

end