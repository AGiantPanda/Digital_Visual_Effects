%
% Tone Mapping Operator, by Reinhard 02 paper.
%
% input:
%   img: 3 channel HDR img
%   a: key value (relates to the key of the image after applying scaling)(high:0.36, noraml:0.18, low:0.09)
%   scales: operate different scales of Guassian filter on img(center-surround ratio) ()
%   phi: sharpening parameter(4.0)
%   epsilon: (local) scalar constant to tell the terminating threshold. (0.05)
%
% output:
%   tone-mapped image (LDR)
%
function imgOut = tonemapLocal(img, a, scales, phi, epsilon )
    imgOut = zeros(size(img));
    delta = 1e-6;

    % Get world luminance from RGB info for all pixels in img
    Lw = 0.27 * img(:,:,1) + 0.67 * img(:,:,2) + 0.06 * img(:,:,3);
    
    % Get log-average luminance as a useful approximation to the key of the scene
    % Use delta to prevent log(0)
	LwMean = exp(mean(mean(log(delta + Lw))));
	L = (a / LwMean) * Lw;
    L(isnan(L))=0;


    Lblur_s = zeros(size(Lw,1), size(Lw,2), scales);
    for i = 1:scales
        s = power(1.6,i-1);
        G_s = fspecial('gaussian', floor(10*s), s); %gouassian filter
        Lblur_s(:,:,i) = imfilter(L,G_s,'conv','symmetric'); % image pass a gaussian filter
    end
    
    for i = 1:size(Lw,1)
        for j = 1:size(Lw,2)
            smax = 1;
            for k = 1:(scales-1)
                s = power(1.6,k-1);
                normal_term = ((power(2,phi)*a)/power(s,2)) + Lblur_s(i,j,k); %prevents V from becoming too large when V approaches zero
                if normal_term == 0
                    Vs = 0;
                else
                    Vs = (Lblur_s(i,j,k)-Lblur_s(i,j,k+1)) / normal_term;
                end
                if abs(Vs) < epsilon %find the right scale
                    smax = k;
                end
                
            end
            if (1+Lblur_s(i,j,smax)) == 0
                Ld(i,j) = 1;
            else
                Ld(i,j) = (L(i,j) / (1+Lblur_s(i,j,smax))); 
            end
        end
   end
    
    for channel = 1:3
        Ratio_w = img(:,:,channel) ./ Lw;
        Ratio_w(isnan(Ratio_w))=0;
        tmp_imgOut = double(Ld) .* Ratio_w;
        [r,c] = find(tmp_imgOut > 1);
        tmp_imgOut(sub2ind(size(tmp_imgOut),r,c)) =1;
        imgOut(:,:,channel) = tmp_imgOut;
    end
    imgOut(isnan(imgOut))=0;


end
