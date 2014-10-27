function out=getMeansFromMasks(imageM,masksM)
    
out=zeros(1,numel(masksM));
for j=1:numel(masksM)
    out(1,j)=mean(imageM(masksM{j}(:,:)));
end

end