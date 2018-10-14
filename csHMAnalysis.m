%% hit miss analysis
% assumes you have an F matrix.
%
%
%% make image clock
% we multiply by 1000 so it is the same as the behavior time. 
frameTime = (frameDelta:frameDelta:frameDelta*size(somaticF,2))*1000;
%
% reassert behavior time
bData.sessionTime = bData.interrupts;
%
%%
% get stim frames and do some stats 
firstCond = @(x) x(1);
lickWindow = 1500;
for n = 1:numel(bData.stimSamps)
    parsed.stimFrame(n)=firstCond(find((frameTime > bData.stimSamps(n))==1));
    parsed.stimFrameTime(n)=firstCond(find(frameTime > bData.stimSamps(n)));
    parsed.contrast(n)=bData.contrasts(n);
    tempLick = find(bData.thresholdedLicks(bData.stimSamps(n):bData.stimSamps(n)+lickWindow)==1);
    % check to see if the animal licked in the window
    if numel(tempLick)>0
        % it licked
        parsed.lick(n) = 1;
        parsed.lickLatency(n) = tempLick(1) - bData.stimSamps(n);
        parsed.lickCount(n) = numel(tempLick);
        if parsed.contrast(n)>0
            parsed.response_hits(n) = 1;
            parsed.response_miss(n) = 0;
            parsed.response_fa(n) = NaN;
            parsed.response_cr(n) = NaN;
        elseif parsed.contrast(n) == 0
            parsed.response_fa(n) = 1;
            parsed.response_cr(n) = 0;
            parsed.response_hits(n) = NaN;
            parsed.response_miss(n) = NaN;
        end
    elseif numel(tempLick)==0
            parsed.lick(n) = 0;
            parsed.lickLatency(n) = NaN;
            parsed.lickCount(n) = 0;
            if parsed.contrast(n)>0
                parsed.response_hits(n) = 0;
                parsed.response_miss(n) = 1;
                parsed.response_fa(n) = NaN;
                parsed.response_cr(n) = NaN;
            elseif parsed.contrast(n) == 0
                parsed.response_fa(n) = 0;
                parsed.response_cr(n) = 1;
                parsed.response_hits(n) = NaN;
                parsed.response_miss(n) = NaN;
            end
    end
end
%% trigger things
preFr= 5;
postFr = 20;
triggeredF=hmTrigger(somaticF,parsed.stimFrame,[preFr,postFr],1,100);
triggeredDF=hmTrigger(somaticF_DF,parsed.stimFrame,[preFr,postFr],1,100);

% velocity is on the behavior time, so let's correct the pre/post frame
% window by scaling up the difference in samples 
sampFac = floor(frameDelta*1000);
triggeredVel=squeeze(hmTrigger(bData.velocity,bData.stimSamps,[preFr*sampFac,postFr*sampFac],1,100));


%% super basic HM comparisons
% for instance is velocity different?
%
% lets make a vector of all trials and then logically index
% start with all we did
parsed.allTrials = 1:numel(bData.stimSamps);
% now find just the HM trials, defined as either all hits or misses that
% aren't nans as those would be fa/cr trials
parsed.allHMTrials = allTrials(isnan(parsed.response_hits)==0);
% likewise all catch trials are trials where either hits or misses were
% nans
parsed.allCatchTrials = allTrials(isnan(parsed.response_hits)==1);

parsed.allHitTrials = intersect(parsed.allHMTrials,find(parsed.response_hits==1));
parsed.allMissTrials = intersect(parsed.allHMTrials,find(parsed.response_miss==1));
parsed.allFaTrials = intersect(parsed.allCatchTrials,find(parsed.response_fa==1));
parsed.allCrTrials = intersect(parsed.allCatchTrials,find(parsed.response_cr==1));

parsed.allHitVel = triggeredVel(:,allHitTrials);
parsed.allMissVel = triggeredVel(:,allMissTrials);

parsed.allHitF = triggeredF(:,:,allHitTrials);
parsed.allMissF = triggeredF(:,:,allMissTrials);


