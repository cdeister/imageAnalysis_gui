function deleteROI(numberList,typeList,scopeString)

% deleteROI: deletes all elements associated with program created ROIs
%
% Arguments:
% 1) 'numberList' is a vector of roiID numbers e.g. (101,99)
% 2) 'typeList' is a cell array of roiType strings e.g. {'somatic','dendritic'}
% 3) 'scopeString' is an optional string to redirect scope (where the ROIs are)
% The default 'scope' is 'base'. You will likely never change it.
% 
% Returns:
% Nothing
%
% cdeister@brown.edu; 10/8/2017


if nargin==2
	scopeString='base';
else
end


% first, I check to see if there is extracted F data for the types of ROIs the user wants to delete.
% that data is extracted after ROI creation, so they don't always go together. 

fDelete=zeros(size(numberList));
uniqueTypes=unique(typeList)
for n=1:numel(uniqueTypes)
	g=evalin(scopeString,['exist(' uniqueTypes{n} ');'])
	if g==1
		roisToDelete=numberList(strcmp(a,uniqueTypes{n}));
		evalin(scopeString,[uniqueTypes{n} 'F([' num2str(roisToDelete) '],:)=[];'])
	else
	end
end
clear n

%debug
disp(fDelete)

% for n=1:numel	
% 	evalin(scopeString,[typeList{n} 'F()'])


% end


end