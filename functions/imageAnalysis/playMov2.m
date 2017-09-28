function [outStack,outMu,outMedian,outStd]=playMov2(stack,rate,gridNums,fNum,popThreshs,yMax)
    figure(fNum)
    subplot(1,2,1)


    
    for i=1:size(stack,1)
        ii=reshape(stack(i,:),gridNums(1),gridNums(2));
        outStack(:,:,i)=ii;
        sss=sum(ii');
        sss(sss<popThreshs(1))=0;
        ttt(:,i)=sum(sss);
        ttt(ttt<popThreshs(2))=0;
        iii(:,i)=i;
        
        subplot(1,3,1)
        h=imagesc(ii,[0 2]);
        daspect([1 1 1])
        axis square

     
        
        subplot(1,3,2)
        i=imagesc(sss',[popThreshs(1) yMax]);
        colormap('jet')
        daspect([1 1 1])
        axis square

        
        subplot(1,3,3)
        j=plot(iii,ttt,'k-');
        ylim([0 yMax])
        %daspect([1 1 1])
        axis square
        drawnow;
        
        
        pause(rate^-1);
        delete(h);
        delete(i);
        delete(j);
        clear ii sss
    end
    
    
    outMu=mean(ttt(10:150));
    outMedian=median(ttt(10:150));
    outStd=std(ttt(10:150));
    disp(median(ttt(10:150)))
    disp(mean(ttt(10:150)))
    disp(std(ttt(10:150)))
    
end

 