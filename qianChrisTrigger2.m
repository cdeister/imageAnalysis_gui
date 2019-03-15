%% once you have somaticF data and neuropilF data you can correct.
somaticF_original = somaticF;
somaticF = somaticF - (0.80*neuropilF);


% add an offset, so we don't get negative values for df/f
% the offset will affect df/f so we will rescale later by the error. 
% the error is the ratio of the original mean and the scalar.
somaticF = somaticF + 10000;

%% once we have df/f we fix
scaleError = 10000/nanmean(nanmean(somaticF_original));
somaticF_DF=somaticF_DF*scaleError;
somaticF_DFBU=somaticF_DF;

%% first we figure out when each trial's first frame actually starts
% we will import each trial, detect the first frame trigger and log the
% frame that was in.

channel_2pFrames = 5;
behavoiorSampleRate = 1/session.Hz;

numTrials = session.current_trial;
firstTrial = session.start_trial+1;

for n=firstTrial:firstTrial+(numTrials-1)
    eval(['load("trial_' num2str(n) '.mat");'])
    
    tempCross = find(diff(data(:,5))<-0.5);
    firstFrame_BehaviorSample = tempCross(1)+1;
    secondFrame_BehaviorSample = tempCross(2)+1;

    firstFrameTime(n-(firstTrial-1)) = firstFrame_BehaviorSample*behavoiorSampleRate;
    clear data tempCross
end
disp('finished calculating offsets')
% firstFrameTime is the delay in seconds that it took the 2p to actually
% start scanning after it received our trigger. 

%% make frame clock
framesPerTrial = 70;
frameInterval = 0.100151818131243;
% 0.108262479936572
frameClock = frameInterval:frameInterval:framesPerTrial*frameInterval;
% add the offset
frameClock = frameClock+firstFrameTime(1);

%% other behavior variables (shouldn't need to change)
syncDur = session.sync_duration;
syncTimes = session.relative_trial_start_times;
stimTimes = (syncTimes+syncDur)+0.001;

%% group f by trials and trigger
% cell x frame x trial
% thus, cell2's 2nd trial is addressed as:
% squeeze(trialF(2,:,2))
clear trigF trialF
fData = somaticF_DF;
bFrames = 12;
sFrames = 30;


trialClock = frameInterval:frameInterval:(bFrames+sFrames)*frameInterval;

for n =1:numTrials
    trialF(:,:,n) = fData(:,((n-1)*framesPerTrial)+1:n*framesPerTrial);
    tFrame = floor((stimTimes(n)/frameInterval)+firstFrameTime(n));
    tFrame = tFrame + ((n-1)*framesPerTrial);
    trigF(:,:,n) = fData(:,tFrame-bFrames:tFrame+(sFrames-1));
end

figure,plot(squeeze(trigF(:,:,1))')
hold all,plot([bFrames-1 bFrames-1],[-1 3],'r-')

%% now we look for stimulus cells:

stimAmp = -9;
stimAmp2 = -5;
% stimAmp = -5;
% stimAmp2 = -3;
% stimAmp = -2;
% stimAmp2 = -0.5;


% session.stim_amplitude = session.stim_amplitude(1:190)
trialsWithStim1 =find(session.stim_amplitude >= stimAmp);
trialsWithStim2 =find(session.stim_amplitude < stimAmp2);
trialsWithStim = intersect(trialsWithStim1,trialsWithStim2);
trialsWithNoStim =find(session.stim_amplitude == 0);

baselineFrames = 4:9;
stimFrames = 12:18;
% 18 for inter
numCells = size(somaticF,1);

% we can now integrate in the baseline window and stim window
for n=1:numCells
    baselineMeans(n,:) = trapz(squeeze(trigF(n,baselineFrames,:)));
    stimMeans(n,:) = trapz(squeeze(trigF(n,stimFrames,:)));
end
stimDelta = stimMeans(:,:)-baselineMeans(:,:);
figure,nhist({baselineMeans,stimMeans,stimMeans-baselineMeans},'box')

%% now lets do stats
clear stimPVals
for n=1:numCells
    withStim = stimDelta(n,trialsWithStim);
    withNoStim = stimDelta(n,trialsWithNoStim);
    stimPVals(n) = bootStrapDifferences(withStim,withNoStim,1000);
    clear withStim withNoStim
    if mod(n,10)==0
        disp(['finished cell ' num2str(n) ' of ' num2str(numCells)])
    else
    end
end

stimCutOff = 0.05;
stimulusResponsiveCells = find(stimPVals<stimCutOff);

%% now we can look at the responsive cells

clear stimPSTH nostimPSTH zPSTH
for n=1:numel(stimulusResponsiveCells)
    stimPSTH(:,n) = mean(squeeze(trigF(stimulusResponsiveCells(n),:,trialsWithStim)),2);
    nostimPSTH(:,n) = mean(squeeze(trigF(stimulusResponsiveCells(n),:,trialsWithNoStim)),2);

end

zPSTH = (stimPSTH-repmat(median(nostimPSTH),42,1))./repmat(std(nostimPSTH),42,1);
evokedScore = trapz(zPSTH(13:22,:))-trapz(zPSTH(2:8,:));
figure
pBounds = [0 2];
subplot(1,2,1)
hold all
plot(trialClock,nostimPSTH,'o-')
ylim([0 pBounds(2)])
plot([trialClock(bFrames-2) trialClock(bFrames-1)],[0 pBounds(2)],'k:')
title('without stim')
subplot(1,2,2)
hold all
plot(trialClock,stimPSTH,'o-')
ylim([0 pBounds(2)])
plot([trialClock(bFrames-2) trialClock(bFrames-1)],[0 pBounds(2)],'k:')
title('with stim')
