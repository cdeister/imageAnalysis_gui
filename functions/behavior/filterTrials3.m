behavSessions={'cdL23_01Aug_wAdditions.mat','cdL23_15Aug_wAdditions.mat','cdPV7_08Nov_wAdditions.mat',...
    'cdPV7_30Oct_wAdditions.mat','cdPV8_23Oct_wAdditions.mat','cdPV8_26Oct_wAdditions.mat', 'cdPV8_23Oct_wAdditions.mat','cdPV11_25Feb_wAdditions.mat',...
    'cdPV11_26Feb_wAdditions.mat','cdPV11_28Feb_wAdditions.mat','cdSom5_02Sep_wAdditions.mat','cdSom5_18Aug_wAdditions.mat', '30Sep_cdPV3.mat','01Oct_cdPV3.mat','03Oct_cdPV3.mat','04Oct_cdPV3.mat',...
     '05Oct_cdPV3.mat','06Oct_cdPV3.mat','07Oct_cdPV3.mat',...
     '10Oct_cdPV3.mat','11Oct_cdPV3.mat','12Oct_cdPV3.mat','05Oct_cdPV4.mat','06Oct_cdPV4.mat','07Oct_cdPV4.mat','08Oct2013_cdPV4.mat','10Oct2013_cdPV4.mat'};
% 'cdPV8_23Oct_wAdditions.mat'
% behavSessions={ '30Sep_cdPV3.mat','01Oct_cdPV3.mat','03Oct_cdPV3.mat','04Oct_cdPV3.mat','06Oct_cdPV3.mat','07Oct_cdPV3.mat',...
%     '10Oct_cdPV3.mat','11Oct_cdPV3.mat','12Oct_cdPV3.mat'};
% '05Oct_cdPV3.mat', '30Sep_cdPV3.mat'
% behavSessions={'05Oct_cdPV4.mat','06Oct_cdPV4.mat','07Oct_cdPV4.mat','08Oct2013_cdPV4.mat','10Oct2013_cdPV4.mat'};
close all
for jj=8; 
clearvars -except corrCollection  jj behavSessions ccc_1 ccc_2 ccc_3 ppp_1 ppp_2 ppp_3 ...
    ccc_1a ccc_2a ccc_3a ppp_1a ppp_2a ppp_3a ccc_1b ccc_2b ccc_3b ppp_1b ppp_2b ppp_3b ccc_1c ccc_2c ccc_3c ppp_1c ppp_2c ppp_3c ...
    ccc_1d ccc_2d ccc_3d ppp_1d ppp_2d ppp_3d
disp(['loading session ' behavSessions{jj}])
if jj<=12
 load(['/Users/cad/Dropbox (Moore Lab)/cadNatNeuro2016_resub/data/usedGeneralSessions/' behavSessions{jj}])
elseif jj>12 && jj <=22
load(['/Users/cad/Dropbox (Moore Lab)/analyzedSessions/cdPV3/' behavSessions{jj}])
elseif jj>22
load(['/Users/cad/Dropbox (Moore Lab)/analyzedSessions/cdPV4/' behavSessions{jj}])
else
end
% 
disp(['done loading session ' behavSessions{jj}])
getBehavioralStuff
% filterTrials
% 
% a_shiftVals(jj+19,1)=shiftVals.faDif;
% a_shiftVals(jj+19,2)=shiftVals.maxDif;
% a_shiftVals(jj+19,3)=shiftVals.n_slopeDif;
% a_shiftVals(jj+19,4)=shiftVals.n_threshDif;
% a_shiftVals(jj+19,5)=shiftVals.slopeDif;
% a_shiftVals(jj+19,6)=shiftVals.threshDif;
% end
% 

% jj=1;
%% Filter Trials
close all

% --- these are variables that one might want to change
trialFilter.preLickThreshold=-0.5; %(in seconds)
trialFilter.tooEarly=0.025; % licks that occur to early after the stim (in seconds)
trialFilter.kernelType=1; % 0 for box; 1 for gaussian
trialFilter.kernelWidth=10; % depends on what you want to do.


