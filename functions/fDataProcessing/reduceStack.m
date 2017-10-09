function reduceStack(dataMat,masksToUseCell,cMapStr,dRange,toPlot)

normData=(dataMat./max(dataMat)).*dRange;
normData=fix(normData)+abs(min(fix(normData)))+1;

normMax=max(max(normData))
normMin=min(min(normData))
maxRange=numel(1:normMax)

aa=eval(['colormap(' cMapStr '(maxRange));']);

for n=1:size(dataMat,2)
    scaledNorm(:,:,n)=aa(normData(:,n),:);
end

size(aa)
size(scaledNorm)
fH=figure(99);

tRGBs=zeros(size(masksToUseCell{1},1),size(masksToUseCell{1},2),3,size(dataMat,1));

if toPlot
for k=1:size(dataMat,2)    
    for n=1:size(dataMat,1) 
        tRGBs(:,:,:,n)=cat(3,masksToUseCell{n}.*scaledNorm(k,1,n),masksToUseCell{n}.*scaledNorm(k,2,n),masksToUseCell{n}.*scaledNorm(k,3,n));
    end
    h=imshow(sum(tRGBs,4));
    daspect([1 1 1])
    drawnow;
    pause(0.0001)
    delete(h);
end
else
end


end