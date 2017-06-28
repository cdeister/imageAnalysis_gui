function [shuffled1,shuffled2]=randomFraction(dataVector,fraction)

rng('shuffle');


dataVectorCopy=dataVector;

for n=1:numel(dataVector);
    rNum=randi(numel(dataVectorCopy));
    shuffledVector(:,n)=dataVectorCopy(rNum);
    dataVectorCopy(rNum)=[];
end


slicePoint=fix(numel(dataVector)*fraction);
shuffled1=shuffledVector(1:slicePoint);
shuffled2=shuffledVector(slicePoint+1:end);
