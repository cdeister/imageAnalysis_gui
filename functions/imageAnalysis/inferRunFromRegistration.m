function out=inferRunFromRegistration(transforms,smoothValue)

if nargin==1
    sV=20;
else
    sV=smoothValue;
end
    out=abs(diff(transforms));
    out=[out(:,1),out];
    out=smooth(out,sV);
    out=out./max(out);

end