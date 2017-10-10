% init
clear newData1 normData aa scaledNorm dataToProject normMax normMin   cellRange maxRange tRGBs
cellRange=[32 261 266 264 269 262 263 33 128 141 268 267 50 136];
dataToProject=nPointMean(somaticF(cellRange,:)',1);
dRange=100;
cMapStr='jet';

normData=(dataToProject./max(dataToProject)).*dRange;
normData=fix(normData)+abs(min(fix(normData)))+1;


normMax=max(max(normData));
normMin=min(min(normData));
maxRange=numel(1:normMax);


aa=eval(['colormap(' cMapStr '(maxRange));']);
pMasks=somaticROIs(cellRange);

for n=1:numel(cellRange)
    scaledNorm(:,:,n)=aa(normData(:,n),:);
end

%%
focusStack=zeros(size(pMasks{n},1),size(pMasks{n},2),3,1000);
tRGBs=zeros(size(pMasks{n},1),size(pMasks{n},2),3,numel(cellRange));

tic
for k=1:1000    
    for n=1:numel(cellRange)
        tRGBs(:,:,:,n)=cat(3,pMasks{n}.*scaledNorm(k,1,n),pMasks{n}.*scaledNorm(k,2,n),pMasks{n}.*scaledNorm(k,3,n));
    end
    focusStack(:,:,:,k)=sum(tRGBs,4);
end
toc


%%
fH=figure(99);

%just play
for k=1:14000    
    h=imshow(focusStack(:,:,:,k));
    daspect([1 1 1])
    drawnow;
    pause(0.001);
    delete(h);
end

%% play and render (test)
fH=figure(99);
xx=1;
tRGBs=zeros(size(pMasks{n},1),size(pMasks{n},2),3,numel(cellRange));
while xx==1
for k=1:14000    
    for n=1:numel(cellRange)
        tRGBs(:,:,:,n)=cat(3,pMasks{n}.*scaledNorm(k,1,n),pMasks{n}.*scaledNorm(k,2,n),pMasks{n}.*scaledNorm(k,3,n));
    end
    h=imshow(sum(tRGBs,4));
    daspect([1 1 1])
    drawnow;
    pause(0.0001)
    delete(h);
end
end