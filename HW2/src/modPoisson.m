function Y = modPoisson( X, param)
ep = 1E-8;

s = [size(X,1), size(X,2), size(X,3)];

Fh = ( X(:,:,:,2) + circshift(X(:,:,:,4),[0,-1])) / 2;
Fv = ( X(:,:,:,3) + circshift(X(:,:,:,5),[-1,0])) / 2;
L = circshift(Fh,[0,1]) + circshift(Fv,[1,0]) - Fh - Fv;

Y = zeros(s);
param2 = param .* param;
for i=1:s(3)
 Xdct = dct2(X(:,:,i));
 Ydct = ( param .* dct2(L(:,:,i)) + ep * Xdct  ) ./ (param2 + ep);
 Y(:,:,i) = idct2(Ydct);
end