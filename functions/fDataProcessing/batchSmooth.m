function [outDataSmooth]=batchSmooth(data_matrix,samplesToSmooth)

% Many DFs


if nargin==1
    %Pre-Allocate Array
    outDataSmooth=zeros(size(data_matrix));

    for i=1:size(data_matrix,2)
        outDataSmooth(:,i)=smooth(data_matrix(:,i));
    end
else
        %Pre-Allocate Array
    outDataSmooth=zeros(size(data_matrix));

    for i=1:size(data_matrix,2)
        outDataSmooth(:,i)=smooth(data_matrix(:,i),samplesToSmooth);
    end
end