%stimTimes=session.relative_trial_start_times;
%stimAmps=session.stim_amplitude(1:numel(stimTimes));

% this picks and makes the smoothing kernel
%
% gaussian
if trialFilter.kernelType==1
    gKern= normpdf(-1000:1000,0,trialFilter.kernelWidth);
    gKern = gKern./max(gKern); 

elseif trialFilter.kernelType==0
% box-car (fixed proportion of trials)
    trialFilter.boxWidth=fix(timingParams.numTrials./trialFilter.kernelWidth);
    gKern=ones(1,trialFilter.boxWidth)./trialFilter.boxWidth;
else
end

% ------------ smooth some stuff!!! 

% ------------ This will allow us to correlated fluctuations in engagment,dprime, criterion etc. with things.
%
%
%


% Let's do a running dPrime and criterionLoc
% normiv(hr)-norminv(fa)
% 0.5*(norminv(hr)+norminv(fa))
%
% This will lead to some NaNs and Infs in places.
trialFilter.smoothDPrime=dprime(nanconv(session.behavior.hits,gKern),...
    nanconv(session.behavior.falsepos,gKern));
trialFilter.smoothCrit=crtiloc(nanconv(session.behavior.hits,gKern),...
    nanconv(session.behavior.falsepos,gKern));

% assume 0.999 and 0.001 are the best and worst that is possible (3 sig
% digits)
trialFilter.smoothDPrime(find(trialFilter.smoothDPrime>6.181))=6.181;
trialFilter.smoothCrit(find(trialFilter.smoothCrit>(3.09)))=3.09;
trialFilter.smoothCrit(find(trialFilter.smoothCrit<(-3.09)))=-3.09;

trialFilter.smoothDPrime=fixgaps(trialFilter.smoothDPrime);
trialFilter.smoothCrit=fixgaps(trialFilter.smoothCrit);


figure
subplot(1,2,1)
plot(trialFilter.smoothDPrime)
hold all
plot(trialFilter.smoothCrit)


% Let's smooth amplitudes to see how well flucutations in average amplitude correlate
% This one is straight forward, and their should be no NaNs
trialFilter.smoothAmps=nanconv(session.stim_amplitude(1:numel(trialFilter.smoothDPrime)),gKern);
plot((-1*trialFilter.smoothAmps)-(-1*mean(trialFilter.smoothAmps)))
title('all trials')
%
%



% smooth overall hit/response rate
%
%
% this takes a vector of 0s, 1s and NaNs and makes a moving average.
% if the subject is perfect this will be 1 across all time.

trialFilter.smoothHit=nanconv(session.behavior.hits,gKern);
plot(trialFilter.smoothHit)
% determine the engagement threshold by looking for a large drop in performance
%
%
trialFilter.engThreshold=(max(trialFilter.smoothHit)-min(trialFilter.smoothHit))/2;
trialFilter.engThreshold=(trialFilter.engThreshold+min(trialFilter.smoothHit));
% trialFilter.engThreshold=(max(trialFilter.smoothHit)-std(trialFilter.smoothHit));
% now cut-off non-egnaged trials by this threshold method
%
%
trialFilter.engagedTrials=find(trialFilter.smoothHit>trialFilter.engThreshold);
trialFilter.disengagedTrials=find(trialFilter.smoothHit<trialFilter.engThreshold);


plot(trialFilter.smoothHit>trialFilter.engThreshold,'ko')
%---- 
subplot(1,2,2)
plot(trialFilter.smoothDPrime(trialFilter.engagedTrials))
hold all
plot(trialFilter.smoothCrit((trialFilter.engagedTrials)))
plot(trialFilter.smoothAmps(trialFilter.engagedTrials))
plot(trialFilter.smoothHit(trialFilter.engagedTrials))
title('engaged trials')

%%


if trialFilter.kernelType==1
    gKern= normpdf(-1000:1000,0,trialFilter.kernelWidth); 
    gKern = gKern./max(gKern); 

