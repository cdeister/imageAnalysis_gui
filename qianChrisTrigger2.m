%% auto template


%% once you have somaticF data and neuropilF data you can correct.
somaticF_original = somaticF;
somaticF = somaticF - (0.80*neuropilF);


% add an offset, so we don't get negative values for df/f
% the offset will affect df/f so we will rescale later by the error. 
% the error is the ratio of the original mean and the scalar.
somaticF = somaticF + 10000;

%% once we have df/f we fix
somaticF = nPointMean(somaticF',4);
somaticF = somaticF';
%
% once we have df/f we fix
blCutOffs = computeQunatileCutoffs(somaticF);
somaticF_BLs=slidingBaseline(somaticF,500,blCutOffs);
%
somaticF_DF = (somaticF - somaticF_BLs)./somaticF_BLs;

%
somaticF_DFBU=somaticF_DF;    
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
frameInterval = frameDelta;
% 0.108262479936572
frameClock = frameInterval:frameInterval:framesPerTrial*frameInterval;
% add the offset
frameClock = frameClock+firstFrameTime(1);

%% other behavior variables (shouldn't need to change)
syncDur = session.sync_duration;
syncTimes = session.relative_trial_start_times;
stimTimes = (syncTimes+syncDur)+0.001;

%% event estimation (foopsi)
eventThreshold = 0.02;
noiseFac = -20;
for n=1:size(somaticF_DF,1)
    [somaticF_DF_Clean(n,:),eventEstimate(n,:),dOptions{n}]=deconvolveCa(somaticF_DF(n,:)','foopsi','ar1', 'smin', noiseFac);
    somaticF_DF_Events(n,:)=zeros(size(eventEstimate(n,:)));
    tInds = find(eventEstimate(n,:)>=eventThreshold);
    somaticF_DF_Events(n,tInds)=1;
    somaticF_DF_Event_Times{n}=find(diff(somaticF_DF_Events(n,:)==1))*frameInterval;
    somaticF_DF_Event_ITIs{n}=diff(somaticF_DF_Event_Times{n});
    somaticF_DF_Event_Freq{n}=1./somaticF_DF_Event_ITIs{n};
    somaticF_DF_Event_MuFreq(:,n)=nanmean(1./somaticF_DF_Event_ITIs{n});
    somaticF_DF_Event_MedFreq(:,n)=nanmedian(1./somaticF_DF_Event_ITIs{n});
    
end

%%
% group f by trials and trigger
% cell x frame x trial
% thus, cell2's 2nd trial is addressed as:
% squeeze(trialF(2,:,2)5
clear trigF trialF
fData = somaticF_DF_Clean;
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

% now we look for stimulus cells:
%
stimBins = [-9,-5.5,-5.5,-4,-4,-2.5,-2.5,-1,-1,-0.5]
%[-9,-4, -4.5,-2.5, -3.0,-2.0, -2.25,-1.0,  -1.25,-0.25];
% [-9,-5.5,-4,-2.5,-1,-0.5]
% stimAmp = -9;
% stimAmp2 = -5;


% *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
% *** first check for "driven" cells with largest stims. ***
% *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***

% define baseline and stim windows.
baselineFrames = 4:9;
stimFrames = 12:18; %12:18
numCells = size(somaticF,1);

% identify the right trials.
trialsWithStim1 =find(session.stim_amplitude >= stimBins(1));
trialsWithStim2 =find(session.stim_amplitude < stimBins(2));

trialsWithStim3 =find(session.stim_amplitude >= stimBins(3));
trialsWithStim4 =find(session.stim_amplitude < stimBins(4));

trialsWithStim5 =find(session.stim_amplitude >= stimBins(5));
trialsWithStim6 =find(session.stim_amplitude < stimBins(6));

trialsWithStim7 =find(session.stim_amplitude >= stimBins(7));
trialsWithStim8 =find(session.stim_amplitude < stimBins(8));

trialsWithStim9 =find(session.stim_amplitude >= stimBins(9));
trialsWithStim10 =find(session.stim_amplitude < stimBins(10));

stimTrials1 = intersect(trialsWithStim1,trialsWithStim2);
stimTrials2 = intersect(trialsWithStim3,trialsWithStim4);
stimTrials3 = intersect(trialsWithStim5,trialsWithStim6);
stimTrials4 = intersect(trialsWithStim7,trialsWithStim8);
stimTrials5 = intersect(trialsWithStim9,trialsWithStim10);

trialsWithNoStim =find(session.stim_amplitude == 0);

% we can now integrate in the baseline window and stim window
for n=1:numCells
    baselineMeans(n,:) = trapz(squeeze(trigF(n,baselineFrames,:)));
    stimMeans(n,:) = trapz(squeeze(trigF(n,stimFrames,:)));
end

stimDelta = stimMeans(:,:)-baselineMeans(:,:);

clear stimPVals
for n=1:numCells
    withStim = stimDelta(n,stimTrials1);
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


% now we can look at the responsive cells
clear stimPSTH1 stimPSTH2 stimPSTH3 stimPSTH4 stimPSTH5 nostimPSTH zPSTH1 zPSTH2 zPSTH3 zPSTH4 zPSTH5 zPSTH0
clear evokedScore1 evokedScore2 evokedScore3 evokedScore4 evokedScore5

for n=1:numel(stimulusResponsiveCells)
    stimPSTH1(:,n) = mean(squeeze(trigF(stimulusResponsiveCells(n),:,stimTrials1)),2);
    stimPSTH2(:,n) = mean(squeeze(trigF(stimulusResponsiveCells(n),:,stimTrials2)),2);
    stimPSTH3(:,n) = mean(squeeze(trigF(stimulusResponsiveCells(n),:,stimTrials3)),2);
    stimPSTH4(:,n) = mean(squeeze(trigF(stimulusResponsiveCells(n),:,stimTrials4)),2);
    stimPSTH5(:,n) = mean(squeeze(trigF(stimulusResponsiveCells(n),:,stimTrials5)),2);
    nostimPSTH(:,n) = mean(squeeze(trigF(stimulusResponsiveCells(n),:,trialsWithNoStim)),2);
end

blFrames = 2:11
zPSTH1(:,:) = (stimPSTH1-repmat(mean(nostimPSTH(:,:)),size(stimPSTH1,1),1))./repmat(std(nostimPSTH(:,:)),size(stimPSTH1,1),1);
zPSTH2(:,:) = (stimPSTH2-repmat(mean(nostimPSTH(:,:)),size(stimPSTH2,1),1))./repmat(std(nostimPSTH(:,:)),size(stimPSTH2,1),1);
zPSTH3(:,:) = (stimPSTH3-repmat(mean(nostimPSTH(:,:)),size(stimPSTH3,1),1))./repmat(std(nostimPSTH(:,:)),size(stimPSTH3,1),1);
zPSTH4(:,:) = (stimPSTH4-repmat(mean(nostimPSTH(:,:)),size(stimPSTH4,1),1))./repmat(std(nostimPSTH(:,:)),size(stimPSTH4,1),1);
zPSTH5(:,:) = (stimPSTH5-repmat(mean(nostimPSTH(:,:)),size(stimPSTH5,1),1))./repmat(std(nostimPSTH(:,:)),size(stimPSTH5,1),1);
zPSTH0(:,:) = (nostimPSTH-repmat(mean(nostimPSTH(:,:)),size(stimPSTH5,1),1))./repmat(std(nostimPSTH(:,:)),size(nostimPSTH,1),1);

%13 22
evokedScore1 = trapz(zPSTH1(13:22,:))-trapz(zPSTH1(2:8,:,1));
evokedScore2 = trapz(zPSTH2(13:22,:))-trapz(zPSTH2(2:8,:,1));
evokedScore3 = trapz(zPSTH3(13:22,:))-trapz(zPSTH3(2:8,:,1));
evokedScore4 = trapz(zPSTH4(13:22,:))-trapz(zPSTH4(2:8,:,1));
evokedScore5 = trapz(zPSTH5(13:22,:))-trapz(zPSTH5(2:8,:,1));

figure,plot(mean(zPSTH1'))
hold all,plot(mean(zPSTH2'))
hold all,plot(mean(zPSTH3'))
hold all,plot(mean(zPSTH4'))
hold all,plot(mean(zPSTH5'))
hold all,plot(mean(zPSTH0'))

figure,nhist({evokedScore1,evokedScore2,evokedScore3,evokedScore4,evokedScore5},'box')
%%
pooledZ1=[];
pooledZ2=[];
pooledZ3=[];
pooledZ4=[];
pooledZ5=[];
pooledZ0=[];
%%
pooledZ1=horzcat(pooledZ1,zPSTH1);
pooledZ2=horzcat(pooledZ2,zPSTH2);
pooledZ3=horzcat(pooledZ3,zPSTH3);
pooledZ4=horzcat(pooledZ4,zPSTH4);
pooledZ5=horzcat(pooledZ5,zPSTH5);
pooledZ0=horzcat(pooledZ0,zPSTH0);

clearvars -except pooledZ1 pooledZ2 pooledZ3 pooledZ4 pooledZ5 pooledZ0
close all
clc
%%
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
plot(trialClock,stimPSTH1,'o-')
ylim([0 pBounds(2)])
plot([trialClock(bFrames-2) trialClock(bFrames-1)],[0 pBounds(2)],'k:')
title('with stim')


nanmean(somaticF_DF_Event_MuFreq(stimulusResponsiveCells))
nanmean(somaticF_DF_Event_MuFreq(setdiff(1:size(somaticF,1),stimulusResponsiveCells)))
nanmean(somaticF_DF_Event_MedFreq(stimulusResponsiveCells))
nanmean(somaticF_DF_Event_MedFreq(setdiff(1:size(somaticF,1),stimulusResponsiveCells)))

%%

%% show a trace
tNum = 16;
figure,plot(somaticF_DF_Events(tNum,:))
hold all,plot(somaticF_DF_Clean(tNum,:))
hold all,plot(somaticF_DF(tNum,:))