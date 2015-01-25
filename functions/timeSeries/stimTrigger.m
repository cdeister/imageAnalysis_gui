function out=stimTrigger(dataMatrix,stimTimes,preWindow,postWindow,sampleInterval)

preSample=ceil(preWindow/sampleInterval);
postSample=ceil(postWindow/sampleInterval);

for i=1:size(dataMatrix,2)
    stimTimes=(stimTimes*(1/sampleInterval))/(1/sampleInterval); % Round the stim such that it is in line with the sample interval.
    stimTimeInSamples=fix(stimTimes(i)/sampleInterval);
    out(:,i)=dataMatrix(stimTimeInSamples-preSample:stimTimeInSamples+postSample,i);
    clear('stimTimeInSamples')
end