parsed.allHitDF = triggeredDF(:,:,allHitTrials);
parsed.allMissDF = triggeredDF(:,:,allMissTrials);
%% example: make a plot with errors (velocity)
inds=size(parsed.allHitVel,1);
hSem=std(parsed.allHitVel,1,2)./sqrt(numel(allHitTrials)-1);
mSem=std(parsed.allMissVel,1,2)./sqrt(numel(allMissTrials)-1);
tVec = (1:inds) - preFr*sampFac;
figure

boundedline(tVec,mean(parsed.allHitVel,2),...
    std(parsed.allHitVel,1,2),'cmap',[0,0.3,1],'transparency',0.1)
hold all
boundedline(tVec,mean(parsed.allMissVel,2),...
    std(parsed.allMissVel,1,2),'cmap',[1,0.3,0],'transparency',0.1)
    plot([0,0],[0.0,0.5],'k:')

%% example: make a plot for a cell with errors
cellNum = 4;
cellHit = squeeze(parsed.allHitDF(cellNum,:,:));
cellMiss = squeeze(parsed.allMissDF(cellNum,:,:));

inds=size(parsed.allHitDF,2);
hSem=nanstd(cellHit,1,2)./sqrt(numel(allHitTrials)-1);
mSem=nanstd(cellMiss,1,2)./sqrt(numel(allMissTrials)-1);
tVec = frameDelta:frameDelta:frameDelta*inds;
figure
boundedline(tVec,nanmean(cellMiss,2),...
    mSem,'cmap',[1,0.3,0],'transparency',0.1)
    plot([0,0],[0.0,0.5],'k:')
    hold all
boundedline(tVec,nanmean(cellHit,2),...
    hSem,'cmap',[0,0.3,1],'transparency',0.05)
hold all

%% compare contrast distributions
hCont = parsed.contrast(parsed.allHitTrials);
mCont = parsed.contrast(parsed.allMissTrials);
figure,nhist({hCont,mCont},'box')

%% look at hit miss on threshold contrasts
hitThreshContTrials = intersect(allHitTrials,find(parsed.contrast>18 & parsed.contrast<50))
missThreshContTrials = intersect(allMissTrials,find(parsed.contrast>18 & parsed.contrast<50))

parsed.thrHitDF = triggeredDF(:,:,hitThreshContTrials);
parsed.thrMissDF = triggeredDF(:,:,missThreshContTrials);

cellNum = 4;
cellHit = squeeze(parsed.allHitDF(cellNum,:,:));
cellMiss = squeeze(parsed.allMissDF(cellNum,:,:));

inds=size(parsed.allHitDF,2);
hSem=nanstd(cellHit,1,2)./sqrt(numel(hitThreshContTrials)-1);
mSem=nanstd(cellMiss,1,2)./sqrt(numel(missThreshContTrials)-1);
tVec = frameDelta:frameDelta:frameDelta*inds;
figure
boundedline(tVec,nanmean(cellMiss,2),...
    mSem,'cmap',[1,0.3,0],'transparency',0.1)
    plot([0,0],[0.0,0.5],'k:')
    hold all
boundedline(tVec,nanmean(cellHit,2),...
    hSem,'cmap',[0,0.3,1],'transparency',0.05)
% hold all

%% look at hit miss on high contrasts
hitHighContTrials = intersect(allHitTrials,find(parsed.contrast>60 & parsed.contrast<=100))
missHighContTrials = intersect(allMissTrials,find(parsed.contrast>60 & parsed.contrast<=100))

parsed.thrHitDF = triggeredDF(:,:,hitHighContTrials);
parsed.thrMissDF = triggeredDF(:,:,missHighContTrials);

cellNum = 4;
cellHit = squeeze(parsed.allHitDF(cellNum,:,:));
cellMiss = squeeze(parsed.allMissDF(cellNum,:,:));

inds=size(parsed.allHitDF,2);
hSem=nanstd(cellHit,1,2)./sqrt(numel(hitHighContTrials)-1);
mSem=nanstd(cellMiss,1,2)./sqrt(numel(missHighContTrials)-1);
tVec = frameDelta:frameDelta:frameDelta*inds;
figure
boundedline(tVec,nanmean(cellMiss,2),...
    mSem,'cmap',[1,0.3,0],'transparency',0.1)
    plot([0,0],[0.0,0.5],'k:')
    hold all
