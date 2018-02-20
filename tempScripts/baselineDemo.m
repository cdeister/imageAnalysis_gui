%%
for n=1:size(somaticF,1)
    scorez(:,n)=(quantile(somaticF(n,:)',0.5)-quantile(somaticF(n,:)',0.25))./quantile(somaticF(n,:)',0.5);
    qCut=(0.25-scorez(n));
    if qCut<0.05
        qCut=0.05;
    else
    end
    qCutz(:,n)=qCut;
    propBelow(:,n)=numel(find(somaticF(n,:)'<quantile(somaticF(n,:)',qCut)))

end
figure
plot(propBelow)
figure
nhist(propBelow,'box')

%%
n=10;
%%
figure(109)

qCut=(0.25-scorez(n));
if qCut<0.05
    qCut=0.05;
else
end

subplot(2,2,[1 3])
plot(somaticF(n,:)','k-')
hold all
plot([1 1000],[mean(somaticF(n,:)') mean(somaticF(n,:)')],'k:')
plot([1 1000],[median(somaticF(n,:)') median(somaticF(n,:)')],'m:')
plot([1 1000],[quantile(somaticF(n,:)',0.25) quantile(somaticF(n,:)',0.25)],'b:')
plot([1 1000],[quantile(somaticF(n,:)',qCut) quantile(somaticF(n,:)',qCut)],'r-')
title([num2str(n) ' : ' num2str(qCut)])
hold off

subplot(2,2,2)
nhist(somaticF(n,:)','box')


n=n+1;