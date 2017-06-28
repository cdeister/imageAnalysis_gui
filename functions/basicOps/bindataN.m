function [b,n,s]=bindataN(x,y,gx)
% [b,n,s]=bindata(x,y,gx)
% Bins y(x) onto b(gx), gx defining centers of the bins. NaNs ignored.
% Optional return parameters are:
% n: number of points in each bin   
% s: standard deviation of data in each bin 
% A.S.

[yr,yc]=size(y);

x=x(:);y=y(:);
idx=find(~isnan(y));
if (isempty(idx)) b=nan*gx;n=nan*gx;s=nan*gx;return;end

x=x(idx);
y=y(idx);

xx = gx(:)';
binwidth = diff(xx) ;
xx = [xx(1)-binwidth(1)/2 xx(1:end-1)+binwidth/2 xx(end)+binwidth(end)/2];

% Shift bins so the interval is "( ]" instead of "[ )".
bins = xx + max(eps,eps*abs(xx));

[nn,bin] = histc(x,bins,1);
nn=nn(1:end-1);
nn(nn==0)=NaN;

idx=find(bin>0);
sum=full(sparse(bin(idx),idx*0+1,y(idx)));
sum=[sum;zeros(length(gx)-length(sum),1)*nan];% add zeroes to the end
b=sum./nn;

if nargout>1, n=nn;end
if nargout>2
	sum=full(sparse(bin(idx),idx*0+1,y(idx).^2));
	sum=[sum;zeros(length(gx)-length(sum),1)*nan];	% add zeroes to the end
   s=sqrt(sum./(nn-1) - b.^2.*nn./(nn-1) );
end
