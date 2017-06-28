for nN=1:68;

%%

nTrails=100;
testF=somaticF(nN,1:240*nTrails)';
for n=1:nTrails,trialTests(:,n)=testF(1+(240*(n-1)):240+(240*(n-1)));,end
for n=1:nTrails,bdTT(:,n)=bandPassData(trialTests(:,n),1,.004,.05,0);,end

%%

allS=1:size(bdTT(:,1),1);
sdScale(:,nN)=1.4;
minSamplesEvent(:,nN)=10;

for trialT=1:nTrails;


    
minFramesPerBreak(:,nN)=2;

cut{nN}(:,trialT)=mean(diff(bdTT(:,trialT)))+sdScale(:,nN)*std(diff(bdTT(:,trialT)));

sAbove=find(diff(bdTT(:,trialT))>cut{nN}(:,trialT));
if numel(sAbove)>minSamplesEvent(:,nN);
    putEventBreaks{nN}{trialT}=find(diff(sAbove)>minFramesPerBreak(:,nN));
    eventCount{nN}(:,trialT)=numel(putEventBreaks{nN}{trialT})+1;
else
    eventCount{nN}(:,trialT)=0;
    putEventBreaks{nN}{trialT}=[];
end



if eventCount{nN}(:,trialT)>0
    eventStarts{nN}{trialT}(:,1)=sAbove(1);
    if eventCount{nN}(:,trialT)>1
        for n=2:eventCount{nN}(:,trialT)
            eventStarts{nN}{trialT}(:,n)=sAbove(putEventBreaks{nN}{trialT}(n-1)+1);
            eventEnds{nN}{trialT}(:,n-1)=sAbove(putEventBreaks{nN}{trialT}(n-1));
        end
        eventEnds{nN}{trialT}(:,eventCount{nN}(:,trialT))=sAbove(end);
    elseif eventCount{nN}(:,trialT)==1
        eventEnds{nN}{trialT}(:,1)=sAbove(end);
    end
else
    eventStarts{nN}{trialT}=[];
end

% now just in case we have multiple small noise events that get detected
% make sure they each meat the min sample criteria.

tD=0;
if eventCount{nN}(:,trialT)>1
    tL=eventCount{nN}(:,trialT);
    for k=1:tL
        if (eventEnds{nN}{trialT}(:,n-tD)-eventStarts{nN}{trialT}(:,n-tD))+1 <minSamplesEvent(:,nN)
            eventCount{nN}(:,trialT)=eventCount{nN}(:,trialT)-1;
            eventStarts{nN}{trialT}(:,n-tD)=[];
            eventEnds{nN}{trialT}(:,n-tD)=[];
            tD=tD+1;
        else
        end
    end
else
end


clear sAbove
% we want to null the non-events, and use them for noise stats etc. 
% seed the replacement with first event (if there is one). we will still
% need to figure out how to pad the end


if eventCount{nN}(:,trialT)>0
newData(:,trialT,nN)=bdTT(:,trialT);
preEventSamples{nN}{trialT}=1:eventStarts{nN}{trialT}(:,1)-1;  % there is only one pre
preEventFs{nN}{trialT}=newData(preEventSamples{nN}{trialT},trialT,nN);
   

for n=1:eventCount{nN}(:,trialT)
    if n==eventCount{nN}(:,trialT)
        lastEvS=numel(allS);
    else
        lastEvS=eventStarts{nN}{trialT}(:,n+1)-1;
    end
    
    eventSamples{nN}{trialT}{n}=eventStarts{nN}{trialT}(:,n):eventEnds{nN}{trialT}(:,n); % something is adding
    postEventSamples{nN}{trialT}{n}=eventEnds{nN}{trialT}(:,n)+1:lastEvS;
        
    eventFs{nN}{trialT}{n}=newData(eventSamples{nN}{trialT}{n},trialT,nN);
    postEventFs{nN}{trialT}{n}=newData(postEventSamples{nN}{trialT}{n},trialT,nN);
