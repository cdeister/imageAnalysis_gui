function plotTrialTrain2(trialTrainMat)
    figure
    hold all
    datPlt=squeeze(trialTrainMat(:,:));
    for n=1:size(datPlt,2)
        tSpikes=find(datPlt(:,n)==1);
        for k=1:numel(tSpikes)
            plot([tSpikes(k)./10000 tSpikes(k)./10000],[0+n 1+n],'k-')
        end
    end
    xlim([0 1.5])
    ylim([0 n+2])
end
