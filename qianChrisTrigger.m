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

    firstFrameTime(n-(firstTrial-1)) = firstFrame_BehaviorSample*behavoiorSampleRate;
    clear data tempCross
end
disp('finished calculating offsets')
% firstFrameTime is the delay in seconds that it took the 2p to actually
% start scanning after it received our trigger. 

%% make frame clock
framesPerTrial = 60;
frameInterval = 0.121786770904064;
frameClock = frameInterval:frameInterval:framesPerTrial*frameInterval;
% add the offset
frameClock = frameClock+firstFrameTime(1);

%% other behavior variables (shouldn't need to change)
syncDur = session.sync_duration;
syncTimes = session.relative_trial_start_times;
stimTimes = (syncTimes+syncDur)+0.001;


%% once you have somaticF data and neuropilF data you can correct.
somaticF_original = somaticF;
somaticF = somaticF - (0.8*neuropilF);
% add an offset, so we don't get negative values for df/f
% the offset will affect df/f so we will rescale later by the error. 
% the error is the ratio of the original mean and the scalar.
somaticF = somaticF + 10000;

%% once we have df/f we fix
scaleError = 10000/mean(mean(somaticF_original));
somaticF_DF=somaticF_DF*scaleError;


fData = somaticF_DF;


%% group f by trials
% cell x frame x trial
% thus, cell2's 2nd trial is addressed as:
% squeeze(trialF(2,:,2))

for n =1:numTrials
    trialF(:,:,n) = fData(:,((n-1)*framesPerTrial)...
    +1:n*framesPerTrial);
end

%% example: single trial for a single cell
exampleTrial = 2;
exampleCell = 20;
figure
plot(frameClock,squeeze(trialF(exampleCell,:,exampleTrial)))
hold all
plot([stimTimes(exampleTrial) stimTimes(exampleTrial)],[0 1],'r-')

%% example: all trials for a single cell
exampleCell = 4;
figure
hold all
for n=1:numTrials
    plot(frameClock,squeeze(trialF(exampleCell,:,n)))
end
hold all
plot([stimTimes(exampleTrial) stimTimes(exampleTrial)],[0 1],'r-')


%% example: take mean for a cells 
exampleCell = 30;
exampleMean = mean(squeeze(trialF(exampleCell,:,:)),2);

figure
plot(frameClock,exampleMean)
hold all
plot([stimTimes(exampleTrial) stimTimes(exampleTrial)],[0 0.4],'r-')

%% example: take mean for a cell, but only max stim amps

exampleCell = 19;
stimAmp = -4;
trialsWithStim =find(session.stim_amplitude <= stimAmp);
trialsWithNoStim =find(session.stim_amplitude == 0);

exampleMeanBig = mean(squeeze(trialF(exampleCell,:,trialsWithStim)),2);
exampleMeanNone = mean(squeeze(trialF(exampleCell,:,trialsWithNoStim)),2);

figure
plot(frameClock,exampleMeanBig,'k-')
hold all
plot(frameClock,exampleMeanNone,'b-')
plot([stimTimes(exampleTrial) stimTimes(exampleTrial)],[0 0.4],'r-')

%% now we look for stimulus cells:
baselineFrames = 11:16;
stimFrames = 27:31;
numCells = size(somaticF,1);

% we can now integrate in the baseline window and stim window
for n=1:numCells
    baselineMeans(n,:) = trapz(squeeze(trialF(n,baselineFrames,:)));
    stimMeans(n,:) = trapz(squeeze(trialF(n,stimFrames,:)));
end

%% now look at difference in baseline and stimulus window 
% with and without stims
stimDelta = stimMeans(:,:)-baselineMeans(:,:);

% now we can filter by stim amplitude
exampleCell = 11;
withStim = stimDelta(exampleCell,trialsWithStim);
withNoStim = stimDelta(exampleCell,trialsWithNoStim);


% plot the distributions, one should be to the right
figure,nhist({withNoStim,withStim},'box')

%% now lets do stats

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


for n=1:numel(stimulusResponsiveCells)
    stimPSTH(:,n) = mean(squeeze(trialF(stimulusResponsiveCells(n),:,trialsWithStim)),2);
    nostimPSTH(:,n) = mean(squeeze(trialF(stimulusResponsiveCells(n),:,trialsWithNoStim)),2);
end


figure

subplot(1,2,1)
hold all
plot(frameClock,nostimPSTH)
ylim([0 0.75])
plot([2 2],[0 0.75],'k:')
title('without stim')
subplot(1,2,2)
hold all
plot(frameClock,stimPSTH)
ylim([0 0.75])
plot([2 2],[0 0.75],'k:')
title('with stim')
