%% make list raster

% user params
timeWindow=[-1.5 3]; % in seconds 1st is low and 2nd is high
reversePlot=1;
dPrimeThresh=0.8;
critThreshL=-4;
critThreshH=1;

singlePlots=0;
preLickThreshL=-0.5;
preLickThreshH=0.01;
makeFits=0;


% --------- calculate stuff
runDPEst=dprime(nanconv(session.behavior.hits,session.f),...
	nanconv(session.behavior.falsepos,session.f));
runCLEst=crtiloc(nanconv(session.behavior.hits,session.f),...
	nanconv(session.behavior.falsepos,session.f));
trailNums=1:numel(session.lick_times);
for n=1:numel(session.lick_times)
	t=find(session.lick_times{n}<=preLickThreshH & session.lick_times{n}>preLickThreshL);
	if numel(t>0)
		preStimLickTrial(:,n)=1;
	else
		preStimLickTrial(:,n)=0;
    end
end



if singlePlots
% make the raster
figure
h1 = axes;
hold all

for n=1:numel(session.lick_times)
	if numel(session.lick_times{n}>0)
		if analyzedBehavior.hitTrials(n)==1
			mColor=[0 0 0];
		elseif analyzedBehavior.hitTrials(n)==0
			mColor=[0 0 1];
		elseif analyzedBehavior.rejectTrials(n)==0
			mColor=[0 1 0];
		elseif analyzedBehavior.rejectTrials(n)==1
			mColor=[1 0 0];	
        end
		plot(session.lick_times{n},n,'Marker','o',...
			'MarkerEdgeColor',mColor, 'MarkerFaceColor',mColor,'MarkerSize',3)
	else
	end
end
plot([0 0],[1 numel(session.lick_times)],'r-', 'LineWidth',1)
xlim([timeWindow(1),timeWindow(2)])
title([session.mouse ' lick raster'])
ylabel('trial number')
xlabel('time relative to stimulus onset (sec)')
if reversePlot
	set(h1, 'Ydir', 'reverse');
else
end
axis square

% plot d-prime
figure
h2 = axes;
plot(runDPEst,trailNums,'k-','color',[0 0 0]);
hold all
plot(ones(size(trailNums))*dPrimeThresh,trailNums,'r--')
hold off
if reversePlot
	set(h2, 'Ydir', 'reverse');
else
end
xlabel('dprime')
ylabel('trial number')

else
end

% subplot
figure(100)
h3=subplot(1,6,1:4);
hold all
for n=1:numel(session.lick_times)
	if numel(session.lick_times{n}>0)
		if analyzedBehavior.hitTrials(n)==1
			mColor=[0 0 0];
		elseif analyzedBehavior.hitTrials(n)==0
			mColor=[0 0 1];
		elseif analyzedBehavior.rejectTrials(n)==0
			mColor=[0 0 1];
		elseif analyzedBehavior.rejectTrials(n)==1
			mColor=[1 0 0];	
        end
		plot(session.lick_times{n},n,'Marker','o',...
			'MarkerEdgeColor',mColor, 'MarkerFaceColor',mColor,'MarkerSize',3)
	else
	end
end
plot([0 0],[1 numel(session.lick_times)],'r-', 'LineWidth',1)
xlim([timeWindow(1),timeWindow(2)])
title([session.mouse ' lick raster ' session.date])
ylabel('trial number')
xlabel('time relative to stimulus onset (sec)')
if reversePlot
	set(h3, 'Ydir', 'reverse');
else
end



h4 = subplot(1,6,5);
plot(runDPEst,trailNums,'k-','color',[0 0 0]);
hold all
plot(ones(size(trailNums))*dPrimeThresh,trailNums,'r--')
hold off
if reversePlot
	set(h4, 'Ydir', 'reverse');
else
end
set(h4,'ytick',[]);
xlabel('dprime')
xlim([0 3])
title('conv. dprime')

