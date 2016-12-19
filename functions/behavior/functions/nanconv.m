function [Y,confidence] = nanconv(X,f)


fl=length(f);
padlength=floor(fl/2);
l=length(X);
Xp=padarray(X+1-1,[0 padlength],NaN,'both');
%Xp(1:padlength)=.5;

%clf;
%hold on;
%plot(X,'x')
%ylim([-.1 1.1]);

f=f./sum(f);

Y=X*0;
for i=1:l
    
    t= Xp([1:fl]+i-1)';
    
    datanum=sum(~isnan(t));
    
    ft=f;  ft(isnan(t))=0; 
    gotdatasum=sum(ft);
    ft=ft./sum(ft);
    
    ts=t.*ft';
    if gotdatasum > 0.1;
    Y(i)= sum( ts(~isnan(t))  ) ;
    else
    Y(i)=NaN;    
    end;
    
    confidence(i)=gotdatasum;
end;


%plot(X,'bx');
%plot(Y,'r');