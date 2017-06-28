function [outDataDFs]=batchDeltaF(data_matrix,quant_bin)

% Many DFs

%Pre-Allocate Array
outDataDFs=zeros(size(data_matrix));

for i=1:size(data_matrix,2)
    baseline=quantile(data_matrix(:,i),quant_bin);
    outDataDFs(:,i)=(data_matrix(:,i)-baseline)*baseline^-1;
end
end