h5 = subplot(1,6,6);
plot(runCLEst,trailNums,'-','color',[0 0 1]);
hold all
plot(ones(size(trailNums))*0,trailNums,'k--')
plot(ones(size(trailNums))*critThreshL,trailNums,'r--')
plot(ones(size(trailNums))*critThreshH,trailNums,'r--')
hold off
if reversePlot
	set(h5, 'Ydir', 'reverse');
else
end
set(h5,'ytick',[]);
xlabel('criterion')
xlim([2*critThreshL critThreshH*2])
title('conv. criterion')

% ----------------------------------------------------------------- make determinations of trials
goodTrialsByCL=find(runCLEst<=critThreshH & runCLEst>=critThreshL);
goodTrialsByDPrime=find(runDPEst>=dPrimeThresh);
goodTrialsByBoth=intersect(goodTrialsByCL,goodTrialsByDPrime);
goodTrialsByPreLick=find(preStimLickTrial==0);
engagedTrials=trialFilter.engagedNoLickTrials;


goodTrialsByCL_andPreLick=intersect(goodTrialsByPreLick,goodTrialsByCL);
goodTrialsByDPrime_andPreLick=intersect(goodTrialsByPreLick,goodTrialsByDPrime);
goodTrialsByBoth_andPreLick=intersect(goodTrialsByPreLick,goodTrialsByBoth);
goodTrialsByBoth_andPreLick_andEngagment=intersect(goodTrialsByBoth_andPreLick,engagedTrials);


meanDPrime=mean(runDPEst(engagedTrials));
meanCriterion=mean(runCLEst(engagedTrials));
meanDPrime_strict=mean(runDPEst(goodTrialsByBoth_andPreLick_andEngagment));
meanCriterion_strict=mean(runCLEst(goodTrialsByBoth_andPreLick_andEngagment));

meanDPAll=nanmean(runDPEst);
meanCriterionAll=nanmean(runCLEst);


%% --------------------------------------------------------------------------

% plot 'good trials lick rasters'
figure(101)
h7=subplot(1,15,1:4);
hold all
for n=1:numel(session.lick_times)
	if numel(session.lick_times{n}>0) && ismember(n,goodTrialsByDPrime_andPreLick)==1
		if analyzedBehavior.hitTrials(n)==1
			mColor=[0 0 0];
		elseif analyzedBehavior.hitTrials(n)==0
			mColor=[0 0 1];
		elseif analyzedBehavior.rejectTrials(n)==0
			mColor=[0 0 1];
		elseif analyzedBehavior.rejectTrials(n)==1
			mColor=[0 1 0];	
        end
		plot(session.lick_times{n},n,'Marker','o',...
			'MarkerEdgeColor',mColor, 'MarkerFaceColor',mColor,'MarkerSize',3)
    elseif numel(session.lick_times{n}>0) && ismember(n,goodTrialsByDPrime_andPreLick)
            mColor=[0.5 0.5 0.5];
		plot(session.lick_times{n},n,'Marker','o',...
			'MarkerEdgeColor',mColor, 'MarkerFaceColor',mColor,'MarkerSize',3)
    else
	end
end
plot([0 0],[1 numel(session.lick_times)],'r-', 'LineWidth',1)
xlim([timeWindow(1),timeWindow(2)])
title(['d prime'])
ylabel('trial number')
if reversePlot
	set(h7, 'Ydir', 'reverse');
else
end

h8=subplot(1,15,5:8);
hold all
for n=1:numel(session.lick_times)
	if numel(session.lick_times{n}>0) && ismember(n,goodTrialsByCL_andPreLick)==1
		if analyzedBehavior.hitTrials(n)==1
			mColor=[0 0 0];
		elseif analyzedBehavior.hitTrials(n)==0
			mColor=[0 0 1];
		elseif analyzedBehavior.rejectTrials(n)==0
			mColor=[0 0 1];
		elseif analyzedBehavior.rejectTrials(n)==1
			mColor=[0 1 0];	
        end
		plot(session.lick_times{n},n,'Marker','o',...
			'MarkerEdgeColor',mColor, 'MarkerFaceColor',mColor,'MarkerSize',3)
    elseif numel(session.lick_times{n}>0) && ismember(n,goodTrialsByCL_andPreLick)
            mColor=[0.5 0.5 0.5];
		plot(session.lick_times{n},n,'Marker','o',...
			'MarkerEdgeColor',mColor, 'MarkerFaceColor',mColor,'MarkerSize',3)
    else
	end
