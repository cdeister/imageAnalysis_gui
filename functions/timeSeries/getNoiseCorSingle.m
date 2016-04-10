function [nC,pairMap]=getNoiseCorSingle(testCellsData1,testCellsData2)

testCellsData(:,:,1)=testCellsData1;
testCellsData(:,:,2)=testCellsData2;


rsDf=reshape(testCellsData,(size(testCellsData,1)*size(testCellsData,2)),size(testCellsData,3));


totalPairs=nchoosek(size(testCellsData,3),2);
totalCells=size(testCellsData,3);

%pre allocate
nC=zeros(1,totalPairs);
pairMap=zeros(2,totalPairs);

v=1;
for k=1:totalCells,
        tic
        for n=k+1:totalCells
            %********************************** hit trials
            % standard correlation
            nC(:,v)=corr(rsDf(:,k),rsDf(:,n));
            pairMap(:,v)=[k n];
            v=v+1;
        end
end

end