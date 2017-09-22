function [out,n]=nPointSem(idata,np)

ogNumel=numel(idata);

% element count in each window
n = conv(ones(1, ogNumel), ones(1, np), 'same');

% calculate s vector
s = conv(idata, ones(1, np), 'same');

% calculate q vector
q = idata .^ 2;
q = conv(q, ones(1, np), 'same');

% calculate output values
o = (q - s .^ 2 ./ n) ./ (n - 1);

% have to take the square root since output o is the 
% square of the standard deviation currently
o = o .^ 0.5
out=real(o);
end