end
plot([0 0],[1 numel(session.lick_times)],'r-', 'LineWidth',1)
xlim([timeWindow(1),timeWindow(2)])
title(['criteria'])
xlabel('time relative to stimulus onset (sec)')
set(h8,'ytick',[]);
if reversePlot
	set(h8, 'Ydir', 'reverse');
else
end

h9=subplot(1,15,9:12);
hold all
for n=1:numel(session.lick_times)
	if numel(session.lick_times{n}>0) && ismember(n,goodTrialsByBoth_andPreLick)==1
		if analyzedBehavior.hitTrials(n)==1
			mColor=[0 0 0];
		elseif analyzedBehavior.hitTrials(n)==0
			mColor=[0 0 1];
		elseif analyzedBehavior.rejectTrials(n)==0
			mColor=[0 0 1];
		elseif analyzedBehavior.rejectTrials(n)==1
			mColor=[0 1 0];	
        end
		plot(session.lick_times{n},n,'Marker','o',...
			'MarkerEdgeColor',mColor, 'MarkerFaceColor',mColor,'MarkerSize',3)
    elseif numel(session.lick_times{n}>0) && ismember(n,goodTrialsByBoth_andPreLick)
            mColor=[0.5 0.5 0.5];
		plot(session.lick_times{n},n,'Marker','o',...
			'MarkerEdgeColor',mColor, 'MarkerFaceColor',mColor,'MarkerSize',3)
    else
	end
end
plot([0 0],[1 numel(session.lick_times)],'r-', 'LineWidth',1)
xlim([timeWindow(1),timeWindow(2)])
title(['dprime and criteria'])
set(h9,'ytick',[]);
if reversePlot
	set(h9, 'Ydir', 'reverse');
else
end

h10=subplot(1,15,13:15);
hold all
for n=1:numel(session.lick_times)
	if numel(session.lick_times{n}>0) && ismember(n,goodTrialsByBoth_andPreLick)==1
		if analyzedBehavior.hitTrials(n)==1
			mColor=[0 0 0];
		elseif analyzedBehavior.hitTrials(n)==0
			mColor=[0 0 1];
		elseif analyzedBehavior.rejectTrials(n)==0
			mColor=[0 0 1];
		elseif analyzedBehavior.rejectTrials(n)==1
			mColor=[0 1 0];	
        end
		plot(session.lick_times{n},n,'Marker','o',...
			'MarkerEdgeColor',mColor, 'MarkerFaceColor',mColor,'MarkerSize',3)
    elseif numel(session.lick_times{n}>0) && ismember(n,goodTrialsByBoth_andPreLick_andEngagment)
            mColor=[0.5 0.5 0.5];
		plot(session.lick_times{n},n,'Marker','o',...
			'MarkerEdgeColor',mColor, 'MarkerFaceColor',mColor,'MarkerSize',3)
    else
	end
end
plot([0 0],[1 numel(session.lick_times)],'r-', 'LineWidth',1)
xlim([timeWindow(1),timeWindow(2)])
title(['dprime and criteria and engagment'])
set(h10,'ytick',[]);
if reversePlot
	set(h10, 'Ydir', 'reverse');
else
end

%%

