numFrames=45000;
testNeuropilF=zeros(1,numFrames);
xMask=neuropilROIs{13};
[yV,xV]=ind2sub(size(xMask),find(xMask==1));
pOfs=10;
pOfs=fix(pOfs/2);
yStrt=min(yV)-pOfs;
yEnd=max(yV)+pOfs;
xStrt=min(xV)-pOfs;
xEnd=max(xV)+pOfs;
cInds={yStrt:yEnd,xStrt:xEnd};
clpReg={[min(cInds{1}) max(cInds{1})],[min(cInds{2}) max(cInds{2})]};


clTmpl=double(regTemplate(cInds{1},cInds{2}));
clMsk=xMask(cInds{1},cInds{2});
tic
parfor k=1:numFrames
    tImPath=[folderz{k} filesep namez{k}];
    impImageA=imread(tImPath,'PixelRegion',clpReg);
    [out1,out2]=dftregistration(clTmpl,fft2(impImageA),100);
    impImageB=abs(ifft2(out2));
    testNeuropilF(1,k)=mean(impImageB(clMsk==1));
%     if mod(k,500)==0
%         disp(['done with ' num2str(k) ' frames of ' num2str(numFrames)])
%     else
%     end
end
toc

