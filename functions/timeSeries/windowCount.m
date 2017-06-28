function countsPerBin=windowCount(data,window,winDelta)
size(data)
binCount=(numel(data)-window)./winDelta
for n=1:binCount
    countsPerBin(:,n)=numel(find(data(1+(winDelta*(n-1)):window+(winDelta*(n-1)))==1));
end

end