function  [cornerList] = NonMaximalSuppresion(tempCornerR, tempCornerC, R_sort, featNum)

	if (featNum >= size(tempCornerC))
		cornerList = [tempCornerC tempCornerR];
		return;
	end

	localRadius = 500;
	tempList = [tempCornerC tempCornerR R_sort];
	cornerList = [];

	tempNum = 1;
	cornerList(tempNum,1:2) = tempList(tempNum,1:2);
	tempList(1,:) = [];

	while (tempNum <= featNum)
		clearIndex = [];
		for i= 1:size(tempList,1)
			pos = tempList(i,1:2);
			R = tempList(i,3);
			if (calDistance(pos,cornerList,localRadius))
				tempNum = tempNum + 1;
				cornerList(tempNum, 1:2) = pos';
				clearIndex(end+1) = i;
			end
		end
		localRadius = max(round(localRadius/2), 3);

		for i = length(clearIndex):-1:1
            tempList(clearIndex(i), :) = [];
        end
    end
    cornerList(tempNum+1:end, :) = [];
	
end

function outside = calDistance(pos,cornerList,threshold)
	for i = 1:size(cornerList)
		if ((pos(1) - cornerList(i,1))^2 + (pos(2) - cornerList(i,2))^2 < threshold^2)
			outside = false;
			return;
		end
	end
	outside = true;
end