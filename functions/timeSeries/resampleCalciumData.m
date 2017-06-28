function out=resampleCalciumData(dataMatrix,originalTimeVector,targetTimeVector)

% Make the data time-series. This is the slow route, but is the
% easiest/best way to interpolate data sampled at odd intervals.

warning('off','all');

if numel(size(dataMatrix))==3
    endT=size(dataMatrix,3);
else
    endT=1;
end


for k=1:endT
    for i=1:size(dataMatrix,2)
        a(i)=timeseries(dataMatrix(:,i,k),originalTimeVector);
        r(i)=resample(a(1,i),targetTimeVector);  % 'zoh'
        out(:,i,k)=r(i).data;
        clear a
        clear r
    end
end

out=squeeze(out);
warning('on','all');