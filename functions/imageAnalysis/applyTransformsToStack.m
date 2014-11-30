function out=applyTransformsToStack(stack,transforms,parFlag)

sS=size(stack,3);

if nargin>2 && parFlag==1
    parfor n=1:sS
        out(:,:,n)=applyRegTransforms(stack(:,:,n),transforms(:,n));
    end
else
    for n=1:sS
        out(:,:,n)=applyRegTransforms(stack(:,:,n),transforms(:,n));
    end
end
end
    
