function [pVal,bsDist, fCI] = bootStrapDifferences(dataSet1,dataSet2,numReps,parallelBool,twoTail)

% bootStrapDifferences:
% arguments: dataSet1 and dataSet2 are two distributions for whom you want
% to compute the differences and determine their significance.
% numReps = the number of times to bootstrap
% this is a way of doing something like a "t-test" with bootstrap statistics.
% optional argument is twoTail a boolean value that determines if you want
% to compute the p-value using a two-tail test.


if nargin == 3
    twoTail = 0;
    parallelBool = 0;
elseif nargin == 4
        twoTail = 0;
else
end

tMedDiff = @(x,xx) x-xx;
bsDist1 = bootstrp(numReps,@median,dataSet1);
bsDist2 = bootstrp(numReps,@median,dataSet2);
bsDist = bootstrp(numReps,tMedDiff,bsDist1,bsDist2);

% if parallelBool == 1
%     parfor n=1:numReps
%         a=shuffleTrialsSimp(1:numel(dataSet1));
%         b=shuffleTrialsSimp(1:numel(dataSet2));
%         bsDist(:,n)=nanmedian(dataSet1(a))-nanmedian(dataSet2(b));
% %         if mod(n,200) == 0
% %             disp(['finished ' num2str(n) ' of ' num2str(numReps)])
% %         else
% %         end
%     end
% else
%     for n=1:numReps
%         a=shuffleTrialsSimp(1:numel(dataSet1));
%         b=shuffleTrialsSimp(1:numel(dataSet2));
%         bsDist(:,n)=nanmedian(dataSet1(a))-nanmedian(dataSet2(b));
%         if mod(n,200) == 0
%             disp(['finished ' num2str(n) ' of ' num2str(numReps)])
%         else
%         end
%     end
% end



alphaLevel=0.05;

if twoTail
    cis=prctile(bsDist',[100*alphaLevel/2,100*(1-alphaLevel/2)]);
else
    cis=prctile(bsDist',[100*alphaLevel,100*(1-alphaLevel)]);
end

H = cis(1)>0 | cis(2)<0;


% estimate p-value

fCI=cis(2)-cis(1);
SE=fCI/(2*1.96);
zS=abs(mean(mean(bsDist)))/SE;
pVal=exp((-0.717*zS)-(0.416*(zS^2)));

    
    
end