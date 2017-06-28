function [outXY,normOut,outX,outY]=nPointDeriv(ydata,xdata,np)

ydata(isnan(ydata))=0;

ogNumel=numel(ydata);



% determine if odd or even.
if mod(np,2)==0
    evenFlag=1;
    dP=round(np/2);
    stPt=dP+1;
elseif mod(np,2)~=0
    evenFlag=0;
    dP=round(np/2)-1;
    stPt=dP+1;
    if np==1
        dP=1;
        stPt=dP+1;
    end
end


for n=stPt:ogNumel-stPt
    outY(:,n)=(ydata(n+dP)-ydata(n-dP));
    outX(:,n)=(xdata(n+dP)-xdata(n-dP));
end


outY(:,n+1:ogNumel)=outY(end);
outX(:,n+1:ogNumel)=outX(end);


outY(outY==0)=NaN;
outX(outX==0)=NaN;

outXY=outY./outX;



normOut=outXY./max(outXY);


end