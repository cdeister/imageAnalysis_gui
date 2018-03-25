lickSamps=find(aa.thresholdedLicks==1);
waitOn=getStateSamps(aa.teensyStates,1,1);
waitOff=getStateSamps(aa.teensyStates,1,0);
if numel(waitOn)~=numel(waitOff)
    waitOn=waitOn(1:min(numel(waitOn),numel(waitOff)));
    waitOff=waitOn(1:min(numel(waitOn),numel(waitOff)));
else
end
waitDurs=waitOn-waitOff;
figure
subplot(1,2,1)
hold all
for n=1:aa.completedTrials
        plot(aa.thresholdedLicks(waitOff(n)-2000:waitOff(n))*n,'ko')
end
subplot(1,2,2)
hold all
for n=1:aa.completedTrials
        tRL=find(aa.thresholdedLicks(waitOff(n)+10:waitOff(n)+2500)==1);
        if aa.contrasts(n)>0
            if numel(tRL)==0
                poolHM(n)=0;
                poolFA(n)=NaN;
            else
                poolHM(n)=1;
                poolFA(n)=NaN;
            end
        elseif aa.contrasts(n)==0
            if numel(tRL)==0
                poolHM(n)=NaN;
                poolFA(n)=0;
            else
                poolHM(n)=NaN;
                poolFA(n)=1;
            end
        end
    
end

%%
catchCount=find(poolFA>=0);
stimCount=find(poolHM>=0);

faRate=numel(find(poolFA==1))/numel(catchCount);
hitRate=numel(find(poolHM==1))/numel(stimCount);


%%
smtWin=100;
figure(76)
subplot(2,2,1)
plot(nPointMean(poolFA',smtWin),'r-')
hold all,plot(nPointMean(poolHM',smtWin),'k-')


subplot(2,2,2)
plot(norminv(nPointMean(poolHM,smtWin))-norminv(nPointMean(poolFA,smtWin)),'k-')
hold all
plot([0 aa.completedTrials],[1 1],'b:')


%%
%trialFilt=1:aa.completedTrials;
trialFilt=253:353;
tCL=unique(aa.contrasts(trialFilt));
contList=tCL(find(tCL>0));

for n=1:numel(contList)
    tRsp=poolHM(find(aa.contrasts(trialFilt)==contList(n)));
    poolCR(n)=numel(find(tRsp==1))/numel(tRsp);
end
figure,plot(contList,nPointMean(poolCR,6),'ko')
