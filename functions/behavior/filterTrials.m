%% Filter Trials
stimTimes=session.relative_trial_start_times;
stimAmps=session.stim_amplitude(1:numel(stimTimes));

% Smooth the responses in order to determine trends in engagement.
trialFilter.binWidth = 50;
trialFilter.convKern = normpdf(-1*fix(trialFilter.binWidth/2):fix(trialFilter.binWidth/2),...
    0,((trialFilter.binWidth)/10)); 
trialFilter.convKern = trialFilter.convKern./sum(trialFilter.convKern); 
% trialFilter.boxWidth=fix(timingParams.numTrials./10);
% f=ones(1,trialFilter.boxWidth);

% --- these are variables that one might want to change
trialFilter.preLickThreshold=-0.5; %(in seconds)
trialFilter.tooEarly=0.05; % licks that occur to early after the stim (in seconds)
%---- end user variables.

trialFilter.smoothHit=nanconv(session.behavior.hits,trialFilter.convKern);
trialFilter.engThreshold=((max(trialFilter.smoothHit)-min(trialFilter.smoothHit))/3)+min(trialFilter.smoothHit); %0.4;   %<--- the red line in the plot
trialFilter.engagedTrials=find(trialFilter.smoothHit>trialFilter.engThreshold);
trialFilter.disengagedTrials=find(trialFilter.smoothHit<=trialFilter.engThreshold);
trialFilter.smoothCrit=crtiloc(nanconv(session.behavior.hits,trialFilter.convKern),nanconv(session.behavior.falsepos,trialFilter.convKern));



%
for n=1:numel(session.trial_start_times)
    trialFilter.preLickNumberByTrial(:,n)= ...
        numel(find(session.lick_times{1,n}>=trialFilter.preLickThreshold & session.lick_times{1,n}<trialFilter.tooEarly));
end

trialFilter.trialsWithPreLicks=find(trialFilter.preLickNumberByTrial>0);
trialFilter.trialsWithNoPreLicks=find(trialFilter.preLickNumberByTrial==0);


% keep trials with no pre-stim licking and enganged.
trialFilter.engagedNoLickTrials=intersect(trialFilter.engagedTrials,trialFilter.trialsWithNoPreLicks);

trialFilter.hitTrials=analyzedBehavior.hitTrials(find(trialFilter.engagedNoLickTrials & session.optical_stim_amplitudes(trialFilter.engagedNoLickTrials)==0));
trialFilter.rejectTrials=analyzedBehavior.rejectTrials(find(trialFilter.engagedNoLickTrials & session.optical_stim_amplitudes(trialFilter.engagedNoLickTrials)==0));
trialFilter.stimAmps=stimAmps(find(trialFilter.engagedNoLickTrials & session.optical_stim_amplitudes(trialFilter.engagedNoLickTrials)==0));
trialFilter.stimTimes=stimTimes(find(trialFilter.engagedNoLickTrials & session.optical_stim_amplitudes(trialFilter.engagedNoLickTrials)==0));
trialFilter.reactionTimes=analyzedBehavior.reactionTimes(find(trialFilter.engagedNoLickTrials & session.optical_stim_amplitudes(trialFilter.engagedNoLickTrials)==0));


trialFilter.disengaged.hitTrials=analyzedBehavior.hitTrials(find(trialFilter.engagedNoLickTrials & session.optical_stim_amplitudes(trialFilter.engagedNoLickTrials)==0));
trialFilter.disengaged.rejectTrials=analyzedBehavior.rejectTrials(find(trialFilter.engagedNoLickTrials & session.optical_stim_amplitudes(trialFilter.engagedNoLickTrials)==0));
trialFilter.disengaged.stimAmps=stimAmps(find(trialFilter.engagedNoLickTrials & session.optical_stim_amplitudes(trialFilter.engagedNoLickTrials)==0));
trialFilter.disengaged.stimTimes=stimTimes(find(trialFilter.engagedNoLickTrials & session.optical_stim_amplitudes(trialFilter.engagedNoLickTrials)==0));
trialFilter.disengaged.reactionTimes=analyzedBehavior.reactionTimes(find(trialFilter.engagedNoLickTrials & session.optical_stim_amplitudes(trialFilter.engagedNoLickTrials)==0));
% trialFilter.hitTrials=analyzedBehavior.hitTrials(find(trialFilter.engagedNoLickTrials));
% trialFilter.rejectTrials=analyzedBehavior.rejectTrials(find(trialFilter.engagedNoLickTrials));
% trialFilter.stimAmps=stimAmps(find(trialFilter.engagedNoLickTrials));
% trialFilter.stimTimes=stimTimes(find(trialFilter.engagedNoLickTrials));
% trialFilter.reactionTimes=analyzedBehavior.reactionTimes(find(trialFilter.engagedNoLickTrials));