elseif trialFilter.kernelType==0
% box-car (fixed proportion of trials)
    trialFilter.boxWidth=fix(timingParams.numTrials./trialFilter.kernelWidth);
    gKern=ones(1,trialFilter.boxWidth)./trialFilter.boxWidth;
else
end

trialFilter.engaged.smoothDPrime=dprime(nanconv(session.behavior.hits(trialFilter.engagedTrials),gKern),...
    nanconv(session.behavior.falsepos(trialFilter.engagedTrials),gKern));
trialFilter.engaged.smoothCrit=crtiloc(nanconv(session.behavior.hits(trialFilter.engagedTrials),gKern),...
    nanconv(session.behavior.falsepos(trialFilter.engagedTrials),gKern));
trialFilter.engaged.smoothHit=nanconv(session.behavior.hits(trialFilter.engagedTrials),gKern);
trialFilter.engaged.smoothAmps=nanconv(session.stim_amplitude(trialFilter.engagedTrials),gKern);

% assume 0.999 and 0.001 are the best and worst that is possible (3 sig
% digits)
trialFilter.engaged.smoothDPrime(find(trialFilter.engaged.smoothDPrime>6.181))=6.181;
trialFilter.engaged.smoothCrit(find(trialFilter.engaged.smoothCrit>(3.09)))=3.09;
trialFilter.engaged.smoothCrit(find(trialFilter.engaged.smoothCrit<(-3.09)))=-3.09;

trialFilter.engaged.smoothDPrime=fixgaps(trialFilter.engaged.smoothDPrime);
trialFilter.engaged.smoothCrit=fixgaps(trialFilter.engaged.smoothCrit);


trialFilter.disengaged.smoothDPrime=dprime(nanconv(session.behavior.hits(trialFilter.disengagedTrials),gKern),...
    nanconv(session.behavior.falsepos(trialFilter.disengagedTrials),gKern));
trialFilter.disengaged.smoothCrit=crtiloc(nanconv(session.behavior.hits(trialFilter.disengagedTrials),gKern),...
    nanconv(session.behavior.falsepos(trialFilter.disengagedTrials),gKern));
trialFilter.disengaged.smoothHit=nanconv(session.behavior.hits(trialFilter.disengagedTrials),gKern);
trialFilter.disengaged.smoothAmps=nanconv(session.stim_amplitude(trialFilter.disengagedTrials),gKern);

% assume 0.999 and 0.001 are the best and worst that is possible (3 sig
% digits)
trialFilter.disengaged.smoothDPrime(find(trialFilter.disengaged.smoothDPrime>6.181))=6.181;
trialFilter.disengaged.smoothCrit(find(trialFilter.disengaged.smoothCrit>(3.09)))=3.09;
trialFilter.disengaged.smoothCrit(find(trialFilter.disengaged.smoothCrit<(-3.09)))=-3.09;

if numel(find(isnan(trialFilter.disengaged.smoothDPrime)==0)>0)
trialFilter.disengaged.smoothDPrime=fixgaps(trialFilter.disengaged.smoothDPrime);
trialFilter.disengaged.smoothCrit=fixgaps(trialFilter.disengaged.smoothCrit);
else
end



figure
plot(trialFilter.engaged.smoothDPrime)
hold all
plot(trialFilter.engaged.smoothCrit)
plot(-1*trialFilter.engaged.smoothAmps)
plot(trialFilter.engaged.smoothHit)
title('engaged trials')


% make some correlations
[tar,tap]=corr(-1*trialFilter.smoothAmps',trialFilter.smoothHit')
[tbr,tbp]=corr(-1*trialFilter.engaged.smoothAmps',trialFilter.engaged.smoothHit')
corrCollection.uf.rs(jj,1)=tar;
corrCollection.uf.ps(jj,1)=tap;
corrCollection.f.rs(jj,1)=tbr;
corrCollection.f.ps(jj,1)=tbp;


