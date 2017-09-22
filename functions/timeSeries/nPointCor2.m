function [sCor]=nPointCor2(d1,d2,bS)

% d1 and d2 are two data vectors
% bS is the binSize you want to do the correlation in
% this vector will be truncated to n-bS, where n is the length of the
% vector. You can manually center if you like. Technically you should start
% t=0 as t=bS/2 I am not doing that here so you have options.

st1=size(d1);
st2=size(d2);

if isa(d1,'double')==0
    d1=double(d1);
end

if isa(d2,'double')==0
    d2=double(d2);
end

% I want N x 1, transpose if pased something else
if st1(1)<st1(2)
    d1=d1';
end

if st2(1)<st2(2)
    d2=d2';
end

% just in case someone passes a matrix
% i didn't want to deal with all the error cases, so I just make a vector. 
% please feel free to add!
d1=d1(:,1);
d2=d2(:,1);

sCor=zeros(numel(d1)-bS,1);
tLen=numel(d1);
for n=1:tLen-bS
    sCor(n,1)=corr(d1(n:n+bS),d2(n:n+bS));
end

end