function [bsDist,pValEst,cis,H]=bsTest(d1,d2,bReps,alphaLevel,plot,metric)

% [bsDist,pValEst,cis,H]=bsTest(d1,d2,bReps,alphaLevel,plot,metric) 0 =
% median

% two metrics (t-test; rank test eq)
dataToBSt=d1;
dataToBSt2=d2;
if metric==1
%tic
clear a
clear bsDist
parfor n=1:bReps
    a=shuffleTrialsSimp(1:numel(dataToBSt));
    b=shuffleTrialsSimp(1:numel(dataToBSt2));
    bsDist(:,n)=mean(dataToBSt(a))-mean(dataToBSt2(b));
end
%toc
%disp('#$#$#$#$ your are strapped #$#$#$#$')
elseif metric==0
tic
clear a
clear bsDist
parfor n=1:bReps
    a=shuffleTrialsSimp(1:numel(dataToBSt)); %
    b=shuffleTrialsSimp(1:numel(dataToBSt2));
    bsDist(:,n)=median(dataToBSt(a))-median(dataToBSt2(b));
end
%toc
%disp('#$#$#$#$ your are strapped #$#$#$#$')    
end




cis=prctile(bsDist,[100*alphaLevel/2,100*(1-alphaLevel/2)]);

if plot
figure,nhist(bsDist,'box')
% hold all,plot([cis(1) cis(1)],[0 100],'k:')
% hold all,plot([cis(2) cis(2)],[0 100],'k:')
else
end

H = cis(1)>0 | cis(2)<0;


%estimate p-value

fCI=cis(2)-cis(1);
SE=fCI/(2*1.96);
zS=abs(mean(bsDist))/SE;
pValEst=exp((-0.717*zS)-(0.416*(zS^2)));

% disp('*** stats ***')
% mean(bsDist)
% std(bsDist)
% cis(2)-cis(1)
% 
% pValEst
% disp('*** end stats ***')

end