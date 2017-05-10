function Y = imGradFeature(X)
Y = zeros(size(X,1),size(X,2),size(X,3),5);

Y(:,:,:,1) = X;
Y(:,:,:,2) = imfilter(X,[ 0,-1, 1 ],'replicate'); %forward horizontal difference
Y(:,:,:,3) = imfilter(X,[ 0;-1; 1 ],'replicate'); %forward vertical difference
Y(:,:,:,4) = circshift(Y(:,:,:,2),[0,1]); %backward horizontal difference
Y(:,:,:,5) = circshift(Y(:,:,:,3),[1,0]); %backward vertical difference
