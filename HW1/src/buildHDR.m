% input
%  Z: 4D matrices: [row, col, channel, imgNum]
%  g: 2D matrices, [0~255, channel]
%  ln_deltaT: [ln_e, imgNum] (log(exposure) for input images Z).
%  w: weighting function for pixel value z
% 
% output
%  imgHDR

function imgHDR = buildHDR(Z, g, ln_deltaT, w)
    [row, col, channel, imgNum] = size(Z);
    ln_E = zeros(row, col, channel);
    for ch = 1:channel
		for i = 1:row
		    for j = 1:col
				sumLn_E = 0;
				sumWeight = 0;
				for n = 1:imgNum
				    tempZ = Z(i, j, ch, n) + 1;
				    tempw = w(tempZ+1);
				    tempg = g(tempZ+1);

				    sumLn_E = sumLn_E + tempw * (tempg - ln_deltaT(n));
				    sumWeight = sumWeight + tempw;
				end
				ln_E(i, j, ch) = sumLn_E / sumWeight;
		    end
		end
    end
    ln_E(isnan(ln_E))=0;
    imgHDR = exp(ln_E);

    % remove NAN or INF
    %index = find(isnan(imgHDR) | isinf(imgHDR));
    %imgHDR(index) = 0;
end
