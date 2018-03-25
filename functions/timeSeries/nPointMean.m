function [out]=nPointMean(idata,np)

idata(isnan(idata))=0;

if numel(size(idata))==2 && size(idata,1)<size(idata,2)
    idata=idata';
else
end
    

if np>0
    c1=fix(np./2);
    idata=padarray(idata,c1,'symmetric');
    kern=zeros(size(idata));
    kern(1:np,:)=(1./np);

    out=ifft(fft(idata).*fft(kern));
    if mod(np,2)
        out=out(np:end,:);
    else
        out=out(np+1:end,:);
    end
elseif np==0
    out=idata;        
else
    disp('np must be a positive integer')
end


end