function [outDataSmooth]=batchSmooth(data_matrix,samplesToSmooth,dim,parF)

% Many DFs


if nargin==1
        %Pre-Allocate Array
    outDataSmooth=zeros(size(data_matrix));

    for i=1:size(data_matrix,2)
        outDataSmooth(:,i)=smooth(data_matrix(:,i));
    end
elseif nargin==2
        %Pre-Allocate Array
    outDataSmooth=zeros(size(data_matrix));

    for i=1:size(data_matrix,2)
        outDataSmooth(:,i)=smooth(data_matrix(:,i),samplesToSmooth);
    end
elseif nargin==3
        %Pre-Allocate Array
    outDataSmooth=zeros(size(data_matrix));
    if dim==2
        for i=1:size(data_matrix,2)
            outDataSmooth(:,i)=smooth(data_matrix(:,i),samplesToSmooth);
        end
    elseif dim==3
        for j=1:size(data_matrix,3)
            for i=1:size(data_matrix,2)
                outDataSmooth(:,i,j)=smooth(data_matrix(:,i,j),samplesToSmooth);
            end
        end
    end
    
elseif nargin==4
        %Pre-Allocate Array
    outDataSmooth=zeros(size(data_matrix));
    if dim==2 && parF==1
        parfor i=1:size(data_matrix,2)
            outDataSmooth(:,i)=smooth(data_matrix(:,i),samplesToSmooth);
        end
    elseif dim==2 && parF==0
        for i=1:size(data_matrix,2)
            outDataSmooth(:,i)=smooth(data_matrix(:,i),samplesToSmooth);
        end
    elseif dim==3 && parF==1
        for j=1:size(data_matrix,3)
            parfor i=1:size(data_matrix,2)
                outDataSmooth(:,i,j)=smooth(data_matrix(:,i,j),samplesToSmooth);
            end
        end
    elseif dim==3 && parF==0
        for j=1:size(data_matrix,3)
            for i=1:size(data_matrix,2)
                outDataSmooth(:,i,j)=smooth(data_matrix(:,i,j),samplesToSmooth);
            end
        end
    end
end

    

    


end