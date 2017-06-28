function outBaselinedData=baselineData(data,samplesToUse,start)

if nargin==2
    start=1;
else
end


baselines=mean(data(start:start+(samplesToUse),:,:),1);
baselines=repmat(baselines,size(data,1),1,1);

outBaselinedData=data-baselines;
end
