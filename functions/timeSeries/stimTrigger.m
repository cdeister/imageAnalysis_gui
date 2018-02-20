function [out timeV]=stimTrigger(dataMatrix,stimTimes,preWindow,postWindow,sampleInterval)

% assumes lowest rank of dataMatrix is the itterable dimension (cell number).

preSample=ceil(preWindow/sampleInterval);
postSample=ceil(postWindow/sampleInterval);



for i=1:size(dataMatrix,2)
    tStimTime=(stimTimes(i)*(1/sampleInterval))/(1/sampleInterval); % Round the stim such that it is in line with the sample interval.
    stimTimeInSamples=fix(tStimTime/sampleInterval);
    cutA(:,i)=stimTimeInSamples-preSample;
    cutB(:,i)=stimTimeInSamples+postSample;
    clear('stimTimeInSamples')
end

for i=1:size(dataMatrix,2)
    out(:,i,:)=dataMatrix(cutA(i):cutB(i),i,:);
end



timeV=horzcat(-1*fliplr(0:sampleInterval:(preSample*sampleInterval)),sampleInterval:sampleInterval:(postSample*sampleInterval));