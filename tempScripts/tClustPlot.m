d1=256;
d2=256;
tMask=zeros(d1,d2);
showGoodBad=0;
thresholdGoodBad=1;



for n=1:numel(debugClus)
    cpixel=floor(debugClus(n)/d1);
    cline=rem(debugClus(n),d2);
    if showGoodBad==1
        if ismember(debugGIDs(n),debugGClus)
            tMask(cline,cpixel)=1;
        else
            tMask(cline,cpixel)=0;
        end
    elseif showGoodBad==0
        tMask(cline,cpixel)=debugGIDs(n);
    elseif thresholdGoodBad==1
        if ismember(debugGIDs(n),debugGClus)
            tMask(cline,cpixel)=debugGIDs(n);
        else
            tMask(cline,cpixel)=0;
        end
        
    end
end
figure

imagesc(tMask),axis square,colormap jet