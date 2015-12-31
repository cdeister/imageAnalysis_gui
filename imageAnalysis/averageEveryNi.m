function out=averageEveryNi(data,N)
% assumes you have data(x,y) where x is frames and y is cells, etc. 

if ~mod(size(data,1)/N,1) 
    a=reshape(data,N,size(data,2),[]);
    aa=sum(a,1)./size(a,1);
    out=reshape(aa,size(data,1)/N,size(data,2));
else
    error('Your data is not divisible by N, choose a different N')
end
