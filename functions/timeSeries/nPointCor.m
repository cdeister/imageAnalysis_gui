function Cor = nPointCor(Data1,Data2,k)

% Filter approach was not my idea, mine was obvious and slower.
% credit to maagen for filter idea.
% https://www.mathworks.com/matlabcentral/newsreader/view_original/931654
% added real call

if isa(Data1,'double')==0
    Data1=double(Data1);
end

if isa(Data2,'double')==0
    Data2=double(Data2);
end

y = zscore(Data2);
n = size(y,1);


if (n<k)
    Cor = NaN(n,1);
else
    x = zscore(Data1);
    x2 = x.^2;
    y2 = y.^2;
    xy = x .* y;
    A=1;
    B = ones(1,k);
    Stdx = sqrt((filter(B,A,x2) - (filter(B,A,x).^2)*(1/k))/(k-1));
    Stdy = sqrt((filter(B,A,y2) - (filter(B,A,y).^2)*(1/k))/(k-1));
    Cor = (filter(B,A,xy) - filter(B,A,x).*filter(B,A,y)/k)./((k-1)*Stdx.*Stdy);
    Cor(1:(k-1)) = NaN;
end
Cor=real(Cor);
end