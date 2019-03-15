    %% correlation coefficent
dataToBSt=dc_pool;
dataToBSt2=cellfun(@mean,allCell);
bReps=1000;
tic
clear a
clear bsDist
parfor n=1:bReps
    a=shuffleTrialsSimp(1:numel(dataToBSt));
        b=shuffleTrialsSimp(1:numel(dataToBSt2));

    bsDist(:,n)=corr(dataToBSt(a)',dataToBSt2(a)');
    bsDist_shuf(:,n)=corr(dataToBSt(a)',dataToBSt2(b)');

end
toc
%% single
mainMan=[1 2 3 4 8];
for n=1:5
dataToBSt=corrCollection.uf.rs(:,mainMan(n));
dataToBSt=dataToBSt(find(isnan(dataToBSt)==0));
tic
clear a
clear bsDist
parfor n=1:10000 
    a=shuffleTrialsSimp(1:numel(dataToBSt));
    bsDist(:,n)=mean(dataToBSt(a));
end
bsDists_uf(:,n)=bsDist;
toc
end
clear mainMan
%% single
    dataToBSt=stimDPThreshold_bl;

tic
clear a
clear bsDist
parfor n=1:10000
    
    a=shuffleTrialsSimp(1:numel(dataToBSt));
    bsDist_4(:,n)=dataToBSt(a(1:4));
end
toc

%%
% single
mainMan=[1 2 3 4 8];
for n=1:5
dataToBSt=corrCollection.uf.rs(:,mainMan(n));
dataToBSt=dataToBSt(find(isnan(dataToBSt)==0));
    bReps=10000;
    tic
    clear a
    clear bsDist
    parfor n=1:bReps
        a=shuffleTrialsSimp(1:numel(dataToBSt));
        bsDist(:,n)=mean(dataToBSt(a));
    end
    toc
    bsDist_uf(:,n)=bsDist;
end

%bsDistb=mean(bsDistb,numel(bsDistb),1);

%% two metrics (t-test; rank test eq)
dataToBSt=grpA;
dataToBSt2=grpB;

bReps=1000;
tic
clear a
clear bsDist
for n=1:bReps
    a=shuffleTrialsSimp(1:numel(dataToBSt));
    b=shuffleTrialsSimp(1:numel(dataToBSt2));
    bsDist(:,n)=nanmedian(dataToBSt(a))-nanmedian(dataToBSt2(b));
end
toc
disp('#$#$#$#$ your are strapped #$#$#$#$')

%%

twoTail=0;
alphaLevel=0.05;

if twoTail
    cis=prctile(bsDist,[100*alphaLevel/2,100*(1-alphaLevel/2)])
else
    cis=prctile(bsDist,[100*alphaLevel,100*(1-alphaLevel)])
end

% figure,nhist(bsDist,'box')
% hold all,plot([cis(1) cis(1)],[0 100],'k:')
% hold all,plot([cis(2) cis(2)],[0 100],'k:')

H = cis(1)>0 | cis(2)<0


%estimate p-value

fCI=cis(2)-cis(1);
SE=fCI/(2*1.96);
zS=abs(mean(bsDist))/SE;
pValEst=exp((-0.717*zS)-(0.416*(zS^2)));

disp('*** stats ***')
mean(bsDist)
std(bsDist)
cis(2)-cis(1);

pValEst
disp('*** end stats ***')