function [quantileCutoffs,baselineValues]=computeQunatileCutoffs(dataMatToCut,startVal,minVal,dimToCut)

% Computes a 'ranked' quantile cutoff for data baselining purposes. 
% Some data have more variance than others, yet in a population recording, without groundtruth, we have to estimate the baseline.
% The goal is to estimate the mean of the 'noise floor' in a way that accounts for variable skew.
% Arguments: dataMatToCut (required) is your data, which can be 1d or 2d. startVal and minVal are optional args that constrain
% the range of valid quantile cutoffs. By default, startVal is 0.25 and minVal is 0.05. dimToCut is another optional argument,
% which tells it which dimension is the time dimension.
% Products: quantileCutoffs is a list of quantiles that is as long as the non-time dimension of your data. This can be used to 
% baseline your data (with a different function or method). baselineValues are the static baseline value that is the quantile you
% computed. This can be used to directly baseline your data. 
%
% "algorithm" for quantile choice: Chris Deister
% cdeister@brown.edu with questions

if nargin==1
    startVal=0.25;
    minVal=0.05;
    [~,cutDim]=min(size(dataMatToCut));
end

if cutDim==1
    dataMatToCut=dataMatToCut';
else
end


for n=1:size(dataMatToCut,2)
    
    tScore=(quantile(dataMatToCut(:,n),0.5)-quantile(dataMatToCut(:,n),startVal))./quantile(dataMatToCut(:,n),0.5);
    qCut=(startVal-tScore);
    
    if qCut<minVal
        qCut=minVal;
    else
    end
    
    quantileCutoffs(n)=qCut;
    baselineValues(n)=quantile(dataMatToCut(:,n),qCut);

end