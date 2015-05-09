function out=zscoreMat(mat,window)

% window is a 2 element vector

blv=mean(mat(window(1):window(2),:,:),1);
blm=repmat(blv,[size(mat,1) 1 1]);


bld=mat-blm;
stdD=std(bld(window(1):window(2),:,:),1,1);
meanD=mean(bld(window(1):window(2),:,:),1);
blStd=repmat(stdD,[size(mat,1) 1 1]);
blMean=repmat(meanD,[size(mat,1) 1]);

out=(bld-blMean)./blStd;

end