boundedline(tVec,nanmean(cellHit,2),...
    hSem,'cmap',[0,0.3,1],'transparency',0.05)
% hold all

%% Example ROC (detection) population
% start with pop distributions
preStim_hit = squeeze(trapz(parsed.thrHitDF(:,preFr-4:preFr-1,:),2));
postStim_hit = squeeze(trapz(parsed.thrHitDF(:,preFr+1:preFr+7,:),2));
preStim_miss = squeeze(trapz(parsed.thrMissDF(:,preFr-4:preFr-1,:),2));
postStim_miss = squeeze(trapz(parsed.thrMissDF(:,preFr+1:preFr+7,:),2));
evokedHit = postStim_hit-preStim_hit;
evokedMiss = postStim_miss-preStim_miss;
figure,nhist({preStim_hit,postStim_hit,preStim_miss,postStim_miss},'box')
figure,nhist({evokedHit,evokedMiss},'box')

%% now cell by cell (we pick)
cellNum = 1;
figure,nhist({evokedHit(cellNum,:),evokedMiss(cellNum,:)},'box')

%% now try perfcurve (built-in roc) this is DP
testCell = 6;

tVals = horzcat(evokedHit(testCell,:),evokedMiss(testCell,:));
tLabs = horzcat(ones(size(evokedHit(testCell,:))),zeros(size(evokedMiss(testCell,:))));
[aa,bb,~,cc]=perfcurve(tLabs,tVals,1);





%% sp is a bit different
noStim = find(parsed.contrast==0);
highStim = find(parsed.contrast==100);
% start with pop distributions
preStim_noStim = squeeze(trapz(triggeredDF(:,preFr-3:preFr-1,noStim),2));
postStim_noStim = squeeze(trapz(triggeredDF(:,preFr+1:preFr+5,noStim),2));

evoked_noStim = postStim_noStim-preStim_noStim;



preStim_highStim = squeeze(trapz(triggeredDF(:,preFr-4:preFr-1,highStim),2));
postStim_highStim = squeeze(trapz(triggeredDF(:,preFr+1:preFr+7,highStim),2));

evoked_highStim = postStim_highStim-preStim_highStim;

figure,nhist({abs(evoked_noStim),abs(evoked_highStim)},'box')

tVals = horzcat(evoked_highStim(testCell,:),evoked_noStim(testCell,:));
tLabs = horzcat(ones(size(evoked_highStim(testCell,:))),zeros(size(evoked_noStim(testCell,:))));
[aa,bb,~,cc]=perfcurve(tLabs,tVals,1);

%% all cell dp and sp

for n=1:size(somaticF,1)
    testCell = n;
    tVals = horzcat(evokedHit(testCell,:),evokedMiss(testCell,:));
    tLabs = horzcat(ones(size(evokedHit(testCell,:))),zeros(size(evokedMiss(testCell,:))));
    [aa,bb,~,cc]=perfcurve(tLabs,tVals,1);
    parsed.DP_thr(n)=cc;
    clear tVals tLabs cc
    tVals = horzcat(evoked_highStim(testCell,:),evoked_noStim(testCell,:));
    tLabs = horzcat(ones(size(evoked_highStim(testCell,:))),zeros(size(evoked_noStim(testCell,:))));
    [aa,bb,~,cc]=perfcurve(tLabs,tVals,1);
    parsed.SP_all(n)=cc;
    clear tVals tLabs cc
end

%% plot sp vs. dp not normed
figure,plot(parsed.SP_all,'ko')
hold all,plot(parsed.DP_thr,'bo')
figure,plot(parsed.SP_all,parsed.DP_thr,'o')

%% same but rel pred mag
figure,nhist({1-abs(0.5-parsed.SP_all),1-abs(0.5-parsed.DP_thr)},'box')
xlim([0.5,1.0])




