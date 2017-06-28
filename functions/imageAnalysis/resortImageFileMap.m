function fileMap=resortImageFileMap(fileMap)

for n=1:numel(fileMap);
    preOrderFilesByNumerals(n)=str2num(fileMap(n,1).name(regexp(fileMap(n,1).name,'\d')));
end

[sorted,sortIdx]=sort(preOrderFilesByNumerals,'ascend');


fileMap=fileMap(sortIdx);