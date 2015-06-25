function [discNeurons,discFrac,auc,hp,rp]=cadROCf(data,hitTrials,rejectTrials,window,thresh,toPlot,critDelta)

% cadROCf performs an ROC analysis (Green and Swets 1966).
%
% #### Arguments
% data is assumed to be a (measurment by trial by cell) matrix.
% hitTrials are the trials you want to detect.
% rejectTrials are the trials to compare to.
% window is a two-element vector specifing the sample range you want.
% baselineSamps is the number of preceeding samples to baseline away.
% thresh is a threshold for computing a detection/discrim fraction.
% toPlot is a boolean that will plot ROC curves for all cells and ranked detection index.
%
% #### Outputs
% discNeurons are the neurons that do better than a threshold.
% discFrac is the fraction of cells that can detect at your thresh.
% auc is the area under the ROC curves for all the cells.
% hp is the hit probablity as a function of the criteria interval.
% rp is the rejection probability as a function of the criteria interval.
%
% #### Notes
% The criteria is handcoded to be -10 and 10 I should add this as an
% argument, there are just so many I wanted to avoid another one.

dvH=zeros(numel(hitTrials),size(data,3));
for q=1:size(data,3)
    for n=1:numel(hitTrials)
        a=mean(data(window(1):window(2),setdiff(hitTrials,hitTrials(n)),q),2);   
        b=mean(data(window(1):window(2),rejectTrials,q),2);
        t=data(window(1):window(2),hitTrials(n),q);
        dvH(n,q)=dot(t,(a-b));
    end
end

dvR=zeros(numel(rejectTrials),size(data,3));
for q=1:size(data,3)
    for n=1:numel(rejectTrials)
        a=mean(data(window(1):window(2),hitTrials,q),2);   
        b=mean(data(window(1):window(2),setdiff(rejectTrials,rejectTrials(n)),q),2);
        t=data(window(1):window(2),rejectTrials(n),q);
        dvR(n,q)=dot(t,(a-b));
    end
end


crit=-100:critDelta:100;

hp=zeros(numel(crit),size(data,3));
rp=zeros(numel(crit),size(data,3));
auc=zeros(1,size(data,3));

for q=1:size(data,3)
    for n=1:numel(crit)
        hp(n,q)=numel(find(dvH(:,q)>crit(n)))/numel(dvH(:,q));
        rp(n,q)=numel(find(dvR(:,q)>crit(n)))/numel(dvR(:,q));
    end
    auc(:,q)=-1*trapz(rp(:,q),hp(:,q));
end

bb=find(sort(auc,'descend')>thresh);
if numel(bb)>0
    discFrac=bb(end)./size(data,3);
    discNeurons=find(auc>thresh);
else
    discFrac=0;
    discNeurons=[];
end

if toPlot
    figure,plot([0 1],[0 1])
    hold all
    for n=1:size(data,3)
        plot(rp(:,n),hp(:,n))
    end
    title('ROC for all cells')
    
    figure,hold all,plot(sort(auc,'descend'),'o')
    hold all,plot([1 size(data,3)],[thresh thresh])
    ylim([0 1]),title('ranked neurons by fraction of correct trials')
    
end
    
