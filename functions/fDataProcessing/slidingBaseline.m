function [out]=slidingBaseline(data,windowSize,quantileThresh)


%pre-allocate the vector and then map the data into the pieces between the
%window fragments, then map the first window/2 values into the first pad
%and the last window/2 values into the last pad.

out=zeros(numel(data),1);
outStd=zeros(numel(data),1);
padD=zeros(numel(data)+windowSize,1);
padD((windowSize/2)+1:end-(windowSize/2))=data;
padD(1:(windowSize/2))=data((windowSize/2)+1:((windowSize/2)+1)+((windowSize/2)-1));
padD(end-((windowSize/2)-1):end)=data(end-((windowSize/2)-1):end);

startQuant=windowSize/2;
for n=1:numel(out)
    td=padD((n+startQuant)-startQuant:(n+startQuant)+(startQuant-1));
    out(n)=quantile(td,quantileThresh);
end