figure
subplot(3,2,1)
plot(-1*trialFilter.smoothAmps',trialFilter.smoothHit','ko')
title(['stim amp vs. resp rate (uf) r= ' num2str(tar,'%.2g') ' p= ' num2str(tap,'%.2g')])
ylim([0 1])
axis square
subplot(3,2,2)
plot(-1*trialFilter.engaged.smoothAmps',trialFilter.engaged.smoothHit','bo')
title(['stim amp vs. resp rate (eng.) r= ' num2str(tbr,'%.2g') ' p= ' num2str(tbp,'%.2g')])
ylim([0 1])
axis square

%

[tar,tap]=corr(-1*trialFilter.smoothAmps(isnan(trialFilter.smoothCrit)==0)',trialFilter.smoothCrit(isnan(trialFilter.smoothCrit)==0)')
[tbr,tbp]=corr(-1*trialFilter.engaged.smoothAmps(isnan(trialFilter.engaged.smoothCrit)==0)',trialFilter.engaged.smoothCrit(isnan(trialFilter.engaged.smoothCrit)==0)')

corrCollection.uf.rs(jj,2)=tar;
corrCollection.uf.ps(jj,2)=tap;
corrCollection.f.rs(jj,2)=tbr;
corrCollection.f.ps(jj,2)=tbp;


subplot(3,2,3)
plot(-1*trialFilter.smoothAmps(isnan(trialFilter.smoothCrit)==0)',trialFilter.smoothCrit(isnan(trialFilter.smoothCrit)==0)','ko')
title(['stim amp vs. criterion (uf) r= ' num2str(tar,'%.2g') ' p= ' num2str(tap,'%.2g')])
ylim([-0.5 3.5])
axis square

subplot(3,2,4)
plot(-1*trialFilter.engaged.smoothAmps(isnan(trialFilter.engaged.smoothCrit)==0)',trialFilter.engaged.smoothCrit(isnan(trialFilter.engaged.smoothCrit)==0)','bo')
title(['stim amp vs. criterion r= ' num2str(tbr,'%.2g') ' p= ' num2str(tbp,'%.2g')])
ylim([-0.5 3.5])
axis square


[tar,tap]=corr(-1*trialFilter.smoothAmps(isnan(trialFilter.smoothDPrime)==0)',trialFilter.smoothDPrime(isnan(trialFilter.smoothDPrime)==0)')
[tbr,tbp]=corr(-1*trialFilter.engaged.smoothAmps(isnan(trialFilter.engaged.smoothDPrime)==0)',trialFilter.engaged.smoothDPrime(isnan(trialFilter.engaged.smoothDPrime)==0)')
corrCollection.uf.rs(jj,3)=tar;
corrCollection.uf.ps(jj,3)=tap;
corrCollection.f.rs(jj,3)=tbr;
corrCollection.f.ps(jj,3)=tbp;

subplot(3,2,5)
plot(-1*trialFilter.smoothAmps(isnan(trialFilter.smoothDPrime)==0)',trialFilter.smoothDPrime(isnan(trialFilter.smoothDPrime)==0)','ko')
title(['stim amp vs. dprime (uf) r= ' num2str(tar,'%.2g') ' p= ' num2str(tap,'%.2g')])
ylim([-0.5 3.5])
axis square

subplot(3,2,6)
plot(-1*trialFilter.engaged.smoothAmps(isnan(trialFilter.engaged.smoothDPrime)==0)',trialFilter.engaged.smoothDPrime(isnan(trialFilter.engaged.smoothDPrime)==0)','bo')
title(['stim amp vs. dprime r= ' num2str(tbr,'%.2g') ' p= ' num2str(tbp,'%.2g')])
ylim([-0.5 3.5])
axis square

% make some correlations
[tar,tap]=corr(trialFilter.smoothCrit(isnan(trialFilter.smoothCrit)==0)',trialFilter.smoothHit(isnan(trialFilter.smoothCrit)==0)')
[tbr,tbp]=corr(trialFilter.engaged.smoothCrit(isnan(trialFilter.engaged.smoothCrit)==0)',trialFilter.engaged.smoothHit(isnan(trialFilter.engaged.smoothCrit)==0)')
corrCollection.uf.rs(jj,4)=tar;
corrCollection.uf.ps(jj,4)=tap;
corrCollection.f.rs(jj,4)=tbr;
corrCollection.f.ps(jj,4)=tbp;

