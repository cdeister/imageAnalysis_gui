% reading
crapBytes=156;
samplingRate=10000;
fid = fopen('~/Downloads/005.dat','r');
dataRecord = fread(fid,'int','b');
dataRecord=dataRecord(crapBytes+1:end);
fclose(fid)
timeVector=0:1/samplingRate:(numel(dataRecord)-1)*1/samplingRate;

%%
stimTime=5;
preTime=1;
postTime=2;
trialTime=10;

stimSamples=stimTime*samplingRate;
preSamples=preTime*samplingRate;
postSamples=postTime*samplingRate;
trialSamples=trialTime*samplingRate;

for n=1:10;
    snips(:,n)=dataRecord((stimSamples-preSamples)+((n-1)*trialSamples):(stimSamples+postSamples)+((n-1)*trialSamples),1);
end

figure,plot(snips,'r:')
hold all,plot(mean(snips,2),'k-')

%%
figure,plot(mean(snips_003,2))
hold all,plot(mean(snips_004,2))
hold all,plot(mean(snips_005,2))
hold all,plot(mean(snips_006,2))
hold all,plot(mean(snips_007,2))

%%

earlyWindow=[10140:10340];
laterWindow=[11490:12650];
baselineWindow=[1000:1000+numel(laterWindow)-1];
winToUse=laterWindow;

aaa=mean(snips_003,2);
bbb=mean(snips_004,2);
ccc=mean(snips_005,2);
ddd=mean(snips_006,2);
eee=mean(snips_007,2);

e3=abs(trapz(aaa(winToUse))-trapz(aaa(baselineWindow)));
e4=abs(trapz(bbb(winToUse))-trapz(bbb(baselineWindow)));
e5=abs(trapz(ccc(winToUse))-trapz(ccc(baselineWindow)));
e6=abs(trapz(ddd(winToUse))-trapz(ddd(baselineWindow)));
e7=abs(trapz(eee(winToUse))-trapz(eee(baselineWindow)));

figure,plot([5,10,20,30],[e3,e4,e5,e6]./max([e3,e4,e5,e6]),'ko-')


%%

earlyWindow=[10140:10340];
laterWindow=[11490:12650];
baselineWindow=[1000:1000+numel(laterWindow)-1];
winToUse=earlyWindow;

aaa=mean(snips_003,2);
bbb=mean(snips_004,2);
ccc=mean(snips_005,2);
ddd=mean(snips_006,2);
eee=mean(snips_007,2);

e3=abs(trapz(aaa(winToUse))-trapz(aaa(baselineWindow)));
e4=abs(trapz(bbb(winToUse))-trapz(bbb(baselineWindow)));
e5=abs(trapz(ccc(winToUse))-trapz(ccc(baselineWindow)));
e6=abs(trapz(ddd(winToUse))-trapz(ddd(baselineWindow)));
e7=abs(trapz(eee(winToUse))-trapz(eee(baselineWindow)));

hold all,plot([5,10,20,30],[e3,e4,e5,e6]./max([e3,e4,e5,e6]),'ro-')