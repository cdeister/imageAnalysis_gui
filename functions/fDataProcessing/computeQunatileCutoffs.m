function [quantileCutoffs,baselineValues]=computeQunatileCutoffs(dataMatToCut,startVal,minVal,dimToCut)

if nargin==1
    startVal=0.25;
    minVal=0.05;
    [~,cutDim]=min(size(dataMatToCut));
end

if cutDim==1
    dataMatToCut=dataMatToCut';
else
end


for n=1:size(dataMatToCut,2)
    
    tScore=(quantile(dataMatToCut(:,n),0.5)-quantile(dataMatToCut(:,n),startVal))./quantile(dataMatToCut(:,n),0.5);
    qCut=(startVal-tScore);
    
    if qCut<minVal
        qCut=minVal;
    else
    end
    
    quantileCutoffs(n)=qCut;
    baselineValues(n)=quantile(dataMatToCut(:,n),qCut);

end