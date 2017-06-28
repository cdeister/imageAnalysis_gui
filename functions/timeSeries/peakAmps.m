function [val,pos]=peakAmps(data)
% simple gets the min or the max depending on which is bigger.


for k=1:size(data,3),
    for n=1:size(data,2)
        if abs(min(data(:,n,k)))>abs(max(data(:,n,k)))
            [val(:,n,k),pos(:,n,k)]=min(data(:,n,k));
        elseif abs(min(data(:,n,k)))<abs(max(data(:,n,k)))
            [val(:,n,k),pos(:,n,k)]=max(data(:,n,k));
        end
    end
end

end


    
    
