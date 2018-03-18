%%
preWin=30;
postWindow=300;
clear trigF
cSS=bData.stimSamps/1000;
stimFrames=floor(cSS/0.0510185550219089);
colFrame=size(somaticF,2);

stimFrames(find(stimFrames>size(somaticF,2)-postWindow))=[];
cOrients=bData.curOrientations(1:numel(stimFrames))/10;
%%
 
clear trigF
clear tMu

tR=4;
oList=unique(cOrients);
for k=1:numel(oList)
sFrames=find(cOrients==oList(k));
for n=1:numel(sFrames)
    trigF(:,n)=somaticF_DF(tR,stimFrames(sFrames(n))-preWin:stimFrames(sFrames(n))+postWindow);  
end
tMu(:,k)=mean(trigF,2);
oScore(:,k)=trapz(tMu(40:60,k))-trapz(tMu(1:30,k));
figure(98)
subplot(2,1,1)
hold all,plot(mean(trigF,2))
end
subplot(2,1,2)
polarplot(deg2rad(oList),abs(oScore))

%%

