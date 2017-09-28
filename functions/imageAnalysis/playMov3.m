function [outStack,outMu,outMedian,outStd]=playMov3(stack,rate,gridNums,fNum,popThreshs)
    hh=figure(fNum);
    


    
    for i=1:size(stack,1)
        ii=reshape(stack(i,:),gridNums(1),gridNums(2));
        
        h=imagesc(ii,[popThreshs(1) popThreshs(2)]);
        daspect([1 1 1])
        axis square

        drawnow;
        
        pause(rate^-1);
        delete(h);
        clear ii
    end
    
    
   
end

 