fCount=numel(flagged_somaticROI);
fI=flagged_somaticROI;

somaticF(fI,:)=[];
somaticRoiCounter=somaticRoiCounter-fCount;
somaticROI_PixelLists(fI)=[];
somaticROIBoundaries(fI)=[];
somaticROICenters(fI)=[];
somaticROIs(fI)=[];

neuropilF(fI,:)=[];
neuropilRoiCounter=neuropilRoiCounter-fCount;
neuropilROI_PixelLists(fI)=[];
neuropilROIBoundaries(fI)=[];
neuropilROICenters(fI)=[];
neuropilROIs(fI)=[];

clear flagged_somaticROI fI fCount