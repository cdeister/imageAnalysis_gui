%% Analyze Spotaneous Data
imTime = frameDelta:frameDelta:frameDelta*size(somaticF,2);

try
    somaticF = dataBU.somaticF_original;
catch
    try
        somaticF = somaticF_original;
    catch
    end
end

scaleForNeg = 0;
framesToMovAvg = 6;

% make a backup of the original F data
dataBU.somaticF_original = somaticF;
if exist('neuropilF')
    dataBU.neuropilF_original = neuropilF;
    
    neuropilCorrectionFactor = 0.8;
    somaticF = somaticF - (neuropilCorrectionFactor*neuropilF);
else
end


if scaleForNeg == 1

    % now we make DF/F
    % a) add an offset, so we don't get negative values for df/f
    % the offset will affect df/f so we will rescale later by the error. 
    % the error is the ratio of the original mean and the scalar.
    somaticF = somaticF + 10000;
else
end


% now take a moving average of a few frames for a first-pass low-pass
% filter
somaticF = nPointMean(somaticF',framesToMovAvg);
somaticF = somaticF';

% Now let's estimate the baselines. The quantile cut-off is calculated
% based on the statistics of the F distributions.
baselineWindow = 500;
blCutOffs = computeQunatileCutoffs(somaticF);
somaticF_BLs=slidingBaseline(somaticF,baselineWindow,blCutOffs);

% now the DF is the (F-BL)/BL
somaticF_DF = (somaticF - somaticF_BLs)./somaticF_BLs;

%
dataBU.somaticF_DF=somaticF_DF;    
dataBU.somaticF_BLs=somaticF_BLs; 

if scaleForNeg == 1
    % now we fix df for our scalar.
    scaleError = 10000/nanmean(nanmean(dataBU.somaticF_original));
    somaticF_DF=somaticF_DF*scaleError;
else
end

disp('data are baselined and df/f computed')