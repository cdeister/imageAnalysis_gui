function [corrByBin,countsPerBinA,countsPerBinB]=winCountCorr(data,cwin,cwinDelta,corBins)

binCount=(size(data,1)-cwin)./cwinDelta;

cBC=1;
cBI=1;
for n=1:binCount
    countsPerBinA(:,n)=numel(find(data(1+(cwin*(n-1)):cwin+(cwinDelta*(n-1)),1)==1));
    countsPerBinB(:,n)=numel(find(data(1+(cwin*(n-1)):cwin+(cwinDelta*(n-1)),2)==1));
    tcountsPerBinA(:,cBC)=numel(find(data(1+(cwin*(n-1)):cwin+(cwinDelta*(n-1)),1)==1));
    tcountsPerBinB(:,cBC)=numel(find(data(1+(cwin*(n-1)):cwin+(cwinDelta*(n-1)),2)==1));
    if cBC==corBins
        corrByBin(:,cBI)=corr(tcountsPerBinA',tcountsPerBinB')
        cBC=1;
        cBI=cBI+1;
    elseif cBC ~= corBins
        cBC=cBC+1;
    end
end

end