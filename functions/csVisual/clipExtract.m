function clipExtract(rMask,tImage,rTemplate)

[yV,xV]=ind2sub(size(rMask),find(rMask==1));

if nargin==3
	cutTemplate=regTemplate(min(yV):(min(yV)+(numel(unique(yV)))-1),(min(xV):min(xV)+(numel(unique(xV)))-1));
	cutFTemplate=fft2(cutTemplate);
	regImp=1;
else
	regImp=0;
end	
cutMask=cMask(min(yV):(min(yV)+(numel(unique(yV)))-1),(min(xV):min(xV)+(numel(unique(xV)))-1));

numFrames=27738;
fG=zeros(numFrames,1);
clpImgs=zeros(horzcat(size(cutMask),numFrames));
tic
imList=1:numFrames;

for v=1:numel(imList)
    impImage=h5read([metaData.importPath metaData.hdfFile],'/ccdMap_ci03-001_images',[min(yV) min(xV) ],[numel(unique(yV)) numel(unique(xV)) 1]);
%     [rShift,rImage]=regFrame(impImage,cutFTemplate);
%     rImage=medfilt2(rImage);
%     clpImgs(:,:,v)=rImage;
    fG(v)=mean2(impImage(cutMask==1));
end
toc



