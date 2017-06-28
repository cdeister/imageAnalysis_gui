function plotCellWithStims2(roi)

%


frameInterval=evalin('base','session.frameInterval');
twoPTrialLength=evalin('base','session.framesPerTrial');
trialCounts=fix(size(roi,1)/twoPTrialLength);
twoPTrialTime=frameInterval:frameInterval:twoPTrialLength*frameInterval;
twoPTrialTimeTotal=twoPTrialTime(end);
totalTwoPTimeVector=frameInterval:frameInterval:(twoPTrialLength*frameInterval)*trialCounts;

%
stimTimes=evalin('base','stimTimes');
stimAmps=evalin('base','stimAmps');


for n=1:trialCounts;
    behaviorEventsTime(:,n)=[(twoPTrialTimeTotal*(n-1))+stimTimes(n),(twoPTrialTimeTotal*(n-1))+stimTimes(n)];
    behaviorEventsVector(:,n)=[(stimAmps(n))+1,-1*(stimAmps(n))+1];
end


%
figure,plot(totalTwoPTimeVector,roi,'b-')
hold all,plot(behaviorEventsTime,behaviorEventsVector,'k-')
title([inputname(1)])
