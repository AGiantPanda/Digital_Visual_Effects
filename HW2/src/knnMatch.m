function [ point_matched distance ] = knnMatch( imgFeature_1, imgFeature_2 ,matchNum)
if matchNum>size(imgFeature_1,1)*size(imgFeature_2,1)
    matchNum = size(imgFeature_1,1)*size(imgFeature_2,1);
end
point_matched = zeros(matchNum,4);
distance = zeros(size(imgFeature_1,1),size(imgFeature_2,1));
for i=1:size(distance,1)
    for j=1:size(distance,2)
        distance(i,j) = norm(imgFeature_1(i,1:(size(imgFeature_1,2))-2)-imgFeature_2(j,1:(size(imgFeature_2,2))-2),2);
        %distance(i,j) = norm(imgFeature_1(i,3:(size(imgFeature_1,2)))-imgFeature_2(j,3:(size(imgFeature_2,2))),2);
    end
end
[B idx] = sort(distance(:),'ascend');


for i=1:matchNum
    if mod(idx(i),size(distance,1))==0
        row = size(distance,1);
    else
        row = mod(idx(i),size(distance,1));
    end
    column = ceil(idx(i)/size(distance,1));
    
    point_matched(i,1:2) = imgFeature_1(row,(size(imgFeature_1,2))-1:end);
    point_matched(i,3:4) = imgFeature_2(column,(size(imgFeature_2,2))-1:end);
    %point_matched(i,1:2) = imgFeature_1(row,1:2);
    %point_matched(i,3:4) = imgFeature_2(column,3:4);
end