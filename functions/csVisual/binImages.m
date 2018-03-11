function imOut=binImages(imsToBin,bB)

imSz=size(imsToBin);
d3=size(imsToBin,3);

nD1=fix(imSz(1)/bB);
nD2=fix(imSz(2)/bB);




imOut=squeeze(mean(squeeze(mean(reshape(imsToBin,bB,nD1,bB,nD2,d3))),2));

end