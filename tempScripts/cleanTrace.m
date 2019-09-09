%%
traces.dfs_npc = somaticF_DF;

%%
traces.ogSomaticF_DF = somaticF_DF;
%%
tN=10;
close all
tTrace=traces.dfs_npc(tN,:)';
oTrace=traces.dfs_npc(tN,:)';



tMedian=median(tTrace);

% is the median above or below 0?
medDif=tMedian-0;

cTrace=tTrace-medDif;
pMedian=median(cTrace);
cMin=min(cTrace);



% begin by assuming the median to zero correction is the initial noise bounds
noiseRange=[abs(medDif) -abs(medDif)];
noiseSamples=cTrace(cTrace<noiseRange(1));
noiseStd=10*std(noiseSamples);

if cMin<noiseRange(2)
    cTrace(cTrace<(noiseRange(2)-noiseStd))=noiseRange(2);
end
pMedian=median(cTrace);
noiseSamples2=cTrace(cTrace<noiseRange(1));
signalSamples=cTrace(cTrace>=noiseRange(1));
noiseStd2=std(noiseSamples2)
noiseRange2=[noiseRange(2)+noiseStd noiseRange(2)-noiseStd]

tSNR=var(signalSamples)/var(noiseSamples2)
cTrace(cTrace<noiseRange2)=pMedian;



%
figure
subplot(1,2,1)
hold all
plot(oTrace,'k-','linewidth',1)
plot(cTrace,'b-','linewidth',1)
plot(nPointMean(cTrace,4),'r-','linewidth',1)
plot([1 1000],[0 0],'k-')
plot([1 1000],[noiseRange(1) noiseRange(1)],'r-')
plot([1 1000],[noiseRange(2) noiseRange(2)],'r-')

subplot(1,2,2)
hold all
plot(cTrace,'k-','linewidth',1)
title([num2str(tSNR)])


%% loop for save
for g=1:size(traces.dfs_npc,1)
tN=g;
tTrace=traces.dfs_npc(tN,:)';




tMedian=median(tTrace);

% is the median above or below 0?
medDif=tMedian-0;
pMedian=median(tTrace);
cTrace=tTrace-medDif;
cMin=min(cTrace);



% begin by assuming the median to zero correction is the initial noise bounds
noiseRange=[abs(medDif) -abs(medDif)];
noiseSamples=cTrace(cTrace<noiseRange(1));
noiseStd=4*std(noiseSamples);

if cMin<noiseRange(2)
    cTrace(cTrace<(noiseRange(2)-noiseStd))=noiseRange(2);
end
noiseSamples2=cTrace(cTrace<noiseRange(1));
signalSamples=cTrace(cTrace>=noiseRange(1));
noiseStd2=std(noiseSamples2)

noiseRange2=[noiseRange(2)+noiseStd noiseRange(2)-noiseStd]

somaticSNR(:,g)=var(signalSamples)/var(noiseSamples2)
cTrace(cTrace<noiseRange2)=pMedian;
traces.dfs_npc(g,:)=cTrace;
end

%%
somaticF_DF = traces.dfs_npc;
%%
somaticF_DF = traces.ogSomaticF_DF;




