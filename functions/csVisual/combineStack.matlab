function s1=combineStacks(s1,s2)

s1=horzcat(reshape(s1,size(s1,1)*size(s1,2),size(s1,3)),...
	reshape(s2,size(s2,1)*size(s2,2),size(s2,3)))

end