frmCnt=size(importedImages,3);
cellCnt=numel(somaticROIs);
somaticF=zeros(cellCnt,frmCnt);

tic
for j=1:frmCnt
    for n=1:cellCnt
        cMask=somaticROIs{n};
        [yV,xV]=ind2sub(size(cMask),find(cMask==1));
        cInds={min(yV):(min(yV)+(numel(unique(yV)))-1),(min(xV):min(xV)+(numel(unique(xV)))-1)};
        cutMask=cMask(cInds{1},cInds{2});
        curGreen=importedImages(cInds{1},cInds{2},j);
        somaticF(n,j)=mean2(curGreen(cutMask==1));
    %         neuropilF(n,j)=median(reshape(curGreen(cutMask==1),numel(curGreen(cutMask==1)),1));
        if mod(j,100)==0
            disp(['finished ' num2str(j) ' of ' num2str(frmCnt)])
        else
        end
    end
end
toc
figure(22)
plot(somaticF')

