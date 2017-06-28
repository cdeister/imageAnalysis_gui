function [meanRs,pValues,pairMap]=noiseCorr(dataMatrix,window,shuffle,shufNum)

% dataMatrix is your data (the default assumption is an:
% frame * trial * cell matrix
% window is a two element vector telling it what range to compute the
% correlation
% shuffle is an optional argument that computes the bootstrap

if nargin==2
    shuffle=0;
    shufNum=1;
end

cellNum=size(dataMatrix,3);
trialNum=size(dataMatrix,2);

if shuffle==0
    meanRs=zeros(1,cellNum);
    pValues=zeros(1,cellNum);
    pairMap=zeros(2,cellNum);
elseif shuffle==1
    meanRs=zeros(1,cellNum,shufNum);
    pValues=zeros(1,cellNum,shufNum);
    pairMap=zeros(2,cellNum);
end

testCells=1:size(dataMatrix,3);

if shuffle==0
v=1;
for k=1:numel(testCells),
    for n=k+1:numel(testCells)
        [r,p]=corr(dataMatrix(window(1):window(2),:,testCells(k))-repmat(mean(dataMatrix(window(1):window(2),:,testCells(k)),2),1,trialNum),...
            dataMatrix(window(1):window(2),:,testCells(n))-repmat(mean(dataMatrix(window(1):window(2),:,testCells(n)),2),1,trialNum));
        meanRs(:,v)=mean(diag(r));
        pValues(:,v)=mean(diag(p));
        pairMap(:,v)=[k,n];
        v=v+1;
    end
end

elseif shuffle==1
trialsToUse=1:size(dataMatrix,2);

for y=1:shufNum
    shufTrials=shuffleTrialsSimp(trialsToUse);
    v=1;
for k=1:cellNum,
    for n=k+1:cellNum
        [r,p]=corr(dataMatrix(window(1):window(2),shufTrials,k)-repmat(mean(dataMatrix(window(1):window(2),shufTrials,k),2),1,trialNum),...
            dataMatrix(window(1):window(2),shufTrials,n)-repmat(mean(dataMatrix(window(1):window(2),shufTrials,n),2),1,trialNum));
        meanRs(:,v,y)=mean(diag(r));
        pValues(:,v,y)=mean(diag(p));
        pairMap(:,v)=[k,n];
        v=v+1;
    end
end
end
end

