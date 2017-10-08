function out=applyTransformsToStack(stack,transforms,parFlag)

sS=size(stack,3);

tClass=class(stack);

if nargin>2 && parFlag==1
    parfor n=1:sS
        out(:,:,n)=applyRegTransforms(double(stack(:,:,n)),transforms(:,n));
    end
else
    for n=1:sS
        out(:,:,n)=applyRegTransforms(double(stack(:,:,n)),transforms(:,n));
    end
end

if strcmp(tClass,'uint16') 
    out=uint16(out);
elseif strcmp(tClass,'uint8') 
    out=uint8(out);
end
   
end
    
