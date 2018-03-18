function binaryVector=binarizeResponse(analogVector,threshold)


numPass=numel(threshold);
binaryVector=zeros(size(analogVector));

for n=1:numPass
    binaryVector(analogVector>threshold(n))=1;
end

end