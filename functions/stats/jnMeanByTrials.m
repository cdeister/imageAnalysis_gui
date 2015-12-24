function out=jnMeanByTrials(tdMatrix);

trialNums=size(tdMatrix,2);

for n=1:trialNums-1
    out(:,n)=mean(tdMatrix(:,setdiff(1:trialNums,n),1),2);
end


end