figure
subplot(2,2,1)
plot(trialFilter.smoothCrit',trialFilter.smoothHit','ko')
title(['crit vs. resp rate (uf) r= ' num2str(tar,'%.2g') ' p= ' num2str(tap,'%.2g')])
ylim([0 1])
axis square
subplot(2,2,2)
plot(trialFilter.engaged.smoothCrit(isnan(trialFilter.engaged.smoothCrit)==0)',trialFilter.engaged.smoothHit(isnan(trialFilter.engaged.smoothCrit)==0)','bo')
title(['crit vs. resp rate (eng.) r= ' num2str(tbr,'%.2g') ' p= ' num2str(tbp,'%.2g')])
ylim([0 1])
axis square



subplot(2,2,3)
plot(trialFilter.smoothCrit',trialFilter.smoothDPrime','ko')
title(['crit vs. dprime (uf) r= ' num2str(tar,'%.2g') ' p= ' num2str(tap,'%.2g')])
axis square
subplot(2,2,4)
plot(trialFilter.engaged.smoothCrit(isnan(trialFilter.engaged.smoothDPrime)==0)',trialFilter.engaged.smoothDPrime(isnan(trialFilter.engaged.smoothDPrime)==0)','bo')
title(['crit vs. dprime (eng.) r= ' num2str(tbr,'%.2g') ' p= ' num2str(tbp,'%.2g')])
axis square


%%
% make some correlations
[tar,tap]=corr(-1*trialFilter.smoothAmps(isnan(trialFilter.smoothDPrime)==0)',trialFilter.smoothDPrime(isnan(trialFilter.smoothDPrime)==0)')
[tbr,tbp]=corr(-1*trialFilter.engaged.smoothAmps(isnan(trialFilter.engaged.smoothDPrime)==0)',trialFilter.engaged.smoothDPrime(isnan(trialFilter.engaged.smoothDPrime)==0)')
corrCollection.uf.rs(jj,5)=tar;
corrCollection.uf.ps(jj,5)=tap;
corrCollection.f.rs(jj,5)=tbr;
corrCollection.f.ps(jj,5)=tbp;


figure
subplot(3,2,1)
plot(-1*trialFilter.smoothAmps(isnan(trialFilter.smoothDPrime)==0)',trialFilter.smoothDPrime(isnan(trialFilter.smoothDPrime)==0)','ko')
title(['stim amp vs. resp rate (uf) r= ' num2str(tar,'%.2g') ' p= ' num2str(tap,'%.2g')])
ylim([0 7])
axis square
subplot(3,2,2)
plot(-1*trialFilter.engaged.smoothAmps(isnan(trialFilter.engaged.smoothDPrime)==0)',trialFilter.engaged.smoothDPrime(isnan(trialFilter.engaged.smoothDPrime)==0)','bo')
title(['stim amp vs. resp rate (eng.) r= ' num2str(tbr,'%.2g') ' p= ' num2str(tbp,'%.2g')])
ylim([0 7])
axis square

%

[tar,tap]=corr(-1*trialFilter.smoothAmps(isnan(trialFilter.smoothCrit)==0)',trialFilter.smoothCrit(isnan(trialFilter.smoothCrit)==0)')
[tbr,tbp]=corr(-1*trialFilter.engaged.smoothAmps(isnan(trialFilter.engaged.smoothCrit)==0)',trialFilter.engaged.smoothCrit(isnan(trialFilter.engaged.smoothCrit)==0)')

corrCollection.uf.rs(jj,6)=tar;
corrCollection.uf.ps(jj,6)=tap;
corrCollection.f.rs(jj,6)=tbr;
corrCollection.f.ps(jj,6)=tbp;


