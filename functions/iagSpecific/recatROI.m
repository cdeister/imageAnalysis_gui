function recatROI(targROI,targTypeString,scopeString)

% deleteROI: deletes all elements associated with program created ROIs
%
% Arguments:
% 1) 'numberList' is a vector of roiID numbers e.g. (101,99)
% 2) 'typeList' is a cell array of roiType strings e.g. {'somatic','dendritic'}
% 3) 'scopeString' is an optional string to redirect scope (where the ROIs are)
% The default 'scope' is 'base'. You will likely never change it.
% 
% Returns:
% Nothing
%
% cdeister@brown.edu; 10/8/2017


a=evalin('base','who');

if nargin==2
	scopeString='base';
else
end


% check to see if they have rois of the right type and delete the core
% first.
uniqueTypes=unique(typeList);


for n=1:numel(uniqueTypes)
    h=evalin(scopeString,['exist(' '''' uniqueTypes{n} 'ROIs'')']);
    if h==1
        roiCount=evalin(scopeString,['numel(' uniqueTypes{n} 'ROIs)']);
        if roiCount~=0
            roisToDelete=numberList(strcmp(typeList,uniqueTypes{n}));
            jj=a(strmatch(uniqueTypes{n},a));
            cS1=[uniqueTypes{n} 'ROI'];
            cS2=[uniqueTypes{n} 'Roi'];
        
            coreStrings=vertcat(jj(strmatch(cS1,jj)),jj(strmatch(cS2,jj)));
            
            numelTypeVars=numel(jj);
            coreVarDiff=numelTypeVars-5;
            nonCoreStrings=setdiff(jj,coreStrings);
            
            for j=1:numel(nonCoreStrings)
                dim=evalin(scopeString,['find(size(' nonCoreStrings{j} ')==' num2str(roiCount) ');']);
                if dim ==1
                    evalin(scopeString,[nonCoreStrings{j} '([' num2str(roisToDelete) '],:)=[];']);
                elseif dim ==2
                    evalin(scopeString,[nonCoreStrings{j} '(:,[' num2str(roisToDelete) '])=[];']);
                else
                end    
            end

            evalin(scopeString,[uniqueTypes{n} 'ROI_PixelLists([' num2str(roisToDelete) '])=[];'])
            evalin(scopeString,[uniqueTypes{n} 'ROIBoundaries([' num2str(roisToDelete) '])=[];'])
            evalin(scopeString,[uniqueTypes{n} 'ROICenters([' num2str(roisToDelete) '])=[];'])
            evalin(scopeString,[uniqueTypes{n} 'ROIs([' num2str(roisToDelete) '])=[];'])
            evalin(scopeString,[uniqueTypes{n} 'RoiCounter=numel(' uniqueTypes{n} 'ROIs);'])
        else
            disp('no rois to delete')
        end
    else
    end
end


end