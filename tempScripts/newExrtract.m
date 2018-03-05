frmCnt=size(green,3);
cellCnt=numel(neuropilROIs);
neuropilF=zeros(cellCnt,frmCnt);

tic
for j=1:frmCnt
    if mod(j,200)==0
        disp(['finished ' num2str(j) ' of ' num2str(frmCnt)])
    else
    end
    curGreen=double(green(:,:,j));
    for n=1:cellCnt
        cMask=neuropilROIs{n};
        [yV,xV]=ind2sub(size(cMask),find(cMask==1));
        cutMask=cMask(min(yV):(min(yV)+(numel(unique(yV)))-1),...
            (min(xV):min(xV)+(numel(unique(xV)))-1));
        neuropilF(n,j)=mean2(curGreen(cutMask==1));
%         neuropilF(n,j)=median(reshape(curGreen(cutMask==1),numel(curGreen(cutMask==1)),1));
    end
end
toc

