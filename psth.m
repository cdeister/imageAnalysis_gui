%%


bFrames = 4:9;
bPool1 = pooledZ1-repmat(mean(pooledZ1(bFrames,:)),42,1);
bPool2 = pooledZ2-repmat(mean(pooledZ2(bFrames,:)),42,1);
bPool3 = pooledZ3-repmat(mean(pooledZ3(bFrames,:)),42,1);
bPool4 = pooledZ4-repmat(mean(pooledZ4(bFrames,:)),42,1);
bPool5 = pooledZ5-repmat(mean(pooledZ5(bFrames,:)),42,1);
bPool0 = pooledZ0-repmat(mean(pooledZ0(bFrames,:)),42,1);

a1=mean(jackknife(@median,bPool1',1))
a2=mean(jackknife(@median,bPool2',1))
a3=mean(jackknife(@median,bPool3',1))
a4=mean(jackknife(@median,bPool4',1))
a5=mean(jackknife(@median,bPool5',1))
a0=mean(jackknife(@median,bPool0',1))
% 
figure,hold all
boundedline(1:42,a1,std(a1),'cmap',[1,0,0])
boundedline(1:42,a2,std(a2),'cmap',[1,0.8,0.2])
boundedline(1:42,a3,std(a3),'cmap',[0,0.9,0.3])
boundedline(1:42,a4,std(a4),'cmap',[0.0,0.2,1.0])
boundedline(1:42,a5,std(a5),'cmap',[0.5,0.2,0.5])
boundedline(1:42,a0,std(a0),'cmap',[0,0,0])



%%
figure
boundedline(1:42,mean(bPool1'),std(bPool1')./sqrt(size(bPool1,2)-1),'cmap',[1,0,0])
boundedline(1:42,mean(bPool2'),std(bPool2')./sqrt(size(bPool2,2)-1),'cmap',[1,0.8,0.2])
boundedline(1:42,mean(bPool3'),std(bPool3')./sqrt(size(bPool3,2)-1),'cmap',[0,0.9,0.3])
boundedline(1:42,mean(bPool4'),std(bPool4')./sqrt(size(bPool4,2)-1),'cmap',[0.0,0.2,1.0])
boundedline(1:42,mean(bPool5'),std(bPool5')./sqrt(size(bPool5,2)-1),'cmap',[0.5,0.2,0.5])
boundedline(1:42,mean(bPool0'),std(bPool0')./sqrt(size(bPool0,2)-1),'cmap',[0,0,0])


%%
wt1=max(bPool1(10:22,:))-mean(bPool1(2:9,:));
wt2=max(bPool2(10:22,:))-mean(bPool2(2:9,:));
wt3=max(bPool3(10:22,:))-mean(bPool3(2:9,:));
wt4=max(bPool4(10:22,:))-mean(bPool4(2:9,:));
wt5=max(bPool5(10:22,:))-mean(bPool5(2:9,:));
wt0=max(bPool0(10:22,:))-mean(bPool0(2:9,:));
clearvars -except wt0 wt1 wt2 wt3 wt4 wt5 ko0 ko1 ko2 ko3 ko4 ko5 wts kos

%%
ko1=max(bPool1(10:22,:))-mean(bPool1(2:9,:));
ko2=max(bPool2(10:22,:))-mean(bPool2(2:9,:));
ko3=max(bPool3(10:22,:))-mean(bPool3(2:9,:));
ko4=max(bPool4(10:22,:))-mean(bPool4(2:9,:));
ko5=max(bPool5(10:22,:))-mean(bPool5(2:9,:));
ko0=max(bPool0(10:22,:))-mean(bPool0(2:9,:));
clearvars -except wt0 wt1 wt2 wt3 wt4 wt5 ko0 ko1 ko2 ko3 ko4 ko5 wts kos
%%
wts=[wt1; wt2; wt3; wt4; wt5; wt0;];
kos=[ko1; ko2; ko3; ko4; ko5; ko0;];

%%
%%
clear bFit fN
figure
amps = [6,4.75,3.25,1.75,0.75,0];
bb=mean(kos,2);
%./max(mean(kos,2));

bFit = fittype('mV/(1+exp((v5-x)/k))','dependent',{'y'},'independent',{'x'},...
    'coefficients',{'mV','v5','k'});

fN = fit(amps',bb,bFit,'Robust','on','StartPoint', [0.5 10 1]);


%
hold all
swX= 0:0.1:6;
repV5 = repmat(fN.v5,size(swX));
repK = repmat(fN.k,size(swX));


varss=(std(kos,2))./sqrt(92);
% ./max(mean(kos)))
hold all
boundedline(amps,bb,varss,'cmap',[1,0,0],'o')
hold all
plot(swX,fN.mV./(1+exp((repV5'-swX')./repK')),'k-')

%%
hold all

bb=mean(wts,2)./max(mean(wts,2));

bFit = fittype('1/(1+exp((v5-x)/k))','dependent',{'y'},'independent',{'x'},...
    'coefficients',{'v5','k'});

fN = fit(amps',bb,bFit,'Robust','on','StartPoint', [2 2],'MaxIter',1000000,'MaxFunEvals',100000);


%
hold all
swX= 0:0.1:6;
repV5 = repmat(fN.v5,size(swX));
repK = repmat(fN.k,size(swX));

varss=(std(wts')./max(mean(wts)))./sqrt(5);

hold all
boundedline(amps,bb,varss,'cmap',[0,0,1],'o')
hold all
plot(swX,1./(1+exp((repV5'-swX')./repK')),'k-')



%%
figure,boundedline([1,0.8,0.6,0.3,0.15,0],mean(wts'),std(wts,1,2)./sqrt(122),'cmap',[0,0,0],'o-')
hold all,boundedline([1,0.8,0.6,0.3,0.15,0],mean(kos'),std(kos,1,2)./sqrt(179),'cmap',[1,0,0],'o-')
h=gca;
h.TickDir='out'