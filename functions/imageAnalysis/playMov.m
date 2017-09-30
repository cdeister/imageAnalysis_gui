function playMov(stack,rate,scBounds)
    if nargin==1
        rate=30;

        mfactor=.3;
        ii=1;
        for i=1:size(stack,3)
            axis square
            ii=(ii.*(1-mfactor))+stack(:,:,i).*mfactor;
            h=imagesc(ii);
            axis square
            colormap('jet')
            daspect([1 1 1])
            drawnow;
            pause(rate^-1);
            delete(h);
        end
    else
        mfactor=.3;
        ii=1;
        for i=1:size(stack,3)
            axis square
            ii=(ii.*(1-mfactor))+stack(:,:,i).*mfactor;
            h=imagesc(ii,scBounds);
            axis square
            colormap('jet')
            daspect([1 1 1])
            drawnow;
            pause(rate^-1);
            delete(h);
        end
    end

 