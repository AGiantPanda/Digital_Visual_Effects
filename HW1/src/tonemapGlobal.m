%
% Tone Mapping Operator, by Reinhard 02 paper.
%
% input:
%   img: HDR img([row, col, channel])
%   a: key value(high:0.36, noraml:0.18, low:0.09)
%   Lwhite: user determined, the smallest luminance to be mapped to 1. (1.5)
%
% output:
%   tone-mapped image (LDR)
%
function imgOut = tonemapGlobal(img, a, Lwhite)
    imgOut = zeros(size(img));
    delta = 1e-6;
    % Get world luminance from RGB info for all pixels in img
    Lw = 0.27 * img(:,:,1) + 0.67 * img(:,:,2) + 0.06 * img(:,:,3);
    
    % Get log-average luminance as a useful approximation to the key of the scene
    % Use delta to prevent log(0)
	LwMean = exp(mean(mean(log(delta + Lw))));
	L = (a / LwMean) * Lw;
    L(isnan(L))=0;
    Ld = (L .* (1 + L / (Lwhite * Lwhite))) ./ (1 + L);
    Ld(isnan(Ld))=0;
    
    % Turn luminance back to RGB
    for channel = 1:3
        Ratio_w = img(:,:,channel) ./ Lw;
        Ratio_w(isnan(Ratio_w))=0;
        imgOut(:,:,channel) = double(Ld) .* Ratio_w;
    end
    imgOut(isnan(imgOut))=0;

end
