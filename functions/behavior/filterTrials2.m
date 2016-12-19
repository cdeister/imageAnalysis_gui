%% Filter Trials
close all
stimTimes=session.relative_trial_start_times;
stimAmps=session.stim_amplitude(1:numel(stimTimes));

%
gKern= normpdf([-100:100],0,20); 
gKern = gKern./max(gKern); 

trialFilter.boxWidth=fix(timingParams.numTrials./8);
gKern=ones(1,trialFilter.boxWidth)./trialFilter.boxWidth;

%ones(1,trialFilter.boxWidth)
% --- these are variables that one might want to change
trialFilter.preLickThreshold=-0.5; %(in seconds)
trialFilter.tooEarly=0.025; % licks that occur to early after the stim (in seconds)
trialFilter.smoothHit=nanconv(session.behavior.hits,gKern);
trialFilter.engThreshold=(max(trialFilter.smoothHit)-min(trialFilter.smoothHit))/2;
trialFilter.engThreshold=(trialFilter.engThreshold+min(trialFilter.smoothHit));
max(trialFilter.smoothHit)/3.5; %0.4;   %<--- the red line in the plot
trialFilter.engagedTrials=find(trialFilter.smoothHit>trialFilter.engThreshold);
trialFilter.smoothAmps=nanconv(session.stim_amplitude,gKern);
trialFilter.smoothDPrime=dprime(nanconv(session.behavior.hits,gKern),...
	nanconv(session.behavior.falsepos,gKern));
trialFilter.smoothCrit=crtiloc(nanconv(session.behavior.hits,gKern),...
	nanconv(session.behavior.falsepos,gKern));
%---- end user variables.

figure
subplot(1,2,1)
plot(trialFilter.smoothAmps',smooth(fixgaps(trialFilter.smoothCrit))','bo')
[aa,bb]=corr(trialFilter.smoothAmps',trialFilter.smoothHit')
ylim([0 1])

subplot(1,2,2)
plot(trialFilter.smoothAmps(trialFilter.engagedTrials)',smooth(fixgaps(trialFilter.smoothCrit(trialFilter.engagedTrials)))','ko')
[aa,bb]=corr(trialFilter.smoothAmps(trialFilter.engagedTrials)',trialFilter.smoothHit(trialFilter.engagedTrials)')
ylim([0 1])

figure
subplot(1,2,1)
plot(trialFilter.smoothAmps',trialFilter.smoothHit','bo')
[aa,bb]=corr(trialFilter.smoothAmps',trialFilter.smoothHit')
ylim([0 1])

subplot(1,2,2)
plot(trialFilter.smoothAmps(trialFilter.engagedTrials)',trialFilter.smoothHit(trialFilter.engagedTrials)','ko')
[aa,bb]=corr(trialFilter.smoothAmps(trialFilter.engagedTrials)',trialFilter.smoothHit(trialFilter.engagedTrials)')
ylim([0 1])

%---------------------

%
for n=1:numel(session.trial_start_times),
    trialFilter.preLickNumberByTrial(:,n)= ...
        numel(find(session.lick_times{1,n}>=trialFilter.preLickThreshold & ...
        session.lick_times{1,n}<0.02));
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

trialFilter.smoothCrit(isinf(trialFilter.smoothCrit))=NaN;
interpCrit=fixgaps(trialFilter.smoothCrit);
figure,plot(interpCrit)


clipSmoothHit=trialFilter.smoothHit(isnan(interpCrit)==0);
clipSmoothCrit=interpCrit(isnan(interpCrit)==0);

figure,plot(clipSmoothCrit./min(clipSmoothCrit))
hold all,plot(clipSmoothHit)
[aaaD nnnD]=corr(clipSmoothCrit',clipSmoothHit')
figure,plot(clipSmoothCrit)

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


psychometrics.fitCurve_x=0:0.5:max(-1*psychometrics.stimAmplitudes);

f = fit(-1*psychometrics.stimAmplitudes(find(isnan(psychometrics.hitRate)==0))',psychometrics.normHitRate,bFit,'Robust','on','StartPoint', [12 6]);
psychometrics.normCurve_y=1./(1+exp((f.v5-psychometrics.fitCurve_x)/f.k));
psychometrics.nonNormCurve_y=psychometrics.normCurve_y*max(smooth(psychometrics.hitRate'));

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
psychometrics.unfiltered.hitRate(:,numel(sB)+1)=numel(find(trialFilter.rejectTrials==0))/...
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


psychometrics.unfiltered.fitCurve_x=0:0.5:max(-1*psychometrics.unfiltered.stimAmplitudes);

f = fit(-1*psychometrics.unfiltered.stimAmplitudes(find(isnan(psychometrics.unfiltered.hitRate)==0))',psychometrics.unfiltered.normHitRate,bFit,'Robust','on','StartPoint', [12 6]);
psychometrics.unfiltered.normCurve_y=1./(1+exp((f.v5-psychometrics.unfiltered.fitCurve_x)/f.k));
psychometrics.unfiltered.nonNormCurve_y=psychometrics.unfiltered.normCurve_y*max(smooth(psychometrics.unfiltered.hitRate'));

% now plot the stimulus response function (psychometric curve)
% figure,plot(-1*psychometrics.unfiltered.stimAmplitudes(find(isnan(psychometrics.unfiltered.nonNormHitRate)==0)),psychometrics.unfiltered.normHitRate,'ko')
% hold all,plot(psychometrics.unfiltered.fitCurve_x,psychometrics.unfiltered.normCurve_y,'r-')
psychometrics.unfiltered.threshold=f.v5;
psychometrics.unfiltered.slope=f.k;
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


%%
if isnan(psychometrics.threshold)==0

figure
subplot(1,2,1)
plot(-1*psychometrics.stimAmplitudes,psychometrics.nonNormHitRate,'bo')
hold all,plot(psychometrics.fitCurve_x,psychometrics.nonNormCurve_y,'b-')
hold all,plot(-1*psychometrics.unfiltered.stimAmplitudes,psychometrics.unfiltered.nonNormHitRate,'ro')
hold all,plot(psychometrics.unfiltered.fitCurve_x,psychometrics.unfiltered.nonNormCurve_y,'r-')
ylim([0 1])
ylabel('hit rate')
xlabel('stimulus amplitude')
title('raw curves')
legend('engaged','engaged fit','unfiltered','unfiltered fit')


subplot(1,2,2)
plot(-1*psychometrics.stimAmplitudes,psychometrics.normHitRate,'bo')
hold all,plot(psychometrics.fitCurve_x,psychometrics.normCurve_y,'b-')
hold all,plot(-1*psychometrics.unfiltered.stimAmplitudes,psychometrics.unfiltered.normHitRate,'ro')
hold all,plot(psychometrics.unfiltered.fitCurve_x,psychometrics.unfiltered.normCurve_y,'r-')
ylim([0 1])
ylabel('hit rate')
xlabel('stimulus amplitude')
title('normalized curves')
legend(['engaged only; dprime=' num2str(trialFilter.dPrimeEst,'%.2f')],['engaged fit; thresh=' num2str(psychometrics.threshold,'%.2f')],['unfiltered; dprime=' num2str(analyzedBehavior.dPrimeEstimate,'%.2f')],['unfiltered fit; thresh=' num2str(psychometrics.unfiltered.threshold,'%.2f')],'Location','southwest')

else
    disp('fits no good; too few trials')
end


