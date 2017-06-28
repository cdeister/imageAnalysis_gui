function [out_z]=blZscore(data,bl_window,smooth_sz)

% blZscore --> Baseline some data by z-scoring relative 
% needs batchSmooth if you want to smooth
%

blWn=bl_window;
winSize=smooth_sz;

aa=batchSmooth(data,winSize);

blD=aa(blWn,:);
blMu=mean(mean(blD,2));
blSig=mean(std(blD,1,2));
blMu=repmat(blMu,size(aa));
blSig=repmat(blSig,size(aa));

out_z=((aa-blMu)./blSig);

end