figure
subplot(2,2,1)
hold all
for i=1:timingParams.numTrials
    plot(session.lick_times{i},ones(1,numel(session.lick_times{i}))*i,'.k')
end
plot([0 0],[1 timingParams.numTrials],'r-')
xlim([-0.5 2]),title('Your Original Trials')
tempGCA=gca;
set(tempGCA, 'Ydir', 'reverse');
ylabel('trial number')
xlabel('time relative to stim (sec)')

subplot(2,2,2)
hold all
for i=1:numel(trialFilter.engagedNoLickTrials)
    plot(session.lick_times{trialFilter.engagedNoLickTrials(i)},ones(1,numel(session.lick_times{trialFilter.engagedNoLickTrials(i)}))*i,'.k')
end
plot([0 0],[1 timingParams.numTrials],'r-')
xlim([-0.5 2]),title(['Your ' num2str(numel(trialFilter.engagedNoLickTrials)) 'Filtered Trials'])
tempGCA=gca;
set(tempGCA, 'Ydir', 'reverse');
ylim([1 timingParams.numTrials])
ylabel('trial number')
xlabel('time relative to stim (sec)')

clear tempGCA

subplot(2,2,3:4)
plot(trialFilter.smoothHit)
hold all,plot([1 timingParams.numTrials],[trialFilter.engThreshold trialFilter.engThreshold])
ylim([0 1])
ylabel('response rate')
xlabel('trial number')
title('engagement threshold and convolved hits')
legend('smoothed hit raster','engagement threshold')

figure,plot(crtiloc(nanconv(session.behavior.hits,ones(1,trialFilter.binWidth)),...
	nanconv(session.behavior.falsepos,ones(1,trialFilter.binWidth))))


%% Make Psychometric Curve After

psychometrics.stimBoundaries=[-7,-4,-3,-1.75,-0.05];

% temp
sA=trialFilter.stimAmps;
hT=trialFilter.hitTrials;
hR=trialFilter.rejectTrials;
sB=psychometrics.stimBoundaries;

