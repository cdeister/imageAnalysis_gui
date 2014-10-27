function playMov(stack)


    mfactor=.3;
    ii=1;
    for i=1:size(stack,3)
        ii=(ii.*(1-mfactor))+stack(:,:,i).*mfactor;
        h=imagesc(ii);
        drawnow;
        delete(h);
    end;
