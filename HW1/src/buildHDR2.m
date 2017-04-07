% Radiometric Self Calibration HDR
% by Tomoo Mitsunaga & Shree K. Nayar
% Ahhhhhhhhh, sooooooo anooooooooying...

function [imgHDR, coeffs, ratios] = buildHDR2(images, exposures, max_order)
	[row, col, channel, imgNum] = size(images);
    
    % sample pixels then normalize it to [0, 1]
    % pixels = 100;
    % sampled_r = randi(row, 1, pixels);
    % sampled_c = randi(col, 1, pixels);
    % sampled_pixels = zeros(pixels, channel, imgNum);
    % for p = 1:pixels
    %     sampled_pixels(p,:,:) = double(images(sampled_r(p), sampled_c(p), :, :)) / 255.0;
    % end
    % [v,o] = sort(exposures);
    % sampled_pixels = sampled_pixels(:,:,o);

    disp('Shrink the image to get well-distributed sample pixels...');
    ratio = col/row;
    sample_row = 30;
    sample_col = ceil(ratio*sample_row);
    pixels = sample_row*sample_col;
    sample_img = zeros(sample_row, sample_col, channel, imgNum);
    for i = 1:imgNum
       sample_img(:,:,:,i) = round(imresize(images(:,:,:,i), [sample_row sample_col], 'bilinear'));
    end
    sampled_pixels = zeros(sample_row*sample_col, channel, imgNum);
    for s = 1:channel
        sampled_pixels(:,s,:) = reshape(sample_img(:,:,s,:), sample_row*sample_col, imgNum)/255;
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
    coeffs = zeros(1, channel);
    ratios = zeros(imgNum, channel);
    errors = zeros(max_order, 1);
    for N = 1:max_order
        R = zeros(imgNum, channel);
        % default settings for R
        R(1, :) = 0.7;
        c = zeros(N+1, channel);
        % B matrix, B(p+1, 1) = 1, others = 0
        D_M = zeros(pixels+1, 1);
        D_M(pixels+1, 1) = 1.0;
        % P_Mq is pixels * N+1 * channel matrix, value of p,k-order,q
    	P_Mq0 = zeros(pixels, N+1, channel);
    	P_Mq1 = zeros(pixels, N+1, channel);
        P_M = zeros(pixels+1, N+1, channel);
    	for q = 1:imgNum - 1
            % to build the P_M matrix, correct af
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
                R(q+1,s) = 1/pixels * sum((P_Mq0(:,:,s)*c(:,s))./(P_Mq1(:,:,s)*c(:,s)));
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

        errors(N) = err;
	    if(err < min_err)
	        % replace min_err, order, {c0~cn} & R(order) for 3 channels
	        min_err = err;
	        order = N;
	        coeffs = c;
	        ratios = R;
	    end
	end
    disp(min_err);
    x = 0:0.01:1;
    y1 = zeros(1,length(x));
    y2 = zeros(1,length(x));
    y3 = zeros(1,length(x));
    for k = 1:order+1
        y1 = y1(:)+coeffs(k,1)*power(x(:), k-1);
        y2 = y2(:)+coeffs(k,2)*power(x(:), k-1);
        y3 = y3(:)+coeffs(k,3)*power(x(:), k-1);
    end
    plot(x,y1,x,y2,x,y3);
	% use {c1~cn} with the least error to compute hdr photo
    imgHDR = zeros(row, col, channel);
    % for i = 1:row
    %     for j = 1:col
    %         for s = 1:channel
    %             r = 1;
    %             q = imgNum;
    %             for qb = 1:imgNum
    %                 q = q - qb + 1;
    %                 if(images(row, col, s, q) < 255)
    %                     break;
    %                 end
    %                 r = r*ratios(q,s);
    %             end
    %             for k = 1:order+1
    %                 imgHDR(row, col, s) = imgHDR(row, col, s) + coeffs(k, s) * power(double(images(row, col, s, q))/255.0, k - 1);
    %             end
    %             imgHDR(row, col, s) = imgHDR(row, col, s)/r;
    %         end
    %     end
    % end
end