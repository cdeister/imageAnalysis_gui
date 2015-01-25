function out=stackMean(stack)

if size(stack,3) ~= 1
    a=stack(:,:,1:2:end-1);
    b=stack(:,:,2:2:end);

    out=(a+b)./2;

elseif size(stack,3) == 1
    a=stack(:,1:2:end-1);
    b=stack(:,2:2:end);

    out=(a+b)./2;
end



end
