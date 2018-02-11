function [stateSamples,onesVect]=getStateSamps(stateMap,stateNum,startBool)

% stateSamples looks at a time-series of states defined by your input
% stateMap and returns the sample where stateNum starts (default) or ends
% (optionally defined by passing startBool=0)
% onesVect is an optional convinence output that simply returns a binary
% version of your stateSamples. That is to say a vector of ones and zeros
% that is the shape of stateMap, but has ones when the state happens.

if nargin == 2
    startBool=1;
else
end

onesVect=zeros(size(stateMap));

% null all but the state you want.
stateMap(stateMap~=stateNum)=0;

% take the diff with the null accounted for.
dThr=stateNum/2; % might be nice to make this an input?
if startBool==1
    stateSamples=find(diff(stateMap)>dThr);
elseif startBool==0
    stateSamples=find(diff(stateMap)<-dThr);
end

% the deriv gives the samp preceding, so correct.
stateSamples=stateSamples+1;    
onesVect(stateSamples)=1;

end