% full neuropil correction
neuropilWF=0.8;
for n=1:size(neuropilF,3)
    nanCnt(:,n)=numel(find(isnan(neuropilF(n,:))==1));
end

badNeuropil=find(nanCnt>0);
goodNeuropil=find(nanCnt==0);
for n=1:numel(badNeuropil)
    badCentroids(:,:,n)=somaticROICenters{badNeuropil(n)}.Centroid; 
end


for n=1:numel(goodNeuropil)
    goodCentroids(:,:,n)=somaticROICenters{goodNeuropil(n)}.Centroid;
end

if numel(badNeuropil)>0

    for n=1:numel(badNeuropil)
        tS=squeeze(abs(goodCentroids-badCentroids(:,:,n)));
        badDists=tS(1,:)./tS(2,:);
        [mV,mI]=min(badDists);
        closestMask(:,n)=goodNeuropil(mI);
    end
    neuropilF(badNeuropil,:)=neuropilF(closestMask,:);
else
end

somaticFBU=somaticF;
somaticF=somaticF-neuropilF*neuropilWF;
% screenROI=49;
% somaticF=somaticF-somaticF(screenROI,:);
% somaticF(screenROI,:)=somaticFBU(screenROI,:)-neuropilF(screenROI,:)*neuropilWF;
% % now make sure all is positive
% somaticF=somaticF+abs(min(somaticF')');