%     pevF{nN}=[pevF{nN} postEventFs{nN}{trialT}{n}'];
%     evF{nN}=[evF{nN} eventFs{nN}{trialT}{n}'];
    
    % now we are using a derivative to detect so we need to be greedy and
    % get the peak too
    
    maxTestSamples=[eventSamples{nN}{trialT}{n} postEventSamples{nN}{trialT}{n}];
    [mv{nN}{trialT}{n},mi{nN}{trialT}{n}]=max(newData(maxTestSamples,trialT,nN));
    mi{nN}{trialT}{n}=mi{nN}{trialT}{n}+(eventSamples{nN}{trialT}{n}(1)-1);
    clear maxTestSamples
    
    eventSamples{nN}{trialT}{n}=eventStarts{nN}{trialT}(:,n):mi{nN}{trialT}{n};
    postEventSamples{nN}{trialT}{n}=mi{nN}{trialT}{n}+1:lastEvS;
    eventFs{nN}{trialT}{n}=newData(eventSamples{nN}{trialT}{n},trialT,nN);
    postEventFs{nN}{trialT}{n}=newData(postEventSamples{nN}{trialT}{n},trialT,nN);
    
    returnCut{nN}{trialT}=mean(preEventFs{nN}{trialT})+std(preEventFs{nN}{trialT}); % todo: I want to flag samples at the end to blank
%     newData(1:eventStarts{nN}{trialT}(:,n),trialT,nN)=newData(eventStarts{nN}{trialT}(:,n),trialT,nN);  % todo: should I go back a sample?

  
end
elseif eventCount{nN}(:,trialT)==0
    newData(:,trialT,nN)=bdTT(:,trialT);
    preEventSamples{nN}{trialT}=1:numel(allS);  % there is only one pre
    preEventFs{nN}{trialT}=newData(preEventSamples{nN}{trialT},trialT,nN);
    eventFs{nN}{trialT}=[];
end
end

end

%%
for nN=1:68

baselineAccum=[];
eventsAccum=[];
for trialT=1:numel(eventCount{nN})

    baselineAccum=[baselineAccum preEventFs{nN}{trialT}'];

if eventCount{nN}(trialT)>=1;
    
    corBase=newData(preEventSamples{nN}{trialT},trialT,nN);
    preCorFactor1=mean(newData(preEventSamples{nN}{trialT},trialT,nN));
    if numel(preEventSamples{nN}{trialT})>=4
        preCorFactor2=mean(newData(preEventSamples{nN}{trialT}(end-3:end),trialT,nN));
    elseif numel(preEventSamples{nN}{trialT})>=1
        preCorFactor2=newData(preEventSamples{nN}{trialT}(end),trialT,nN);
    elseif numel(preEventSamples{nN}{trialT})==0
         preCorFactor2=mean(newData(end-4:end,trialT,nN));
    end
    
    if numel(preEventSamples{nN}{trialT})==0
        corBase=preCorFactor2;
        tND=[];
    else
        corBase=repmat(preCorFactor2,size(newData(preEventSamples{nN}{trialT},trialT,nN)));
        tND=[corBase];
    end
    
    for n=1:eventCount{nN}(trialT)
        eventsAccum=[eventsAccum eventFs{nN}{trialT}{n}'];
        eventDataT{n}=newData(eventSamples{nN}{trialT}{n},trialT,nN);
        shiftFacE=min(eventDataT{n})-max(corBase);
        postEventDataT{n}=newData(postEventSamples{nN}{trialT}{n},trialT,nN);
        shiftFacPE=min(postEventDataT{n})-max(corBase);
        tND=vertcat(tND,eventDataT{n}-shiftFacE,postEventDataT{n}-shiftFacE);
        tND(find(tND<corBase(1)))=corBase(1);
    end
    tND(find(tND<corBase(1)))=corBase(1);
    newNewData(:,trialT,nN)=tND;
elseif eventCount{nN}(trialT)==0;
    corBase=newData(preEventSamples{nN}{trialT},trialT,nN);
    preCorFactor1=mean(newData(preEventSamples{nN}{trialT},trialT,nN));
    preCorFactor2=mean(newData(preEventSamples{nN}{trialT}(end-3:end),trialT,nN));
    corBase=repmat(preCorFactor2,size(newData(preEventSamples{nN}{trialT},trialT,nN)));
    newNewData(:,trialT,nN)=[corBase'];    
end
clear tND eventDataT postEventDataT corBase 
end
for trialT=1:numel(eventCount{nN})
    dataToFix=newNewData(:,trialT,nN);
    finShift=min(dataToFix)-mean(baselineAccum);
    newNewData(:,trialT,nN)=dataToFix-repmat(finShift,size(dataToFix));
end
baselineFsFlat{nN}=baselineAccum;
eventsFsFlat{nN}=eventsAccum;
clear baselineAccum eventsAccum
SNRs(:,nN)=dpSig(eventsFsFlat{n},baselineFsFlat{n});
ndW(:,nN)=reshape(newNewData(:,1:68,nN),68*240,1);
end



%%
newNewData(:,trialT,nN)=vertcat(corBase,eventData,postEventData);


if eventCount{nN}(trialT)>=1
    for n=1:eventCount{nN}(trialT)
        hold all,plot(eventSamples{nN}{trialT}{n},newData(eventSamples{nN}{trialT}{n},trialT,nN),'r')
        hold all,plot(postEventSamples{nN}{trialT}{n},newData(postEventSamples{nN}{trialT}{n},trialT,nN),'b')
        hold all,plot(preEventSamples{nN}{trialT},newData(preEventSamples{nN}{trialT},trialT,nN),'g')
        hold all,plot(preEventSamples{nN}{trialT},corBase,'k')

        hold all,plot(mi{nN}{trialT}{n},mv{nN}{trialT}{n},'ko')
    end
else
end
ylim([1000 5000])






%%
nN=10;
trialT=30;
figure,plot(newData(:,trialT,nN),'k-')
if eventCount{nN}(trialT)>=1
    for n=1:eventCount{nN}(trialT)
        hold all,plot(eventSamples{nN}{trialT}{n},newData(eventSamples{nN}{trialT}{n},trialT,nN),'r')
        hold all,plot(postEventSamples{nN}{trialT}{n},newData(postEventSamples{nN}{trialT}{n},trialT,nN),'b')
        hold all,plot(mi{nN}{trialT}{n},mv{nN}{trialT}{n},'ko')
    end
else
end
ylim([1000 5000])


%%
clear xx yy
n=1;
xx=(postEventSamples{nN}{trialT}{n}(1)-1): (postEventSamples{nN}{trialT}{n}(1)+50);
yy=newData(xx,trialT,nN);
blS=quantile(yy,0.1);
yy=newData(xx,trialT,nN)-blS;
figure,plot(xx,yy)


cccc=fit(xx',yy,'exp1','Robust','on','StartPoint', [5000 2]);
xx=postEventSamples{nN}{trialT}{n}';
hold all,plot(xx,cccc.a*exp(cccc.b*xx))
tau{nN}{trialT}{n}=1/cccc.b;

%%

for k=1:10
    accumT{k}=[];
    accumA{k}=[];
    evTs=find(eventCount{k}>=1);
    for n=1:numel(evTs)
        for m=1:eventCount{k}(evTs(n))
            clear xx yy
            tlp=min([(postEventSamples{nN}{evTs(n)}{m}(1)+50),numel(allS)]);
            xx=(postEventSamples{nN}{evTs(n)}{m}(1)-1): tlp;
            yy=newData(xx,evTs(n),nN);
            blS=quantile(yy,0.1);
            yy=newData(xx,evTs(n),nN)-blS;

            cccc=fit(xx',yy,'exp1','Robust','on','StartPoint', [5000 2]);
            tau{nN}{evTs(n)}{m}=1/cccc.b;
            accumT{k}=[accumT{k} tau{nN}{evTs(n)}{m}];
            accumA{k}=[accumA{k} max(yy)];
        end
    end
end

%%
k=1;
            badEvents{k}=find(accumT{k}>0 | accumT{k}<-500);
figure,nhist(accumT{k}(setdiff(1:numel(accumT{k}),badEvents{k})))

figure,nhist(accumA{k}(setdiff(1:numel(accumA{k}),badEvents{k})))


    
    



