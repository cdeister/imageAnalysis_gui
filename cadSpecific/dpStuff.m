clear discNeurons discFrac hp rp
for n=1:30,[discNeurons,discFrac,auc1(n,:),hp,rp]=cadROCf(trials.stDfs(:,:,:),gain.hitTrials,gain.missTrials,[1+(n-1) 5+(n-1)],0.6,0);,end

%%
clear discNeurons discFrac hp rp
for n=1:30,[discNeurons,discFrac,auc2(n,:),hp,rp]=cadROCf(trials.stEvents(:,:,:),gain.hitTrials,gain.missTrials,[1+(n-1) 5+(n-1)],0.6,0);,end

%%
figure,plot(mean(auc1,2))
hold all,plot(mean(auc2,2))

%%
figure,subplot(1,2,1)
plot(auc1)
hold all
subplot(1,2,2)
plot(auc2)

%%
framesC=2.5:2.5:2.5*30;
figure, plot(mean(auc1(:,gainCells),2))
figure, plot(auc1(:,gainCells))

hold all, plot(mean(auc1(:,nonGainCells),2))
hold all, plot(mean(auc1,2))
meanRtFrames_Hit=mean(analyzedBehavior.reactionTimes(gain.hitTrials))/timingParams.frameInterval;
hold all,plot([9 9],[0.4 0.7])
hold all,plot([10+meanRtFrames_Hit 10+meanRtFrames_Hit],[0.4 0.7])

%%
figure,plot(mean(auc2(:,gainCells),2))
hold,plot(mean(auc2(:,nonGainCells),2))