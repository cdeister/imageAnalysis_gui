%% Get Mean Luminance of Red Channel and Extract 'times'

% This is just for times you have stim artifacts, but no data, which should
% be rare. 

% user variables
tSt_threshold = 2;
tSt_refractSamples = 10;
tSt_preFrames = 20;
tSt_postFrames = 100;
% I didn't add in the nanPad alternative, so leave 0 for now.
tSt_nanPad = 0;

% This is going to use your red channel to find the times in frame number.
tSt_redDiff = diff(red_meanLuminance);
% all possible thresholds
tSt_Ups = find(tSt_redDiff>tSt_threshold);
% shift back one since matlab indexes from 1 (time happens on DX1 if
% DX2-DX1>=threshold
tSt_Ups = tSt_Ups-1;
% drop anything that is too frequent (set at tSt_refractSamples)
tSt_Ups = tSt_Ups(tSt_Ups>=tSt_refractSamples);
tSt_totalFrames = max(size(red_meanLuminance));

%% Now we clip frames around and after the 'times'

% assume you don't want to nanpad for stims with too few pre-frames, or
% post-frames
if tSt_nanPad == 0
    tSt_Ups = tSt_Ups((tSt_Ups-tSt_preFrames)>0);
    tSt_Ups = tSt_Ups((tSt_Ups+(tSt_postFrames+1))<=tSt_totalFrames);
end

tSt_totalStimFrames = max(size(tSt_Ups));
tSt_dataBounds = size(somaticF_DF);
tSt_totalTrigFrames = (tSt_preFrames+tSt_postFrames+1);

% pre-allocate the eventTrigger Array
% note: the dimensions are clippedData x roiInd x eventInd
trigSpikes = zeros(tSt_totalTrigFrames,tSt_dataBounds(1),tSt_totalStimFrames);

for n =1:tSt_totalStimFrames
    tmp_fIndx = (tSt_Ups(n)-tSt_preFrames):tSt_Ups(n)+tSt_postFrames;
    trigSpikes(:,:,n) = somaticF_DF(:,tmp_fIndx)';
end
tSt_frameVector = 1:tSt_totalTrigFrames;
tSt_alignedFrameVector = tSt_frameVector-tSt_preFrames;

clear tmp_fIndx
%% Plot/Index Example

% This is how you would as for the event-triggered mean for ROI #1
% note the use of squeeze to get a 2-d vector from your 3-d array. 
tmp_roiIndex = 47;
tmp_yBounds = [-0.05 0.5];
tmp_TrigMean = mean(squeeze(trigSpikes(:,tmp_roiIndex,:)),2);
tmp_TrigStd = std(squeeze(trigSpikes(:,tmp_roiIndex,:)),1,2);
tmp_TrigSEM = tmp_TrigStd/sqrt(tSt_totalStimFrames-1);

figure,plot(tSt_alignedFrameVector,tmp_TrigMean)
hold all,plot([0 0],tmp_yBounds,'r')

clear tmp_roiIndex 

% Here with errors plotted
figure,boundedline(tSt_alignedFrameVector,tmp_TrigMean,tmp_TrigSEM)
hold all,plot([0 0],tmp_yBounds,'r')