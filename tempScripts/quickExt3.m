xMask=somaticROIs{13};
[yV,xV]=ind2sub(size(xMask),find(xMask==1));
pOfs=10;
pOfs=fix(pOfs/2);
yStrt=min(yV)-pOfs;
yEnd=max(yV)+pOfs;
xStrt=min(xV)-pOfs;
xEnd=max(xV)+pOfs;
cInds={yStrt:yEnd,xStrt:xEnd};
clpReg={[min(cInds{1}) max(cInds{1})],[min(cInds{2}) max(cInds{2})]};
tImPath=[folderz{tFrm} filesep namez{tFrm}];

clTmpl=double(regTemplate(cInds{1},cInds{2}));
clMsk=xMask(cInds{1},cInds{2});


tFrm=9;
impImageA=double(imread(tImPath,'PixelRegion',clpReg));
[out1,out2]=dftregistration(double(clMsk),fft2(impImageA),100);
impImageB=abs(ifft2(out2));

figure
colormap csred
subplot(2,2,1)
imagesc(impImageA,[0 1000]),axis square,colormap csred

subplot(2,2,2)
imagesc(xMask(cInds{1},cInds{2})),axis square

subplot(2,2,3)
imagesc(clTmpl,[0 1000]),axis square

subplot(2,2,4)
imshowpair(impImageA,impImageB),axis square
