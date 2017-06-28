%% bin dp
% messy right now, but works
% need to bootstrap the randperms I think

trialFilter.falseTrials=trialFilter.rejectTrials;
trialFilter.falseTrials(find(trialFilter.rejectTrials==0))=1;
trialFilter.falseTrials(find(trialFilter.rejectTrials==1))=0;

maxEng=trialFilter.hitTrials(find(trialFilter.stimAmps==-7));
weakEng=trialFilter.hitTrials(find(trialFilter.stimAmps>-5 & trialFilter.stimAmps<0));


ff=normpdf([-10:10],0,5);
ff = ff./sum(ff); 
figure,plot(nanconv(maxEng',ff))
figure,plot(nanconv(trialFilter.falseTrials',ff))

engMax=nanconv(maxEng',ff);
engWeak=nanconv(weakEng',ff);
engFA=nanconv(trialFilter.falseTrials',ff);

% estimate max dprime
[minC,minI]=min([numel(engMax),numel(engFA)]);
if minI==1
    engFA=engFA(randperm(numel(engFA),numel(engMax)));
elseif minI==2
    engMax=engMax(randperm(numel(engMax),numel(engFA)));
else
end
    
dprimeMaxEst=dprime(engMax,engFA);
infsToNan=find(dprimeMaxEst==Inf | dprimeMaxEst==-Inf);
dprimeMaxEst(infsToNan)=NaN;
mean_dprimeMaxEst=nanmean(dprimeMaxEst);

% estimate 'weak' dprime
[minC,minI]=min([numel(engWeak),numel(engFA)]);
if minI==1
    engFA=engFA(randperm(numel(engFA),numel(engWeak)));
elseif minI==2
    engWeak=engWeak(randperm(numel(engWeak),numel(engFA)));
else
end
    
dprimeWeakEst=dprime(engWeak,engFA);
infsToNan=find(dprimeWeakEst==Inf | dprimeWeakEst==-Inf);
dprimeWeakEst(infsToNan)=NaN;
mean_dprimeWeakEst=nanmean(dprimeWeakEst);