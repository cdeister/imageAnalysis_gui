function out=resampleCalciumData(dataMatrix,originalTimeVector,targetTimeVector)

% Make the data time-series. This is the slow route, but is the
% easiest/best way to interpolate data sampled at odd intervals.

warning('off','all');
for i=1:size(dataMatrix,2)
        a(i)=timeseries(dataMatrix(:,i),originalTimeVector);
        r(i)=resample(a(1,i),targetTimeVector);  % 'zoh'
        out(:,i)=r(i).data;
end
warning('on','all');