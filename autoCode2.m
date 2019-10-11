%%

%

runAlready=0;
if runAlready==0

% prompt = {'enter mouse id'};
% dlg_title = 'mouse info';
% num_lines = 1;
% defaultans = {'?'};
% mouseanswer = inputdlg(prompt,dlg_title,num_lines,defaultans);    
    
aa=dir;
for n=1:numel(aa)
    aaSize(:,n)=aa(n).bytes;
    aaNames{n}=aa(n).name;
end
for n=1:numel(aa)
    if aaSize(n)<10000 
        aaNames{1,n}=[];
    else
    end
end

goodEntries=find(cellfun(@numel,aaNames)>0);
runAlready=1;
else
end



%%
for ttt=1:numel(goodEntries)

currentName=aaNames{goodEntries(ttt)};
currentName=currentName(1:end-4);
load(aaNames{goodEntries(ttt)})
tV=ttt;  %<--- TODO: Hack, just needed to workaround a mistake. Doesn't hurt.
close all

getBehavioralStuff
filterTrials2
close all
lickRaster
binDprime

% ---- get some basics
pooledValues.lickNoLickRation(:,ttt)=trialFilter.lickNoLickRatio;
pooledValues.dp_unfiltered(:,ttt)=analyzedBehavior.dPrimeEstimate;
pooledValues.dp_engagementFilter(:,ttt)=trialFilter.dPrimeEst;
pooledValues.dp(:,tV)=meanDPrime;  
% this is just filtered on engagement too; but from lickRaster (running average)
pooledValues.crit(:,tV)=meanCriterion;
% this is just filtered on engagement too; but from lickRaster (running average)
pooledValues.dp_strict(:,tV)=meanDPrime_strict;  
% this is for trials that were engaged, criterion, and dprimed matched
pooledValues.crit_strict(:,tV)=meanCriterion_strict;
% this is for trials that were engaged, criterion, and dprimed matched
pooledValues.trialCount(:,tV)=numel(engagedTrials);
pooledValues.strongDP(:,tV)=psychometrics.strongDP;
pooledValues.weakDP(:,tV)=psychometrics.weakDP;
pooledValues.weak_RTs(:,tV)=psychometrics.rt_weak;
pooledValues.strong_RTs(:,tV)=psychometrics.rt_strong;
pooledValues.all_RTs(:,tV)=psychometrics.rt_all;
pooledValues.fa_RTs(:,tV)=psychometrics.rt_fa;


% ---- get curve stuff (engaged trials)
pooledValues.weights(:,tV)=psychometrics.weights;   % this is trial count per bin (in case you need to weight mean)
pooledValues.hitRates(:,tV)=psychometrics.hitRate;  % raw unsmoothed hit rate per bin
pooledValues.amps(:,tV)=-1*psychometrics.stimAmplitudes; % raw stimulus amplitude mean per bin (normalized for amplifier shift)



pooledValues.fitCurve_x(:,tV)=psychometrics.fitCurve_x;
pooledValues.normHitRate(:,tV)=psychometrics.normHitRate;
pooledValues.nonNormHitRate(:,tV)=psychometrics.nonNormHitRate;
pooledValues.normCurve_y(:,tV)=psychometrics.normCurve_y;
pooledValues.nonNormCurve_y(:,tV)=psychometrics.nonNormCurve_y;
pooledValues.threshold(:,tV)=psychometrics.threshold;
pooledValues.slope(:,tV)=psychometrics.slope;

% ---- get curve stuff (unfiltered)
% (just as FYI; data should not be used)
pooledValues.unfiltered.hitRates(:,tV)=psychometrics.unfiltered.hitRate;  % raw unsmoothed hit rate per bin
pooledValues.unfiltered.amps(:,tV)=-1*psychometrics.unfiltered.stimAmplitudes; % raw stimulus amplitude mean per bin (normalized for amplifier shift)


pooledValues.unfiltered.fitCurve_x(:,tV)=psychometrics.unfiltered.fitCurve_x;
pooledValues.unfiltered.normHitRate(:,tV)=psychometrics.unfiltered.normHitRate;
pooledValues.unfiltered.nonNormHitRate(:,tV)=psychometrics.unfiltered.nonNormHitRate;
pooledValues.unfiltered.normCurve_y(:,tV)=psychometrics.unfiltered.normCurve_y;
pooledValues.unfiltered.nonNormCurve_y(:,tV)=psychometrics.unfiltered.nonNormCurve_y;
pooledValues.unfiltered.threshold(:,tV)=psychometrics.unfiltered.threshold;
pooledValues.unfiltered.slope(:,tV)=psychometrics.unfiltered.slope;




% ---- by criteria and dprime? (still working on this?)
% pooledValues.stimAmps{tV}=stimAmps_byCritDP;
% pooledValues.responses{tV}=respByCritDP;


% --- back out weak vs. max DPrime (still working on this)
pooledValues.mean_dprimeMaxEst(:,tV)=mean_dprimeMaxEst;
pooledValues.mean_dprimeWeakEst(:,tV)=mean_dprimeWeakEst;

%%
newConvolvingPsychometricCode
pooledValues.psychometricCoefs(:,tV)=groupA_Coefs;



clearvars -except aa aaNames aaSize  goodEntries ttt runAlready pooledValues mouseanswer
disp(['finished with session # ' num2str(ttt) ' of ' num2str(numel(goodEntries))])
end

eval(['pooledValues_' mouseanswer{1} '=pooledValues;'])
save(['pooledValues_' mouseanswer{1} '.mat'],['pooledValues_' mouseanswer{1}])