% plot 'good trials lick rasters'
figure(102)
h7=subplot(1,15,1:4);
hold all
pm=1;
for n=1:numel(session.lick_times)
	if numel(session.lick_times{n}>0) && ismember(n,goodTrialsByDPrime_andPreLick)==1
		if analyzedBehavior.hitTrials(n)==1
			mColor=[0 0 0];
		elseif analyzedBehavior.hitTrials(n)==0
			mColor=[0 0 1];
		elseif analyzedBehavior.rejectTrials(n)==0
			mColor=[0 0 1];
		elseif analyzedBehavior.rejectTrials(n)==1
			mColor=[0 1 0];	
        end
		plot(session.lick_times{n},pm,'Marker','o',...
			'MarkerEdgeColor',mColor, 'MarkerFaceColor',mColor,'MarkerSize',3)
        pm=pm+1;
    elseif numel(session.lick_times{n}>0) && ismember(n,goodTrialsByDPrime_andPreLick)
            mColor=[0.5 0.5 0.5];
		plot(session.lick_times{n},n,'Marker','o',...
			'MarkerEdgeColor',mColor, 'MarkerFaceColor',mColor,'MarkerSize',3)
    else
	end
end
plot([0 0],[1 numel(session.lick_times)],'r-', 'LineWidth',1)
xlim([timeWindow(1),timeWindow(2)])
title(['d prime'])
ylabel('trial number')
if reversePlot
	set(h7, 'Ydir', 'reverse');
else
end

h8=subplot(1,15,5:8);
hold all
pm=1;
for n=1:numel(session.lick_times)
	if numel(session.lick_times{n}>0) && ismember(n,goodTrialsByCL_andPreLick)==1
		if analyzedBehavior.hitTrials(n)==1
			mColor=[0 0 0];
		elseif analyzedBehavior.hitTrials(n)==0
			mColor=[0 0 1];
		elseif analyzedBehavior.rejectTrials(n)==0
			mColor=[0 0 1];
		elseif analyzedBehavior.rejectTrials(n)==1
			mColor=[0 1 0];	
        end
		plot(session.lick_times{n},pm,'Marker','o',...
			'MarkerEdgeColor',mColor, 'MarkerFaceColor',mColor,'MarkerSize',3)
        pm=pm+1;
    elseif numel(session.lick_times{n}>0) && ismember(n,goodTrialsByCL_andPreLick)
            mColor=[0.5 0.5 0.5];
		plot(session.lick_times{n},n,'Marker','o',...
			'MarkerEdgeColor',mColor, 'MarkerFaceColor',mColor,'MarkerSize',3)
    else
	end
end
plot([0 0],[1 numel(session.lick_times)],'r-', 'LineWidth',1)
xlim([timeWindow(1),timeWindow(2)])
title(['criteria'])
xlabel('time relative to stimulus onset (sec)')
set(h8,'ytick',[]);
if reversePlot
	set(h8, 'Ydir', 'reverse');
else
end

h9=subplot(1,15,9:12);
hold all
pm=1;
for n=1:numel(session.lick_times)
	if numel(session.lick_times{n}>0) && ismember(n,goodTrialsByBoth_andPreLick)==1
		if analyzedBehavior.hitTrials(n)==1
			mColor=[0 0 0];
		elseif analyzedBehavior.hitTrials(n)==0
			mColor=[0 0 1];
		elseif analyzedBehavior.rejectTrials(n)==0
			mColor=[0 0 1];
		elseif analyzedBehavior.rejectTrials(n)==1
			mColor=[0 1 0];	
        end
		plot(session.lick_times{n},pm,'Marker','o',...
			'MarkerEdgeColor',mColor, 'MarkerFaceColor',mColor,'MarkerSize',3)
        pm=pm+1;
    elseif numel(session.lick_times{n}>0) && ismember(n,goodTrialsByBoth_andPreLick)
            mColor=[0.5 0.5 0.5];
		plot(session.lick_times{n},n,'Marker','o',...
			'MarkerEdgeColor',mColor, 'MarkerFaceColor',mColor,'MarkerSize',3)
    else
	end
