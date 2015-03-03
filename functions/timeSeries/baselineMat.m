function out=baselineMat(mat,window)

% window is a 2 element vector

blv=mean(mat(window(1):window(2),:,:),1);
blm=repmat(blv,size(mat,1),1,1);

out=mat-blm;
end

