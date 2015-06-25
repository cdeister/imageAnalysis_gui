clear discNeurons discFrac hp rp auc1
for n=1:22,[discNeurons,discFrac,auc1(n,:),hp,rp]=cadROCf(trials.stDfs(:,:,:),gain.hitTrials,gain.missTrials,[1+(n-1) 2+(n-1)],0.6,0);,end

%%
clear discNeurons discFrac hp rp
for n=1:22,[discNeurons,discFrac,auc2(n,:),hp,rp]=cadROCf(trials.stEvents(:,:,:),gain.hitTrials,gain.missTrials,[1+(n-1) 2+(n-1)],0.6,0);,end

%%
figure,plot(mean(auc1,2))
hold all,plot(mean(auc2,2))
%%
figure
plot(auc)


%%
framesC=2.5:2.5:2.5*30;
figure, plot(mean(auc1(:,gainCells),2))
hold all, plot(mean(auc1(:,nonGainCells),2))
hold all, plot(mean(auc1,2))
meanRtFrames_Hit=mean(analyzedBehavior.reactionTimes(gain.hitTrials))/timingParams.frameInterval;
hold all,plot([9 9],[0.4 0.7])
hold all,plot([10+meanRtFrames_Hit 10+meanRtFrames_Hit],[0.4 0.7])

%%
figure,plot(mean(auc2(:,gainCells),2))
hold,plot(mean(auc2(:,nonGainCells),2))

%%
figure,boundedline([1:37],mean(auc1(:,gainCells),2),std(auc1(:,gainCells)./sqrt(numel(gainCells)),1,2),'cmap',[1 0 0])
hold all,boundedline([1:37],mean(auc1(:,nonGainCells),2),std(auc1(:,nonGainCells)./sqrt(numel(nonGainCells)),1,2),'cmap',[0 0 1])
%%
figure,boundedline([1:30],mean(auc2(:,gainCells),2),std(auc2(:,gainCells)./sqrt(numel(gainCells)),1,2),'cmap',[1 0 0])
hold all,boundedline([1:30],mean(auc2(:,nonGainCells),2),std(auc2(:,nonGainCells)./sqrt(numel(nonGainCells)),1,2),'cmap',[0 0 1])

%%
earlyDPs=mean(auc1(1:5,:),1);
figure,nhist(earlyDPs,'box')
stimDPs=mean(auc1(10:15,:),1);
figure,nhist(stimDPs,'box')
figure,nhist({stimDPs(nonDriven),stimDPs(nonGainCells),stimDPs(gainCells)},'box')


%%
testCells=1:215;
stEvents=trials.stDfs;
ncWindow=[1 6];
trialTypes=gain.hitTrials;
v=1;
for k=1:numel(testCells),
    for n=k+1:numel(testCells)
        [r,p]=corr(stEvents(ncWindow(1):ncWindow(2),trialTypes,testCells(k))-repmat(mean(stEvents(ncWindow(1):ncWindow(2),trialTypes,testCells(k)),2),1,numel(trialTypes)),stEvents(ncWindow(1):ncWindow(2),trialTypes,testCells(n))-repmat(mean(stEvents(ncWindow(1):ncWindow(2),trialTypes,testCells(n)),2),1,numel(trialTypes)));
        meanRd(:,v)=mean(diag(r));
        meanPd(:,v)=mean(diag(p));
        v=v+1;
    end
end

%%
clear meanRd_hit meanPd_hit
testCells=drivenCells;
stEvents=trials.stDfs;
ncWindow=[7 16];
trialTypes=gain.hitTrials;
v=1;
for k=1:numel(testCells),
    for n=k+1:numel(testCells)
        [r,p]=corr(stEvents(ncWindow(1):ncWindow(2),trialTypes,testCells(k))-repmat(mean(stEvents(ncWindow(1):ncWindow(2),trialTypes,testCells(k)),2),1,numel(trialTypes)),stEvents(ncWindow(1):ncWindow(2),trialTypes,testCells(n))-repmat(mean(stEvents(ncWindow(1):ncWindow(2),trialTypes,testCells(n)),2),1,numel(trialTypes)));
        meanRd_hit(:,v)=mean(diag(r));
        meanPd_hit(:,v)=mean(diag(p));
        matDp(:,:,v)=[earlyDPs(k),earlyDPs(n),mean(diag(r))];
        v=v+1;
    end
end
        matDp=squeeze(matDp);
        matDp=matDp';


%%
clear meanRd_miss meanPd_miss
testCells=drivenCells;
stEvents=trials.stDfs;
ncWindow=[7 16];
trialTypes=gain.missTrials;
v=1;
for k=1:numel(testCells),
    for n=k+1:numel(testCells)
        [r,p]=corr(stEvents(ncWindow(1):ncWindow(2),trialTypes,testCells(k))-repmat(mean(stEvents(ncWindow(1):ncWindow(2),trialTypes,testCells(k)),2),1,numel(trialTypes)),stEvents(ncWindow(1):ncWindow(2),trialTypes,testCells(n))-repmat(mean(stEvents(ncWindow(1):ncWindow(2),trialTypes,testCells(n)),2),1,numel(trialTypes)));
        meanRd_miss(:,v)=mean(diag(r));
        meanPd_miss(:,v)=mean(diag(p));
        v=v+1;
    end
end