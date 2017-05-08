function pointMatched = featMatch(imgFeature_1, imgFeature_2)
    THRESHOLD = 0.6;

	kdTree2 = KDTreeSearcher(imgFeature_2);
    %Find the k nearest neighbor index of imgFeature_1 for the feature descriptors in imgFeature_2
	idx1 = knnsearch(kdTree2, imgFeature_1, 'K', 2);
    
    kdTree1 = KDTreeSearcher(imgFeature_1);
    %Find the k nearest neighbor index of imgFeature_2 for the feature descriptors in imgFeature_1
    idx2 = knnsearch(kdTree1, imgFeature_2, 'K', 2);
    
    indexMatched = [];
    matchNum = 0;
    for i = 1:size(idx1, 1)
        idx1_1 = idx1(i, 1);
        idx1_2 = idx1(i, 2);
        X = find(idx2(idx1_1, :) == i);
        %distance for the 2 nearest neighbor
        dis1 = sum((imgFeature_1(i, :)-imgFeature_2(idx1_1, :)).^2);
        dis2 = sum((imgFeature_1(i, :)-imgFeature_2(idx1_2, :)).^2);

        if(length(X) > 0 && dis1 < THRESHOLD*dis2)
            matchNum = matchNum+1;
            indexMatched(matchNum, 1:2) = [i, idx1_1];
        end
    end

    tmp1rc = imgFeature_1(indexMatched(:,1),65:end);

    tmp2rc = imgFeature_2(indexMatched(:,2),65:end);

    pointMatched = [tmp1rc,tmp2rc]; 


end