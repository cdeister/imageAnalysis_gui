%%
preWin=20;
postWindow=120;
clear trigF
cSS=bData.stimSamps/1000;
stimFrames=floor(cSS/0.0510185550219089);
colFrame=size(somaticF,2);

stimFrames(find(stimFrames>size(somaticF,2)-postWindow))=[];
cOrients=bData.orientations(1:numel(stimFrames));
%%
 
clear trigF
clear tMu

tR=11;
oList=unique(cOrients);
for k=1:numel(oList)
sFrames=find(cOrients==oList(k));

%shuffle sFrame Deltas
sFrameDeltas=diff(stimFrames(sFrames));
sFrameDeltas_shuf=sFrameDeltas(randi(numel(sFrameDeltas),numel(sFrameDeltas),1));
firstFrameShuf=randi([30,90]);
shufSFrames=zeros(numel(sFrameDeltas_shuf)+1,1);
shufSFrames(1,1)=firstFrameShuf;
for n=1:numel(sFrameDeltas)
    
    shufSFrames(n+1,1)=shufSFrames(n)+sFrameDeltas_shuf(n);
end

shufSFrames(shufSFrames>stimFrames(end))=shufSFrames(shufSFrames>stimFrames(end))-(shufSFrames(shufSFrames>stimFrames(end))-(stimFrames(end)+postWindow))

for n=1:numel(sFrames)
    
    trigF(:,n)=somaticF_DF(tR,stimFrames(sFrames(n))-preWin:stimFrames(sFrames(n))+postWindow);
    shuf_trigF(:,n)=somaticF_DF(tR,shufSFrames(n)-preWin:shufSFrames(n)+postWindow);
end
tMu(:,k)=mean(trigF,2);
shuf_tMu(:,k)=mean(shuf_trigF,2);
oScore(:,k)=trapz(smooth(tMu(40:60,k)))-smooth(trapz(tMu(1:20,k)));
oScore_shuf(:,k)=trapz(shuf_tMu(40:60,k))-trapz(shuf_tMu(1:20,k));

end
eval(['figure(9' num2str(tR) ')'])
subplot(2,1,1)
hold all,plot(batchSmooth(tMu-mean(tMu(1:25,:),1)),'k-')
hold all,plot(batchSmooth(shuf_tMu-mean(shuf_tMu(1:25,:),1)),'r-') 
subplot(2,1,2)
polarplot(deg2rad(oList),abs(oScore))
hold all
polarplot(deg2rad(oList),abs(oScore_shuf))

%%
for n=1:size(somaticF,1)
tR=n;
for n=1:numel(stimFrames)
    trigF(:,n)=somaticF_DF(tR,stimFrames(n)-preWin:stimFrames(n)+postWindow);  
end
predF=trapz(trigF(50:65,:))-trapz(trigF(1:20,:))
oC(tR)=corr(bData.trialDurations',predF');
sC(tR)=corr(bData.spatialFreqs',predF');
% oCs(tR)=corr(bData.orientations(randperm(numel(bData.trialDurations)))',predF');
sCs(tR)=corr(bData.spatialFreqs(randperm(numel(bData.spatialFreqs)))',predF');
end
figure(67),hold all,plot(oC,'k-')
figure(67),hold all,plot(oCs,'r-')