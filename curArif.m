%% stuff you should change ... 
% just add the path to the raw file
md.workingPath = '/Users/cad/Desktop/CYCLE_000001_RAWDATA_000028';
% change dimensions if needed
xDim = 256;
yDim = 256;
mSamp = 1;

%%
% indexed as y by x or lines by pixels
clear tt fImage taa

tPix = yDim * xDim * mSamp;
tFrames = numel(m.Data)/tPix;
for k=1:tFrames
    clear tt fImage taa33st
    tt = m.Data(1+((k-1)*tPix):tPix*k);
    taa=reshape(tt,xDim*2*mSamp,yDim/2)';
    taa(:,1:xDim*mSamp)=fliplr(taa(:,1:xDim*mSamp));
    fImage = uint16(zeros(xDim,yDim));
    fImage(1:2:yDim,:)=taa(1:end,1:xDim*mSamp);
    fImage(2:2:yDim,:)=taa(1:end,(xDim*mSamp)+1:xDim*2);
    cStack(:,:,k) = fImage;
end