end
plot([0 0],[1 numel(session.lick_times)],'r-', 'LineWidth',1)
xlim([timeWindow(1),timeWindow(2)])
title(['dprime and criteria'])
set(h9,'ytick',[]);
if reversePlot
	set(h9, 'Ydir', 'reverse');
else
end

h10=subplot(1,15,13:15);
hold all
pm=1;
for n=1:numel(session.lick_times)
	if numel(session.lick_times{n}>0) && ismember(n,goodTrialsByBoth_andPreLick)==1
		if analyzedBehavior.hitTrials(n)==1
			mColor=[0 0 0];
		elseif analyzedBehavior.hitTrials(n)==0
			mColor=[0 0 1];
		elseif analyzedBehavior.rejectTrials(n)==0
			mColor=[0 0 1];
		elseif analyzedBehavior.rejectTrials(n)==1
			mColor=[0 1 0];	
        end
		plot(session.lick_times{n},pm,'Marker','o',...
			'MarkerEdgeColor',mColor, 'MarkerFaceColor',mColor,'MarkerSize',3)
        pm=pm+1;
    elseif numel(session.lick_times{n}>0) && ismember(n,goodTrialsByBoth_andPreLick_andEngagment)
            mColor=[0.5 0.5 0.5];
		plot(session.lick_times{n},n,'Marker','o',...
			'MarkerEdgeColor',mColor, 'MarkerFaceColor',mColor,'MarkerSize',3)
    else
	end
end
plot([0 0],[1 numel(session.lick_times)],'r-', 'LineWidth',1)
xlim([timeWindow(1),timeWindow(2)])
title(['dprime and criteria and engagment'])
set(h10,'ytick',[]);
if reversePlot
	set(h10, 'Ydir', 'reverse');
else
end

%%
if numel(engagedTrials)>1

for n=1:numel(engagedTrials)
    stimAmps_byCritDP(:,n)=session.stim_amplitude(engagedTrials(n));
    if stimAmps_byCritDP(:,n)<0
        respByCritDP(:,n)=analyzedBehavior.hitTrials(engagedTrials(n));
    else
        respByCritDP(:,n)=analyzedBehavior.falseTrials(engagedTrials(n));
    end
end
maxAmp=min(stimAmps_byCritDP);
maxTrials=find(stimAmps_byCritDP==maxAmp);
catchAmp=max(stimAmps_byCritDP);
catchTrials=find(stimAmps_byCritDP==catchAmp);



[sAmps sAmpsInd]=sort(stimAmps_byCritDP);
sResp=respByCritDP(:,sAmpsInd);
maxResps=respByCritDP(:,maxTrials);
faResps=respByCritDP(:,catchTrials);

cWind=50;
cKe=ones(cWind,1)./cWind;
smResp=conv(sResp,cKe);
smAmps=conv(sAmps,cKe);
% figure,plot(-1*smAmps(cWind+1:end),smResp(cWind+1:end),'o')
else
maxResps=0;
faResps=0;
respByCritDP=[];
stimAmps_byCritDP=[];
end

%%


%% non-normalized
if makeFits
bFit = fittype('1/(1+exp((v5-x)/k))',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'v5','k'});

sAm=-1*smAmps(cWind+1:end);
sHR=smResp(cWind+1:end);
sHR=sHR./max(sHR);

f = fit(sAm',sHR',bFit,'Robust','on','StartPoint', [12 6]);
fitCIs=confint(f,0.95);

% now plot the stimulus response function (psychometric curve)
figure,plot(sAm,sHR,'ko')
fX=0:0.5:max(-1*maxAmp);
hold all,plot(fX,1./(1+exp((f.v5-fX)/f.k)),'r-')
hold all,plot([f.v5 f.v5],[0 0.5],'k-')
legend('data','fit')
if numel(fitCIs)>1
title(['data fit with boltzman; midPoint= ' num2str(f.v5) ' psi w/CI=  ' num2str(fitCIs(2,:))])
else
    title(['data fit with boltzman; midPoint= ' num2str(f.v5) ' too few points bad fit'])
end
else
end