psychometrics.stimAmplitudes=psychometrics.stimBoundaries;
psychometrics.hitRate=zeros(size(psychometrics.stimBoundaries));
psychometrics.stimAmplitudes(:,1)=sB(1);
h=numel(find(hT==1 & sA'==sB(1)));
m=numel(find(hT==0 & sA'==sB(1)));
psychometrics.hitRate(:,1)=h/(h+m);
psychometrics.weights(:,1)=(h+m);

for n=2:numel(sB)
    psychometrics.stimAmplitudes(:,n)=mean(sA(find(sA>sB(n-1) & sA<=sB(n))));
    h=numel(find(hT==1 & sA'>sB(n-1) & sA'<=sB(n)));
    m=numel(find(hT==0 & sA'>sB(n-1) & sA'<=sB(n)));
    psychometrics.hitRate(:,n)=h/(h+m);
    psychometrics.weights(:,n)=(h+m);
end



psychometrics.stimAmplitudes(:,numel(sB)+1)=0;
psychometrics.hitRate(:,numel(sB)+1)=numel(find(trialFilter.rejectTrials==0))/...
    numel(find(trialFilter.rejectTrials==0 | trialFilter.rejectTrials==1));
psychometrics.weights(:,numel(sB)+1)=(h+m);
psychometrics.stimAmplitudes(find(isnan(psychometrics.stimAmplitudes)))=psychometrics.stimBoundaries(find(isnan(psychometrics.stimAmplitudes)));

if numel(find(isnan(psychometrics.hitRate) | psychometrics.hitRate==0))>=4
    badFitFlag=1;
else
    badFitFlag=0;
end
% 

h=numel(find(hT==1));
m=numel(find(hT==0));
f=numel(find(hR==0));
r=numel(find(hR==1));

trialFilter.dPrimeEst=norminv(h/(h+m))-norminv(f/(f+r));


clear('sA','hT','hR','sB','h','m','f','r')

if badFitFlag==0
bFit = fittype('1/(1+exp((v5-x)/k))',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'v5','k'});


psychometrics.nonNormHitRate=smooth(psychometrics.hitRate(find(isnan(psychometrics.hitRate)==0))');
psychometrics.normHitRate=smooth(psychometrics.nonNormHitRate./max(psychometrics.nonNormHitRate));


psychometrics.fitCurve_x=0:0.1:max(-1*psychometrics.stimAmplitudes);

f = fit(-1*psychometrics.stimAmplitudes(find(isnan(psychometrics.hitRate)==0))',psychometrics.nonNormHitRate,bFit,'Robust','on','StartPoint', [12 6]);
fN = fit(-1*psychometrics.stimAmplitudes(find(isnan(psychometrics.hitRate)==0))',psychometrics.normHitRate,bFit,'Robust','on','StartPoint', [12 6]);

psychometrics.normCurve_y=1./(1+exp((f.v5-psychometrics.fitCurve_x)/f.k));
psychometrics.nonNormCurve_y=1./(1+exp((fN.v5-psychometrics.fitCurve_x)/fN.k));

% now plot the stimulus response function (psychometric curve)
% figure,plot(-1*psychometrics.stimAmplitudes(find(isnan(psychometrics.nonNormHitRate)==0)),psychometrics.normHitRate,'ko')
% hold all,plot(psychometrics.fitCurve_x,psychometrics.normCurve_y,'r-')
psychometrics.threshold=f.v5;
psychometrics.slope=f.k;
if timingParams.numTrials<20;
    psychometrics.threshold=NaN;
    psychometrics.slope=NaN;
else
end


tNn=find(isnan(psychometrics.hitRate)==0);
tNy=find(isnan(psychometrics.hitRate)==1);

psychometrics.normHitRate(tNn)=psychometrics.normHitRate;
psychometrics.normHitRate(tNy)=NaN;
psychometrics.nonNormHitRate(tNn)=psychometrics.nonNormHitRate;
psychometrics.nonNormHitRate(tNy)=NaN;
clear tNn tNy

elseif badFitFlag==1
    psychometrics.threshold=NaN;
    psychometrics.slope=NaN;
    psychometrics.normHitRate=[NaN NaN NaN NaN NaN NaN];
    psychometrics.nonNormHitRate=[NaN NaN NaN NaN NaN NaN];
    psychometrics.fitCurve_x=0:0.5:max(-1*psychometrics.stimAmplitudes);
    psychometrics.normCurve_y=NaN(size(psychometrics.fitCurve_x));
    psychometrics.nonNormCurve_y=NaN(size(psychometrics.fitCurve_x));
end
 

psychometrics.f_threshold=f.v5;
psychometrics.f_slope=f.k;

psychometrics.f_nthreshold=fN.v5;
psychometrics.f_nslope=fN.k;

%% Make Psychometric Curve Before

psychometrics.unfiltered.stimBoundaries=[-7,-4,-3,-1.75,-0.05];

% temp
sA=stimAmps;
hT=analyzedBehavior.hitTrials;
hR=analyzedBehavior.rejectTrials;
sB=psychometrics.unfiltered.stimBoundaries;

psychometrics.unfiltered.stimAmplitudes=psychometrics.unfiltered.stimBoundaries;
psychometrics.unfiltered.hitRate=zeros(size(psychometrics.unfiltered.stimBoundaries));
psychometrics.unfiltered.stimAmplitudes(:,1)=sB(1);
h=numel(find(hT==1 & sA'==sB(1)));
m=numel(find(hT==0 & sA'==sB(1)));
psychometrics.unfiltered.hitRate(:,1)=h/(h+m);
psychometrics.unfiltered.weights(:,1)=(h+m);

for n=2:numel(sB)
    psychometrics.unfiltered.stimAmplitudes(:,n)=mean(sA(find(sA>sB(n-1) & sA<=sB(n))));
    h=numel(find(hT==1 & sA'>sB(n-1) & sA'<=sB(n)));
    m=numel(find(hT==0 & sA'>sB(n-1) & sA'<=sB(n)));
    psychometrics.unfiltered.hitRate(:,n)=h/(h+m);
    psychometrics.unfiltered.weights(:,n)=(h+m);
end

if numel(find(isnan(psychometrics.unfiltered.hitRate) | psychometrics.unfiltered.hitRate==0))>=4
    badFitFlag=1;
else
    badFitFlag=0;
end
% 
psychometrics.unfiltered.stimAmplitudes(:,numel(sB)+1)=0;
psychometrics.unfiltered.hitRate(:,numel(sB)+1)=numel(find(analyzedBehavior.rejectTrials==0))/...
    numel(find(trialFilter.rejectTrials==0 | trialFilter.rejectTrials==1));
psychometrics.unfiltered.weights(:,numel(sB)+1)=(h+m);
psychometrics.unfiltered.stimAmplitudes(find(isnan(psychometrics.unfiltered.stimAmplitudes)))=psychometrics.unfiltered.stimBoundaries(find(isnan(psychometrics.unfiltered.stimAmplitudes)));


h=numel(find(hT==1));
m=numel(find(hT==0));
f=numel(find(hR==0));
r=numel(find(hR==1));

clear('sA','hT','hR','sB','h','m','f','r')

if badFitFlag==0
bFit = fittype('1/(1+exp((v5-x)/k))',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'v5','k'});


psychometrics.unfiltered.nonNormHitRate=smooth(psychometrics.unfiltered.hitRate(find(isnan(psychometrics.unfiltered.hitRate)==0))');
psychometrics.unfiltered.normHitRate=smooth(psychometrics.unfiltered.nonNormHitRate./max(psychometrics.unfiltered.nonNormHitRate));


psychometrics.unfiltered.fitCurve_x=0:0.1:max(-1*psychometrics.unfiltered.stimAmplitudes);

f = fit(-1*psychometrics.unfiltered.stimAmplitudes(find(isnan(psychometrics.unfiltered.hitRate)==0))',psychometrics.unfiltered.nonNormHitRate,bFit,'Robust','on','StartPoint', [12 6]);
fN = fit(-1*psychometrics.unfiltered.stimAmplitudes(find(isnan(psychometrics.unfiltered.hitRate)==0))',psychometrics.unfiltered.normHitRate,bFit,'Robust','on','StartPoint', [12 6]);

psychometrics.unfiltered.normCurve_y=1./(1+exp((f.v5-psychometrics.unfiltered.fitCurve_x)/f.k));
psychometrics.unfiltered.nonNormCurve_y=1./(1+exp((fN.v5-psychometrics.unfiltered.fitCurve_x)/fN.k));

% now plot the stimulus response function (psychometric curve)
% figure,plot(-1*psychometrics.unfiltered.stimAmplitudes(find(isnan(psychometrics.unfiltered.nonNormHitRate)==0)),psychometrics.unfiltered.normHitRate,'ko')
% hold all,plot(psychometrics.unfiltered.fitCurve_x,psychometrics.unfiltered.normCurve_y,'r-')
psychometrics.unfiltered.threshold=f.v5;
psychometrics.unfiltered.slope=f.k;

psychometrics.unfiltered.nthreshold=fN.v5;
psychometrics.unfiltered.nslope=fN.k;

if timingParams.numTrials<20;
    psychometrics.unfiltered.threshold=NaN;
    psychometrics.unfiltered.slope=NaN;
else
end


tNn=find(isnan(psychometrics.unfiltered.hitRate)==0);
tNy=find(isnan(psychometrics.unfiltered.hitRate)==1);

psychometrics.unfiltered.normHitRate(tNn)=psychometrics.unfiltered.normHitRate;
psychometrics.unfiltered.normHitRate(tNy)=NaN;
psychometrics.unfiltered.nonNormHitRate(tNn)=psychometrics.unfiltered.nonNormHitRate;
psychometrics.unfiltered.nonNormHitRate(tNy)=NaN;
clear tNn tNy

elseif badFitFlag==1
    psychometrics.unfiltered.threshold=NaN;
    psychometrics.unfiltered.slope=NaN;
    psychometrics.unfiltered.normHitRate=[NaN NaN NaN NaN NaN NaN];
    psychometrics.unfiltered.nonNormHitRate=[NaN NaN NaN NaN NaN NaN];
    psychometrics.unfiltered.fitCurve_x=0:0.5:max(-1*psychometrics.unfiltered.stimAmplitudes);
    psychometrics.unfiltered.normCurve_y=NaN(size(psychometrics.unfiltered.fitCurve_x));
    psychometrics.unfiltered.nonNormCurve_y=NaN(size(psychometrics.unfiltered.fitCurve_x));
end
 


%% ratio of pre-lick to none
trialFilter.lickNoLickRatio=numel(trialFilter.trialsWithPreLicks)./numel(trialFilter.trialsWithNoPreLicks);

%% strong vs. weak dprime
% find weak and strong trials
clear strongHits strongMisses weakHits weakMisses fAs cRs
strongResponses=find(trialFilter.stimAmps<-6.5);
weakResponses=find(trialFilter.stimAmps>-3.5 & trialFilter.stimAmps<=-0.5);
noiseResponses=find(trialFilter.stimAmps==0);

strongHits=find(trialFilter.hitTrials(strongResponses)==1);
strongMisses=find(trialFilter.hitTrials(strongResponses)==0);
weakHits=find(trialFilter.hitTrials(weakResponses)==1);
weakMisses=find(trialFilter.hitTrials(weakResponses)==0);
fAs=find(trialFilter.rejectTrials(noiseResponses)==0);
cRs=find(trialFilter.rejectTrials(noiseResponses)==1);


psychometrics.rt_all=nanmean(trialFilter.reactionTimes(([strongHits; weakHits])));
psychometrics.rt_weak=nanmean(trialFilter.reactionTimes(weakHits));
psychometrics.rt_strong=nanmean(trialFilter.reactionTimes(strongHits));
psychometrics.rt_fa=nanmean(trialFilter.reactionTimes(fAs));


if numel(fAs)==0
    fAs=[999];
else
end
sHR=numel(strongHits)/(numel(strongHits)+numel(strongMisses));
wHR=numel(weakHits)/(numel(weakHits)+numel(weakMisses));
fAR=numel(fAs)/(numel(fAs)+numel(cRs));

if wHR==0 || isnan(wHR)
    wHR=0.001;
else
end

if sHR==0 || isnan(sHR)
    sHR=0.001;
else
end

if fAR==0 || isnan(fAR)
    fAR=0.001;
else
end

if wHR==1
    wHR=0.999;
else
end

if sHR==1
    sHR=0.999;
else
end

if fAR==1
    fAR=0.999;
else
end


psychometrics.strongDP=norminv(sHR)...
    -norminv(fAR)
psychometrics.weakDP=norminv(wHR)...
    -norminv(fAR)

if numel(strongResponses)<6
    psychometrics.strongDP=NaN;
else
end

if numel(weakResponses)<6
    psychometrics.weakDP=NaN;
else
end

%%
if isnan(psychometrics.threshold)==0

figure
subplot(1,2,1)
plot(-1*psychometrics.stimAmplitudes,psychometrics.nonNormHitRate,'bo')
hold all,plot(psychometrics.fitCurve_x,psychometrics.normCurve_y,'b-')
hold all,plot(-1*psychometrics.unfiltered.stimAmplitudes,psychometrics.unfiltered.nonNormHitRate,'ro')
hold all,plot(psychometrics.unfiltered.fitCurve_x,psychometrics.unfiltered.normCurve_y,'r-')
ylim([0 1])
ylabel('hit rate')
xlabel('stimulus amplitude')
title('raw curves')
legend('engaged','engaged fit','unfiltered','unfiltered fit')


subplot(1,2,2)
plot(-1*psychometrics.stimAmplitudes,psychometrics.normHitRate,'bo')
hold all,plot(psychometrics.fitCurve_x,psychometrics.nonNormCurve_y,'b-')
hold all,plot(-1*psychometrics.unfiltered.stimAmplitudes,psychometrics.unfiltered.normHitRate,'ro')
hold all,plot(psychometrics.unfiltered.fitCurve_x,psychometrics.unfiltered.nonNormCurve_y,'r-')
ylim([0 1])
ylabel('hit rate')
xlabel('stimulus amplitude')
title('normalized curves')
legend(['engaged only; dprime=' num2str(trialFilter.dPrimeEst,'%.2f')],['engaged fit; thresh=' num2str(psychometrics.threshold,'%.2f')],['unfiltered; dprime=' num2str(analyzedBehavior.dPrimeEstimate,'%.2f')],['unfiltered fit; thresh=' num2str(psychometrics.unfiltered.threshold,'%.2f')],'Location','southwest')

else
    disp('fits no good; too few trials')
end

%%
shiftVals.n_slopeDif=psychometrics.f_nslope-psychometrics.unfiltered.nslope;
shiftVals.slopeDif=psychometrics.f_slope-psychometrics.unfiltered.slope;

shiftVals.n_threshDif=psychometrics.f_nthreshold-psychometrics.unfiltered.nthreshold;
shiftVals.threshDif=psychometrics.f_threshold-psychometrics.unfiltered.threshold;

shiftVals.maxDif=max(psychometrics.hitRate)-max(psychometrics.unfiltered.hitRate);
shiftVals.faDif=psychometrics.hitRate(end)-psychometrics.unfiltered.hitRate(end)



%%
deets = [psychometrics.threshold,psychometrics.slope,psychometrics.f_threshold,psychometrics.f_slope,psychometrics.f_nthreshold,psychometrics.f_nslope,psychometrics.rt_all,psychometrics.rt_weak,psychometrics.rt_strong,psychometrics.rt_fa,psychometrics.strongDP,psychometrics.weakDP]