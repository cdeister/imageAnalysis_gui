function s1=combineStacks(s1,s2)

	try 
		d1=size(s1,1);
		d2=size(s1,2);
		d3a=size(s1,3);
		d3b=size(s2,3);

	catch
		disp('first "stack" is not 3d')
	end

	if size(s1,1) ~= size(s2,1)
		disp('first dimension is unequal')
		return
	else if numel(size(s1)) ~= numel(size(s2))
		disp('stacks of different dimensionality')
		return
	else
		s1=horzcat(reshape(s1,size(s1,1)*size(s1,2),size(s1,3)),...
		reshape(s2,size(s2,1)*size(s2,2),size(s2,3)));

		s1=reshape(s1,d1,d2,d3a+d3b);	
	end




end