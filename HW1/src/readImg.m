%%--------------------------------------------------------------------------------
% Read in images with different exposures.
%%--------------------------------------------------------------------------------
% input
%  folder: folder name for images. (extension: jpg)
%%--------------------------------------------------------------------------------
% output
%  images: 4D matrices: [row, col, channel, number of images].
%  exposure: (number, 1) matrices, representing image's exposure time in second.
%
%%--------------------------------------------------------------------------------

function [images, exposure] = readImg(folder)
    files = dir([folder, '/*.JPG']);

    % initialization
    info = imfinfo([folder, '/', files(1).name]);
    imgNumber = length(files);
    images = zeros(info.Height, info.Width, info.NumberOfSamples, imgNumber, 'uint8');
    exposure = zeros(imgNumber, 1);

    % read in image and its exposure time
    for i = 1:imgNumber
	   filename = [folder, '/', files(i).name];
	   images(:,:,:,i) = imread(filename);
    
	   expoInfo = imfinfo(filename);
	   exposure(i) = expoInfo.DigitalCamera.ExposureTime;
    end
end
