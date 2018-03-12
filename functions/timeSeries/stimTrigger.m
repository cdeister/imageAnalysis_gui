function out=stimTrigger(dataMatrix,stimTimes,preWindow,postWindow,sampleInterval)



preSample=ceil(preWindow/sampleInterval);
postSample=ceil(postWindow/sampleInterval);
dataMatrix=padarray(dataMatrix,[preSample+postSample,0],NaN,'post');


for i=1:numel(stimTimes)
    try
        stimTimeInSamples=fix(stimTimes(i)/sampleInterval);
        dRange=(stimTimeInSamples-preSample):(stimTimeInSamples+postSample);
%         disp(postSample)
%         disp(i)
%         disp(size(dataMatrix))
        out(:,:,i)=dataMatrix(dRange,:);
        clear dRange
    catch
        return
    end
end



% timeV=horzcat(-1*fliplr(0:sampleInterval:(preSample*sampleInterval)),sampleInterval:sampleInterval:(postSample*sampleInterval));