subplot(3,2,3)
plot(-1*trialFilter.smoothAmps(isnan(trialFilter.smoothCrit)==0)',trialFilter.smoothCrit(isnan(trialFilter.smoothCrit)==0)','ko')
title(['stim amp vs. criterion (uf) r= ' num2str(tar,'%.2g') ' p= ' num2str(tap,'%.2g')])
ylim([-0.5 3.5])
axis square

subplot(3,2,4)
plot(-1*trialFilter.engaged.smoothAmps(isnan(trialFilter.engaged.smoothCrit)==0)',trialFilter.engaged.smoothCrit(isnan(trialFilter.engaged.smoothCrit)==0)','bo')
title(['stim amp vs. criterion r= ' num2str(tbr,'%.2g') ' p= ' num2str(tbp,'%.2g')])
ylim([-0.5 3.5])
axis square


[tar,tap]=corr(-1*trialFilter.smoothAmps(isnan(trialFilter.smoothDPrime)==0)',trialFilter.smoothDPrime(isnan(trialFilter.smoothDPrime)==0)')
[tbr,tbp]=corr(-1*trialFilter.engaged.smoothAmps(isnan(trialFilter.engaged.smoothDPrime)==0)',trialFilter.engaged.smoothDPrime(isnan(trialFilter.engaged.smoothDPrime)==0)')
corrCollection.uf.rs(jj,7)=tar;
corrCollection.uf.ps(jj,7)=tap;
corrCollection.f.rs(jj,7)=tbr;
corrCollection.f.ps(jj,7)=tbp;

subplot(3,2,5)
plot(-1*trialFilter.smoothAmps(isnan(trialFilter.smoothDPrime)==0)',trialFilter.smoothDPrime(isnan(trialFilter.smoothDPrime)==0)','ko')
title(['stim amp vs. dprime (uf) r= ' num2str(tar,'%.2g') ' p= ' num2str(tap,'%.2g')])
ylim([-0.5 3.5])
axis square

subplot(3,2,6)
plot(-1*trialFilter.engaged.smoothAmps(isnan(trialFilter.engaged.smoothDPrime)==0)',trialFilter.engaged.smoothDPrime(isnan(trialFilter.engaged.smoothDPrime)==0)','bo')
title(['stim amp vs. dprime r= ' num2str(tbr,'%.2g') ' p= ' num2str(tbp,'%.2g')])
ylim([-0.5 3.5])
axis square

% make some correlations
[tar,tap]=corr(trialFilter.smoothCrit(isnan(trialFilter.smoothCrit)==0)',trialFilter.smoothDPrime(isnan(trialFilter.smoothCrit)==0)')
[tbr,tbp]=corr(trialFilter.engaged.smoothCrit(isnan(trialFilter.engaged.smoothCrit)==0)',trialFilter.engaged.smoothDPrime(isnan(trialFilter.engaged.smoothCrit)==0)')
corrCollection.uf.rs(jj,8)=tar;
corrCollection.uf.ps(jj,8)=tap;
corrCollection.f.rs(jj,8)=tbr;
corrCollection.f.ps(jj,8)=tbp;

corrCollection.HR_uf(:,jj)=nanmean(trialFilter.smoothHit);
corrCollection.HR_f(:,jj)=nanmean(trialFilter.engaged.smoothHit);
corrCollection.HR_de(:,jj)=nanmean(trialFilter.disengaged.smoothHit);

corrCollection.CR_uf(:,jj)=nanmean(trialFilter.smoothCrit);
corrCollection.CR_f(:,jj)=nanmean(trialFilter.engaged.smoothCrit);
corrCollection.CR_de(:,jj)=nanmean(trialFilter.disengaged.smoothCrit);

corrCollection.DP_uf(:,jj)=nanmean(trialFilter.smoothDPrime);
corrCollection.DP_f(:,jj)=nanmean(trialFilter.engaged.smoothDPrime);
corrCollection.DP_de(:,jj)=nanmean(trialFilter.disengaged.smoothDPrime);

