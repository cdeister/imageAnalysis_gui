function deleteROI(numberList,typeList,scopeString)

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


if nargin==2
	scopeString='base';
else
end


% first, I check to see if there is extracted F data for the types of ROIs the user wants to delete.
% that data is extracted after ROI creation, so they don't always go together. 

uniqueTypes=unique(typeList);
for n=1:numel(uniqueTypes)
	g=evalin(scopeString,['exist(' '''' uniqueTypes{n} 'F'')']);
    gd=evalin(scopeString,['exist(' '''' uniqueTypes{n} 'F_DF'')']);
    gBL=evalin(scopeString,['exist(' '''' uniqueTypes{n} 'F_nonBL'')']);
    h=evalin(scopeString,['exist(' '''' uniqueTypes{n} 'ROIs'')']);
    BLCT=evalin(scopeString,['exist(' '''' uniqueTypes{n} 'F_BLCutOffs'')']);
    BLT=evalin(scopeString,['exist(' '''' uniqueTypes{n} 'BL'')']);

    somaticF_BLCutOffs
	
    roisToDelete=numberList(strcmp(typeList,uniqueTypes{n}));
    if g==1
        evalin(scopeString,[uniqueTypes{n} 'F([' num2str(roisToDelete) '],:)=[];'])
    else
    end

    if gd==1
        evalin(scopeString,[uniqueTypes{n} 'F_DF([' num2str(roisToDelete) '],:)=[];'])
    else
    end

    if gBL==1
        evalin(scopeString,[uniqueTypes{n} 'F_nonBL([' num2str(roisToDelete) '],:)=[];'])
    else
    end

    if BLCT==1
        evalin(scopeString,[uniqueTypes{n} 'F_BLCutOffs([' num2str(roisToDelete) '],:)=[];'])
    else
    end

    if BLT==1
        evalin(scopeString,[uniqueTypes{n} 'BL([' num2str(roisToDelete) '],:)=[];'])
    else
    end

    
    
    if h==1
        roiCount=evalin(scopeString,['numel(' uniqueTypes{n} 'ROIs)']);
        if roiCount~=0
            evalin(scopeString,[uniqueTypes{n} 'ROI_PixelLists(:,[' num2str(roisToDelete) '])=[];'])
            evalin(scopeString,[uniqueTypes{n} 'ROIBoundaries(:,[' num2str(roisToDelete) '])=[];'])
            evalin(scopeString,[uniqueTypes{n} 'ROICenters(:,[' num2str(roisToDelete) '])=[];'])
            evalin(scopeString,[uniqueTypes{n} 'ROIs(:,[' num2str(roisToDelete) '])=[];'])
            evalin(scopeString,[uniqueTypes{n} 'RoiCounter=numel(' uniqueTypes{n} 'ROIs);'])
        else
            disp('no rois to delete')
        end
    else
    end
end



end