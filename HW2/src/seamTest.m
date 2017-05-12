X = double(img)/255;
orient = 'up'
[rows, cols, dim] = size(X);
E = findEnergy(X);
figure(1)
imshow(E)
S = findSeamImg(E,orient);
figure(2)
imshow(S, [min(S(:)) max(S(:))])
SeamVector = findSeam(S,orient);
SeamedImg=SeamPlot(E,SeamVector,orient);
figure(3)
imshow(SeamedImg,[min(SeamedImg(:)) max(SeamedImg(:))])