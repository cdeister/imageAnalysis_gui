function [roiStack roiSum]=flattenROIs(roiCellArray)

for n=1:numel(roiCellArray)
    roiStack(:,:,n)=roiCellArray{n};
end

roiSum=sum(roiStack,3);


end