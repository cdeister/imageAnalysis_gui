function [ym,yb,ystd] = bindata(y,x,xrg)
    %function [ym,yb] = bindata(y,x,xrg)
    %Computes ym(ii) = mean(y(x>=xrg(ii) & x < xrg(ii+1)) for every ii
    %using a fast algorithm which uses no looping
    %If a bin is empty it returns nan for that bin
    %Also returns yb, the approximation of y using binning (useful for r^2
    %calculations). Example:
    %
    %x = randn(100,1);
    %y = x.^2 + randn(100,1);
    %xrg = linspace(-3,3,10)';
    %[ym,yb] = bindata(y,x,xrg);
    %X = [xrg(1:end-1),xrg(2:end)]';
    %Y = [ym,ym]'
    %plot(x,y,'.',X(:),Y(:),'r-');
    %
    %By Patrick Mineault
    %Refs: https://xcorr.net/?p=3326
    %      http://www-pord.ucsd.edu/~matlab/bin.htm
    [~,whichedge] = histc(x,xrg(:)');
 
    bins = min(max(whichedge,1),length(xrg)-1);
    xpos = ones(size(bins,1),1);
    ns = sparse(bins,xpos,1)
    ysum = sparse(bins,xpos,y);
    b=ysum./ns;
    ym = full(ysum)./(full(ns));
    yb = ym(bins);
    
    ystd=((ysum./(ns-1))-(b.^2.*ns./(ns-1)))./sqrt(ns-1);
    
end