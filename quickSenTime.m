%% template

%% Get Mean Luminance of Red Channel and Extract 'times'

tSt_threshold = 2;
tSt_refractSamples = 10;
tSt_redDiff = diff(red_meanLuminance);
% all possible thresholds
tSt_Ups = find(tSt_redDiff>tSt_threshold);
% shift back one since matlab indexes from 1
tSt_Ups = tSt_Ups-1
% drop anything that is too frequent (set at tSt_refractSamples)
tSt_Ups = tSt_Ups(tSt_Ups>=tSt_refractSamples);

%%
tSt_totalStimFrames = max(size(tSt_Ups))-2;
tSt_totalFrames = max(size(red_meanLuminance));
tSt_preFrames = 20;
tSt_postFrames = 60;
tSt_dataBounds = size(somaticF_DF);

trigSpikes = zeros((tSt_preFrames+tSt_postFrames+1),tSt_dataBounds(1),tSt_totalStimFrames);

for n =1:tSt_totalStimFrames
    tmp_fIndx = (tSt_Ups(n)-tSt_preFrames):tSt_Ups(n)+tSt_postFrames;
    trigSpikes(:,:,n) = somaticF_DF(:,tmp_fIndx)';
end

%%
figure,plot(mean(squeeze(trigSpikes(:,6,:)),2))