corrCollection.FA_uf(:,jj)=numel(find(session.behavior.falsepos==1))./numel(find(session.behavior.falsepos==1 | session.behavior.falsepos==0));
corrCollection.FA_f(:,jj)=numel(find(session.behavior.falsepos(trialFilter.engagedTrials)==1))./numel(find(session.behavior.falsepos(trialFilter.engagedTrials)==0 | session.behavior.falsepos(trialFilter.engagedTrials)==1));
corrCollection.FA_de(:,jj)=numel(find(session.behavior.falsepos(trialFilter.disengagedTrials)==1))./numel(find(session.behavior.falsepos(trialFilter.disengagedTrials)==0 | session.behavior.falsepos(trialFilter.disengagedTrials)==1));


if numel(trialFilter.disengaged.smoothAmps(isnan(trialFilter.disengaged.smoothDPrime)==0))>0

[corrCollection.de.rs(jj,1) corrCollection.de.ps(jj,1)]=corr(trialFilter.disengaged.smoothAmps(isnan(trialFilter.disengaged.smoothHit)==0)',trialFilter.disengaged.smoothHit(isnan(trialFilter.disengaged.smoothHit)==0)');
[corrCollection.de.rs(jj,2) corrCollection.de.ps(jj,2)]=corr(trialFilter.disengaged.smoothAmps(isnan(trialFilter.disengaged.smoothCrit)==0)',trialFilter.disengaged.smoothCrit(isnan(trialFilter.disengaged.smoothCrit)==0)');
[corrCollection.de.rs(jj,3) corrCollection.de.ps(jj,3)]=corr(trialFilter.disengaged.smoothAmps(isnan(trialFilter.disengaged.smoothDPrime)==0)',trialFilter.disengaged.smoothDPrime(isnan(trialFilter.disengaged.smoothDPrime)==0)');
[corrCollection.de.rs(jj,4) corrCollection.de.ps(jj,4)]=corr(trialFilter.disengaged.smoothCrit(isnan(trialFilter.disengaged.smoothCrit)==0)',trialFilter.disengaged.smoothHit(isnan(trialFilter.disengaged.smoothCrit)==0)');
[corrCollection.de.rs(jj,5) corrCollection.de.ps(jj,5)]=corr(trialFilter.disengaged.smoothCrit(isnan(trialFilter.disengaged.smoothCrit)==0)',trialFilter.disengaged.smoothDPrime(isnan(trialFilter.disengaged.smoothCrit)==0)');
else
    corrCollection.de.rs(jj,1) =NaN;
        corrCollection.de.ps(jj,1) =NaN;
    corrCollection.de.rs(jj,2) =NaN;
        corrCollection.de.ps(jj,2) =NaN;
    corrCollection.de.rs(jj,3)  =NaN;
        corrCollection.de.ps(jj,3) =NaN;
    corrCollection.de.rs(jj,4)  =NaN;
        corrCollection.de.ps(jj,4)=NaN;
    corrCollection.de.rs(jj,5)  =NaN;
        corrCollection.de.ps(jj,5) =NaN;
end

[ccc_1(:,jj) ppp_1(:,jj)]=corr((-1*trialFilter.smoothAmps)',trialFilter.smoothHit')
[ccc_2(:,jj) ppp_2(:,jj)]=corr((-1*trialFilter.smoothAmps(trialFilter.disengagedTrials))',trialFilter.smoothHit(trialFilter.disengagedTrials)')
[ccc_3(:,jj) ppp_3(:,jj)]=corr((-1*trialFilter.smoothAmps(trialFilter.engagedTrials))',trialFilter.smoothHit(trialFilter.engagedTrials)')

[ccc_1a(:,jj) ppp_1a(:,jj)]=corr((-1*trialFilter.smoothAmps)',trialFilter.smoothCrit')
[ccc_2a(:,jj) ppp_2a(:,jj)]=corr((-1*trialFilter.smoothAmps(trialFilter.disengagedTrials))',trialFilter.smoothCrit(trialFilter.disengagedTrials)')
[ccc_3a(:,jj) ppp_3a(:,jj)]=corr((-1*trialFilter.smoothAmps(trialFilter.engagedTrials))',trialFilter.smoothCrit(trialFilter.engagedTrials)')
end