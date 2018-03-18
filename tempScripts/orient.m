%%
tmpSS=bData.stimSamps/1000;
imDelta=0.033858981*1;
sS_asClosestFrame=ceil(tmpSS./imDelta);
%%
trialRange=2:185;
tOrients=bData.curOrientations(trialRange);
%%
close all
orientSweep=[0 450 900 1800 2250 2700 3150];
preF=100;
postF=300;
for j=1:size(somaticF,1)
    cellNum=j;
    for k=1:numel(orientSweep)
        cOrient=orientSweep(k);
        tFocus=find(tOrients==cOrient);
        for n=1:tFocus
            trimDF(:,n)=somaticF_DF(cellNum,sS_asClosestFrame(tFocus(n))-preF:sS_asClosestFrame(tFocus(n))+postF);
        end

        tSm=smooth(mean(trimDF,2),50);
        blSm=tSm-min(tSm(1:100));
        poolOrientResp(k,j)=max(blSm(40:200));

% figure(111)
% subplot(2,2,1:2)
% hold all
% plot(blSm)
% ylim([-1 3])
% end
% 
% 
% subplot(2,2,3)
% plot(orientSweep/10,poolOrientResp)
% ylim([-1 3])
% subplot(2,2,4)
% polarplot(deg2rad(orientSweep/10),poolOrientResp)
% rlim([0 3])

end
end
