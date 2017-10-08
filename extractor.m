function varargout = extractor(varargin)

% extractor: provides tools for extracting and processing intensity values from ROIs made in roiMaker
%
% Will extract from disk, or a selected matrix in your workspace.
% This will be improved soon to give options to control parallelization,
% image types etc.
%
%
% Version: 0.99
% 10/8/2017
% Code by: Chris Deister
% Questions: cdeister@brown.edu
%
% Known Issues:
% A) For disk extraction: you have to specify the frame range.
% B) All df/f options default to somaticF for now. I am overhauling this. 



%todo: I want to kill dispROIString

% ******** Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @extractor_OpeningFcn, ...
                   'gui_OutputFcn',  @extractor_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% ********* End initialization code - DO NOT EDIT


function diskExtractButton_Callback(hObject, eventdata, handles)

    set(handles.extractFeedbackString,'String','Extracting ...')
    pause(0.00000001);
    guidata(hObject, handles);

    imPath=evalin('base','importPath');
    fileList=evalin('base','filteredFiles');

    firstIm=str2num(get(handles.firstImageEntry,'string'));
    endIm=str2num(get(handles.endImageEntry,'string'));

    skipImagesToggle=get(handles.diskExtractSkipByToggle,'Value');
    skipImagesToggle=get(handles.diskExtractSkipByToggle,'Value');


    skipImagesToggle=get(handles.diskExtractSkipByToggle,'Value');
    if skipImagesToggle
        st=str2num(get(handles.diskExtractSkipByStartEntry,'String'));
        by=str2num(get(handles.diskExtractSkipByEntry,'String'));
        a=st;
        if st>by
            a=rem(st,by);
        else
        end
        en=numel(fileList)-(by-a);
        fileList=fileList(st:by:en);
    else
    end
    disp(['after skiping you will extract from ' num2str(numel(fileList)) ' images'])


    % ************ handle concatination of roi types
    roiStringMap={'somaticROI','dendriticROI','axonalROI','boutonROI',...
    'neuropilROI','vascularROI','redSomaticROI'};
    roiToggleTruth=[get(handles.somaExtractCheck,'Value'),get(handles.dendriteExtractCheck,'Value'),...
        get(handles.axonExtractCheck,'Value'),get(handles.boutonExtractCheck,'Value'),...
        get(handles.neuropilExtractCheck,'Value'),get(handles.vascularExtractCheck,'Value'),...
        get(handles.redSomaticExtractCheck,'Value')];

    rois=[];   % we will map in the selected rois into this
    warnBit=1;
    for n=1:numel(roiToggleTruth)
        if roiToggleTruth(n)==1
            warnBit=0;      % if anything is selected flip the warning to 0.
            roisToMap=evalin('base', roiStringMap{n});
            rois=[rois roisToMap];
        else
        end
    end

    if warnBit==1;
        disp('no rois')
    end
    % ************ end handle concatination of roi types

    % ************  handle image list prep
    numImages=(endIm-firstIm)+1;
    sED=zeros(numel(rois),numImages);
    regFlag=get(handles.diskRegFlag,'Value');

    % ************  end handle image list prep


    % ************  extract without registration 
    if regFlag==0
    disp(['about to extract, this should take ~ ' num2str((numel(rois)*.0004*numImages)./60) ' minutes'])
    cc=clock;
    disp(['started at ' num2str(cc(4)) ':'  num2str(cc(5))])
    tic
    disp('extracting')
    diskLuminance=zeros(1,numImages);
    for n=firstIm:endIm
        impImage=imread([imPath filesep fileList(n).name]);
        diskLuminance(:,(n-firstIm)+1)=mean2(impImage);
        for q=1:numel(rois)
            sED(q,(n-firstIm)+1)=mean(impImage(rois{q}(:,:)));
        end
        if (rem((n-firstIm)+1,100)==0)
            fprintf('%d/%d (%d%%)\n',(n-firstIm)+1,numImages,round(100*((n-firstIm)+1)./numImages));
        end
    end
    eT=toc;
    assignin('base','diskLuminance',diskLuminance);
    disp(['done extracting, this took ' num2str(eT./60) ' minutes'])

    % ************  extract with registration 
    elseif regFlag==1

    disp(['about to extract, this should take ~ ' num2str((numel(rois)*.0008*numImages)./60) ' minutes'])
    cc=clock;
    disp(['started at ' num2str(cc(4)) ':'  num2str(cc(5))])
    tic
    template=evalin('base','regTemplate');
    disp('extracting')
    registeredTransformations=zeros(4,numImages);
    diskLuminance=zeros(1,numImages);

    for n=firstIm:endIm
        impImage=imread([imPath filesep fileList(n).name]);
        [out1,out2]=dftregistration(fft2(template),fft2(impImage),100);
        registeredTransformations(:,(n-firstIm)+1)=out1;
        diskLuminance(:,(n-firstIm)+1)=mean2(impImage);
        regImage=abs(ifft2(out2));
        for q=1:numel(rois)
            sED(q,(n-firstIm)+1)=mean(regImage(rois{q}(:,:)));
        end
        if (rem((n-firstIm)+1,100)==0)
            fprintf('%d/%d (%d%%)\n',(n-firstIm)+1,numImages,round(100*((n-firstIm)+1)./numImages));
        end
    end

    assignin('base','registeredTransformations',registeredTransformations);
    assignin('base','diskLuminance',diskLuminance);

    eT=toc;

    disp(['done extracting, this took ' num2str(eT./60) ' minutes'])

    end

    % ************  now we need to map the extracted values to the original roi types
    for n=1:numel(roiToggleTruth)
        if roiToggleTruth(n)==1
            roisToMapCount=evalin('base', ['numel(' roiStringMap{n} ')']);
            assignin('base',[roiStringMap{n}(1:end-4) 'F'],sED(1:roisToMapCount,:));
            sED(1:roisToMapCount,:)=[];
        else
        end
    end

    set(handles.extractFeedbackString,'String','')
    guidata(hObject, handles);

function extractButton_Callback(hObject, eventdata, handles)

    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    selectStack=selections{selectionsIndex};


    dStackSize=evalin('base',['size(' selectStack ');']);

    if dStackSize(3)>1

    % ************ handle concatination of roi types
    roiStringMap={'somaticROIs','dendriticROIs','axonalROIs','boutonROIs',...
    'neuropilROIs','vesselROIs','redSomaticROIs'};
    roiToggleTruth=[get(handles.somaExtractCheck,'Value'),get(handles.dendriteExtractCheck,'Value'),...
        get(handles.axonExtractCheck,'Value'),get(handles.boutonExtractCheck,'Value'),...
        get(handles.neuropilExtractCheck,'Value'),get(handles.vascularExtractCheck,'Value'),...
        get(handles.redSomaticExtractCheck,'Value')];

    rois=[];   % we will map in the selected rois into this
    warnBit=1;
    for n=1:numel(roiToggleTruth)
        if roiToggleTruth(n)==1
            warnBit=0;      % if anything is selected flip the warning to 0.
            roisToMap=evalin('base', roiStringMap{n});
            rois=[rois roisToMap];
        else
        end
    end

    if warnBit==1;
        disp('no rois')
    end
    % ************ end handle concatination of roi types

    %--- extract

    set(handles.extractButton,'string','running','ForegroundColor','red','enable','off');
    pause(0.00000001);
    guidata(hObject, handles);

    sED=zeros(numel(rois),dStackSize(3));
    tic
    for n=1:dStackSize(3)
        for q=1:numel(rois)
            aIm=double(evalin('base',[selectStack '(:,:,' num2str(n) ')']));
            sED(q,n)=mean(aIm(rois{q}(:,:)));    
        end
    end
    aa=toc;
    % disp(num2str(aa))

    %--- end extract

    % ************  now we need to map the extracted values to the original roi types
    for n=1:numel(roiToggleTruth)
        if roiToggleTruth(n)==1
            roisToMapCount=evalin('base', ['numel(' roiStringMap{n} ')']);
            assignin('base',[roiStringMap{n}(1:end-4) 'F'],sED(1:roisToMapCount,:));
            sED(1:roisToMapCount,:)=[];
        else
        end
    end


    set(handles.extractButton,'string','Extract','ForegroundColor','black','enable','on');

    % Update handles structure

    set(handles.extractFeedbackString,'String','')
    set(handles.extractButton,'string','Extract','ForegroundColor','black','enable','on');

    % Update handles structure
    refreshWSVarsBtn_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
    else
    end

function roiDisplaySlider_Callback(hObject, eventdata, handles)
    % main roi load
    returnBit=0;

    [knwTgs,onTypes]=getKnownROIDisplayToggles(hObject, eventdata, handles);
    
    whoIsOn=zeros(numel(knwTgs),1);
    
    for n=1:numel(knwTgs)
        whoIsOn(n)=eval(['get(handles.' knwTgs{n} 'DisplayToggle, ''Value'');']);
    end

    selectedTypes=onTypes(find(whoIsOn==1));

    plotRelated=get(handles.showCorrelatedToggle,'Value');
    relatedThreshold=str2double(get(handles.corThresholdEntry,'String'));
    if plotRelated==0
        relatedThreshold=0.999999;
    else
    end

    sliderValue = fix(get(handles.roiDisplaySlider,'Value'));
    if sliderValue<1
        sliderValue=1;
    else
    end

    set(handles.displayedROICounter,'String', num2str(sliderValue));
    tnum=str2double(get(handles.displayedROICounter,'String'));

    if numel(selectedTypes)>0
        for k=1:numel(selectedTypes)
            pltDF=get(handles.plotAsDFToggle,'Value');
            if pltDF
                traces=evalin('base',[selectedTypes{k} 'F_DF;']);
            else
                traces=evalin('base',[selectedTypes{k} 'F;']);
            end
            mask=evalin('base',[selectedTypes{k} 'ROIs{' num2str(tnum) '}']);
            maskStr=[selectedTypes{k} 'ROIs'];
            centroidStr=[selectedTypes{k} 'ROICenters'];
        end
    else
        returnBit=1;
    end

    if returnBit==0
    yLow=str2num(get(handles.yLowTrace,'String'));
    xLow=str2num(get(handles.yHighTrace,'String'));

    selTrace=traces(tnum,:);
    nonSelTraces=traces(1:size(traces,1),:);
    selTrace=repmat(selTrace,size(nonSelTraces,1),1);


    axes(handles.corAxis)
    curCorr=corr(selTrace',nonSelTraces');
    [csV,csI]=sort(curCorr','descend');
    csV=csV(:,1);
    csI=csI(:,1);
    plot(curCorr','ko','linewidth',1)
    hold on
    plot([1 size(curCorr,1)],[relatedThreshold relatedThreshold],'r:','linewidth',1)
    hold off
    ylim([-1 1])

    relatedROIs=csI(find(csV>=relatedThreshold));
    relatedCorrelations=csV(find(csV>=relatedThreshold));


    % related pairwise distance (Euclidean)
    for n=1:numel(relatedROIs)
        b=evalin('base',[centroidStr '{' num2str(tnum) '}.Centroid;']);
        a=evalin('base',[centroidStr '{' num2str(relatedROIs(n)) '}.Centroid;']);
        relatedDistances(:,n)=sqrt((b(1)-a(1))^2+((b(2)-a(2))^2));
    end

    % check for menu sort
    sL=get(handles.sortByMenu,'String');
    sV=get(handles.sortByMenu,'Value');

    sortString=sL{sV};
    sortUp=get(handles.sortAscend,'Value');
    if sortUp
        eval(['[tSrtV tSrtI]=sort(related' sortString ',''ascend'');'])
    else
        eval(['[tSrtV tSrtI]=sort(related' sortString ',''descend'');'])
    end

    relatedROIs=relatedROIs(tSrtI);
    relatedCorrelations=relatedCorrelations(tSrtI);
    relatedDistances=relatedDistances(tSrtI);

    relCString=strjoin(arrayfun(@(x) num2str(x),relatedROIs,'UniformOutput',false),',');
    set(handles.relatedCellsReturn,'String',relCString)

    relVString=strjoin(arrayfun(@(x) num2str(x),relatedCorrelations,'UniformOutput',false),',');
    set(handles.relatedValuesReturn,'String',relVString)

    relDString=strjoin(arrayfun(@(x) num2str(x),relatedDistances,'UniformOutput',false),',');
    set(handles.relatedDistReturn,'String',relDString);


    if numel(relatedDistances)>=2
        axes(handles.featureHist)
        nhist(relatedDistances,'box');
        xlim([0 200])
        
        axes(handles.featurePlot)
        plot(relatedROIs,relatedDistances,'ko')
        hold on
        plot([1 size(curCorr,1)],[20 20],'r:','linewidth',1)
        hold off
        ylim([0 200])
    else
    end


    axes(handles.traceDisplay)

    if numel(relatedROIs)>1
        aa=colormap(jet(numel(relatedROIs)*3));
        aa=aa(1:3:end,:);
    else
        col=[0,0,0];
    end

    hold off
    for n=1:numel(relatedROIs)
        if relatedROIs(n)==tnum
            sameCell=n;
            col=[1,1,1];
        else
            col=aa(n,:);
        end
        h(n)=plot(traces(relatedROIs(n),:)','Color',col,'LineWidth',1.1);
        hold all
    end
    hold off
    set(h, 'ButtonDownFcn', {@LineSelected, h})


    assignin('base','curh',h);

    a=gca;
    a.Color=[0,0,0];


    ylim([yLow xLow])


    for n=1:numel(relatedROIs)
        cumuMasks(:,:,n)=evalin('base',[maskStr '{' num2str(relatedROIs(n)) '}'])*relatedCorrelations(n);
    end
    rgb=cat(3,false(size(cumuMasks(:,:,1))),false(size(cumuMasks(:,:,1))),false(size(cumuMasks(:,:,1))));

    if numel(relatedROIs)==1
        aa(1,:)=[1,1,1];
    else
    end
    for n=1:numel(relatedROIs)
        g=aa(n,:);
        if n==sameCell
            g=[1,1,1];
        else
        end
        rgb=rgb+cat(3,cumuMasks(:,:,n)*g(1),cumuMasks(:,:,n)*g(2),cumuMasks(:,:,n)*g(3));
    end
        
       
    clear cumuMasks

    axes(handles.roiMaskAxis)
    mP=imshow(rgb);
    a=gca;
    a.YTick=[];
    a.XTick=[];

    assignin('base','curHMask',mP);

    guidata(hObject, handles);
    else
    end

function displayedROICounter_Callback(hObject, eventdata, handles)
    input = str2num(get(hObject,'String'));

    %checks to see if input is empty. if so, default input1_editText to zero
    if (isempty(input))
         set(hObject,'String','1')
    end

    if input<1
        input=1;
    else
    end

    set(handles.roiDisplaySlider,'Value',input);

    roiDisplaySlider_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);


% *********************************************************************
% *********** These Functions Deal With the roiDisplayToggles *********
% *********************************************************************


function [knownTogglesList,typeList]=getKnownROIDisplayToggles(hObject, eventdata, handles)
    knownTogglesList={'neuropilRois','vascularRois','boutonRois',...
    'axonRois','dendriteRois','somaRois','redSomaticRois'};
    typeList={'neuropil','vessel','bouton',...
    'axonal','dendritic','somatic','redSomatic'};
    % todo: fix names with 'knownTypes', the typeList is a temp hack.

function genericDispalyTypeToggle(hObject, eventdata, handles,typeString,toggleString)
    assignin('base','dispROIString',[typeString 'ROI']);
    knwTgs=getKnownROIDisplayToggles(hObject, eventdata, handles);
    selTg=toggleString;
    nonSelTgs=setdiff(knwTgs,selTg);
    for n=1:numel(nonSelTgs)
        eval(['set(handles.' nonSelTgs{n} 'DisplayToggle, ''Value'', 0);']);
    end
    g=checkForWSVar([typeString 'F']);
    if g
        tCnt=doXInWSOn('size',[typeString 'F']);
        tCnt=tCnt(1);
        if tCnt>1
            tnum=str2double(get(handles.displayedROICounter,'String'));
            sliderMin = 1;
            sliderMax = tCnt(1); % this is variable
            sliderStep = [1, 1] / (sliderMax - sliderMin); % major and minor steps of 1
            set(handles.roiDisplaySlider, 'Min', sliderMin);
            set(handles.roiDisplaySlider, 'Max', sliderMax);
            set(handles.roiDisplaySlider, 'SliderStep', sliderStep);
            if tnum<=sliderMax
                set(handles.roiDisplaySlider, 'Value', tnum); % set to beginning of sequence
                set(handles.displayedROICounter,'String', num2str(tnum));
            else
                set(handles.roiDisplaySlider, 'Value', sliderMin); % set to beginning of sequence
                tnum=1;
                set(handles.displayedROICounter,'String', '1');
            end
            roiDisplaySlider_Callback(hObject, eventdata, handles)
            guidata(hObject, handles);
        elseif tCnt==1
            tnum=1;
            sliderMin = 0;
            sliderMax = 1; % this is variable
            sliderStep = [1 1];
            set(handles.roiDisplaySlider, 'Min', sliderMin);
            set(handles.roiDisplaySlider, 'Max', sliderMax);
            set(handles.roiDisplaySlider, 'SliderStep', sliderStep);
            if tnum<=sliderMax
                set(handles.roiDisplaySlider, 'Value', tnum); % set to beginning of sequence
                set(handles.displayedROICounter,'String', num2str(tnum));
            else
                set(handles.roiDisplaySlider, 'Value', sliderMin); % set to beginning of sequence
                tnum=1;
                set(handles.displayedROICounter,'String', '1');
            end
            roiDisplaySlider_Callback(hObject, eventdata, handles)
            guidata(hObject, handles);
        else
        end
    else
    end
    guidata(hObject, handles);

function somaRoisDisplayToggle_Callback(hObject, eventdata, handles)
    genericDispalyTypeToggle(hObject, eventdata, handles,'somatic','somaRois')
    guidata(hObject, handles);

function dendriteRoisDisplayToggle_Callback(hObject, eventdata, handles)
    genericDispalyTypeToggle(hObject, eventdata, handles,'dendritic','dendriteRois')
    guidata(hObject, handles);

function boutonRoisDisplayToggle_Callback(hObject, eventdata, handles)
    genericDispalyTypeToggle(hObject, eventdata, handles,'bouton','boutonRois')
    guidata(hObject, handles);

function axonRoisDisplayToggle_Callback(hObject, eventdata, handles)
    genericDispalyTypeToggle(hObject, eventdata, handles,'axonal','axonRois')
    guidata(hObject, handles);

function vascularRoisDisplayToggle_Callback(hObject, eventdata, handles)
    genericDispalyTypeToggle(hObject, eventdata, handles,'vessel','vascularRois')
    guidata(hObject, handles);

function redSomaticRoisDisplayToggle_Callback(hObject, eventdata, handles)
    genericDispalyTypeToggle(hObject, eventdata, handles,'redSomatic','redSomaticRois')
    guidata(hObject, handles);

function neuropilRoisDisplayToggle_Callback(hObject, eventdata, handles)

    genericDispalyTypeToggle(hObject, eventdata, handles,'neuropil','neuropilRois')
    guidata(hObject, handles);


% *********************************************************************
% *********** These Functions Deal With XXXXX *************************
% *********************************************************************

function flagROIButton_Callback(hObject, eventdata, handles)

    sROI=str2num(get(handles.displayedROICounter,'String'));
    bE=evalin('base','exist(''dispROIString'');');
    if bE==1
        dispString=evalin('base','dispROIString;');
        tStr=['flagged_' dispString];
        fE=evalin('base',['exist([''' tStr '''])']);
        
        if fE
            curFlagged=evalin('base',['flagged_' dispString]);
            curFlagged=[curFlagged; sROI];
            assignin('base',['flagged_' dispString],curFlagged)
        else
            curFlagged=sROI;
            assignin('base',['flagged_' dispString],curFlagged)
        end
    else
    end

    rN=fix(str2double(get(handles.displayedROICounter,'String')))+1;
    set(handles.roiDisplaySlider,'Value',rN)
    guidata(hObject, handles);
    roiDisplaySlider_Callback(hObject, eventdata, handles)

function refreshWSVarsBtn_Callback(hObject, eventdata, handles)

    vars = evalin('base','who');
    set(handles.workspaceVarBox,'String',vars)

function dataAppendToggle_Callback(hObject, eventdata, handles)

% *********************************************************************
% *********** These Functions Deal With Time Series Ops ***************
% *********************************************************************

function movingAvgBtn_Callback(hObject, eventdata, handles)
    mvWin=fix(str2double(get(handles.smoothWindowEntry,'String')));
    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    selectStack=selections{selectionsIndex};

    aa=evalin('base',selectStack);
    bb=nPointMean(aa',mvWin);
    clear aa
    assignin('base',selectStack,bb');

function smoothWindowEntry_Callback(hObject, eventdata, handles)

% *******************************************************************
% *********** These Functions Deal With Graph Options ***************
% *******************************************************************

function xLowTrace_Callback(hObject, eventdata, handles)

function xHighTrace_Callback(hObject, eventdata, handles)

function yLowTrace_Callback(hObject, eventdata, handles)
    
    roiDisplaySlider_Callback(hObject, eventdata, handles)

function yHighTrace_Callback(hObject, eventdata, handles)
    
    roiDisplaySlider_Callback(hObject, eventdata, handles)


% *******************************************************************
% *********** These Functions Deal With Correlations Etc. ***********
% *******************************************************************

function showCorrelatedToggle_Callback(hObject, eventdata, handles)

    roiDisplaySlider_Callback(hObject, eventdata, handles)

function corThresholdEntry_Callback(hObject, eventdata, handles)
   
    roiDisplaySlider_Callback(hObject, eventdata, handles)

function relatedCellsReturn_Callback(hObject, eventdata, handles)

function groupMarkerBtn_Callback(hObject, eventdata, handles)

    gNum=fix(str2num(get(handles.groupCounter,'String')))+1;
    gIs=str2num(get(handles.relatedCellsReturn,'String'));
    gVs=str2num(get(handles.relatedValuesReturn,'String'));
    gDs=str2num(get(handles.relatedDistReturn,'String'));

    if numel(gIs)>1
        assignin('base','tIs',gIs);
        assignin('base','tVs',gVs);
        assignin('base','tDs',gDs);
        evalin('base',['tgROIs{' num2str(gNum) ',1}=tIs;,clear tIs']);
        evalin('base',['tgScores{' num2str(gNum) ',1}=tVs;,clear tVs']);
        evalin('base',['tgDists{' num2str(gNum) ',1}=tDs;,clear tDs']);
        set(handles.groupCounter,'String',num2str(gNum))
        refreshWSVarsBtn_Callback(hObject, eventdata, handles)
        guidata(hObject, handles);
    else
    end


    rN=fix(str2double(get(handles.displayedROICounter,'String')))+1;
    set(handles.roiDisplaySlider,'Value',rN)
    guidata(hObject, handles);
    roiDisplaySlider_Callback(hObject, eventdata, handles)

function groupCounter_Callback(hObject, eventdata, handles)

function relatedValuesReturn_Callback(hObject, eventdata, handles)

function rcBtn_soma_Callback(hObject, eventdata, handles)

    curROIType=evalin('base','dispROIString');

    if strcmp(curROIType,'somaticROI')
        disp('It is already a soma.')
    else
        curNum=fix(str2double(get(handles.displayedROICounter,'String')));
        g=evalin('base','exist(''somaticRoiCounter'')');
        
    end

    refreshWSVarsBtn_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);

function rcBtn_dend_Callback(hObject, eventdata, handles)
    refreshWSVarsBtn_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);

function rcBtn_axon_Callback(hObject, eventdata, handles)
    
    refreshWSVarsBtn_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);

function deleteFlagged_Callback(hObject, eventdata, handles)
    %
    % curROIType=evalin('base','dispROIString'); 
    % evalin('base',[curROIType ]);


    refreshWSVarsBtn_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
    somaRoisDisplayToggle_Callback(hObject, eventdata, handles)

function relatedDistReturn_Callback(hObject, eventdata, handles)

function keepFirstBtn_Callback(hObject, eventdata, handles)

    related=str2num(get(handles.relatedCellsReturn,'String'));
    kill=related(2:end);
    killNum=numel(kill);
    if killNum>=1
    tKS=strjoin(arrayfun(@(x) num2str(x),kill,'UniformOutput',false),',');
    killString=['[' tKS ']'];


    evalin('base',['somaticF(' killString ',:)=[];']);
    evalin('base','somaticRoiCounter=size(somaticF,1);');
    evalin('base',['somaticROI_PixelLists(' killString ')=[];']);
    evalin('base',['somaticROIBoundaries(' killString ')=[];']);
    evalin('base',['somaticROICenters(' killString ')=[];']);
    evalin('base',['somaticROIs(' killString ')=[];']);

    refreshWSVarsBtn_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
    % somaRoisDisplayToggle_Callback(hObject, eventdata, handles)
    advance=0;
    else
        advance=1;
    end
    rN=fix(str2double(get(handles.displayedROICounter,'String')))+advance;
    set(handles.roiDisplaySlider,'Value',rN)
    guidata(hObject, handles);
    roiDisplaySlider_Callback(hObject, eventdata, handles)
    somaRoisDisplayToggle_Callback(hObject, eventdata, handles)

function killSelectedBtn_Callback(hObject, eventdata, handles)
    tnum=str2double(get(handles.displayedROICounter,'String'));
    killString=num2str(tnum);

    evalin('base',['somaticF(' killString ',:)=[];']);
    evalin('base','somaticRoiCounter=size(somaticF,1);');
    evalin('base',['somaticROI_PixelLists(' killString ')=[];']);
    evalin('base',['somaticROIBoundaries(' killString ')=[];']);
    evalin('base',['somaticROICenters(' killString ')=[];']);
    evalin('base',['somaticROIs(' killString ')=[];']);

    refreshWSVarsBtn_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
    advance=1;

    rN=fix(str2double(get(handles.displayedROICounter,'String')))+advance;
    set(handles.roiDisplaySlider,'Value',rN)
    guidata(hObject, handles);
    roiDisplaySlider_Callback(hObject, eventdata, handles)
    somaRoisDisplayToggle_Callback(hObject, eventdata, handles)

function saveTracesPDFBtn_Callback(hObject, eventdata, handles)

    tnum=str2double(get(handles.displayedROICounter,'String'));
    hh=evalin('base','curh');
    mi=evalin('base','curHMask');
    miX=mi.XData;
    miY=mi.YData;
    mi.XData=miY;
    mi.YData=miX;



    tFig=figure('visible','off');
    subplot(6,2,[5 6 7 8 9 10 11 12])
    ta=gca;
    hh(1,end).Color=[0,0,0];
    copyobj(hh,ta);
    ta.Box='off';
    ta.TickDir='out';

    subplot(6,2,[2 4])
    tb=gca;
    copyobj(mi,tb);

    tb.YTick=[];
    tb.XTick=[];
    tb.Clipping='off';
    tb.Visible='off';
    tb.YDir='reverse';

    % tFig.PaperPositionMode='manual';
    orient(tFig,'portrait');
    print(tFig,['reladteROIs_' num2str(tnum) '.pdf'],'-dpdf','-painters','-r300');
    clear tFig
    mi.XData=miX;
    mi.YData=miY;
    hh(1,end).Color=[1,1,1];

function sortByMenu_Callback(hObject, eventdata, handles)
    
    roiDisplaySlider_Callback(hObject, eventdata, handles)

function sortAscend_Callback(hObject, eventdata, handles)
    
    roiDisplaySlider_Callback(hObject, eventdata, handles)

function [numSel]=LineSelected(hObject, eventdata, handels)
    set(hObject, 'LineWidth', 2);
    set(handels(handels ~= hObject), 'LineWidth', 0.8);
    sI=(handels==hObject);
    numSel=find(sI==1);
    disp(['trace #' num2str(numSel) ' selected'])

function killGroupBtn_Callback(hObject, eventdata, handles)

function killFirstBtn_Callback(hObject, eventdata, handles)
    related=str2num(get(handles.relatedCellsReturn,'String'));

    deleteROI(related(1),typeList,scopeString)

    tKS=num2str(related(1));
    killString=['[' tKS ']'];


    evalin('base',['somaticF(' killString ',:)=[];']);
    evalin('base','somaticRoiCounter=size(somaticF,1);');
    evalin('base',['somaticROI_PixelLists(' killString ')=[];']);
    evalin('base',['somaticROIBoundaries(' killString ')=[];']);
    evalin('base',['somaticROICenters(' killString ')=[];']);
    evalin('base',['somaticROIs(' killString ')=[];']);

    refreshWSVarsBtn_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
    % somaRoisDisplayToggle_Callback(hObject, eventdata, handles)
    advance=0;

    rN=fix(str2double(get(handles.displayedROICounter,'String')))+advance;
    set(handles.roiDisplaySlider,'Value',rN)
    guidata(hObject, handles);
    roiDisplaySlider_Callback(hObject, eventdata, handles)
    somaRoisDisplayToggle_Callback(hObject, eventdata, handles)

% &
% &&
% &&&
% &&&&&&
% &&&&&&&&&&
% &&&&&&&&&&&&&&&
% &&&&&&&&&&&&&&&&&&&& The Good Stuff Is Over :(
% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& The Rest Is Distracting Junk
% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& Thanks For Watching 



% ****************************************************************************

% ********************************
% ****** basic program nav *******
% ********************************

function importerBtn_Callback(hObject, eventdata, handles)
    
    evalin('base','importer')
function roiMakerBtn_Callback(hObject, eventdata, handles)
    
    evalin('base','roiMaker')


% ---------------------------------------------
% ------------------------- junk yard ---------
% ---------------------------------------------

function relatedCellsReturn_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function smoothWindowEntry_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function relatedDistReturn_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function somaExtractCheck_Callback(hObject, eventdata, handles)
function dendriteExtractCheck_Callback(hObject, eventdata, handles)
function axonExtractCheck_Callback(hObject, eventdata, handles)
function boutonExtractCheck_Callback(hObject, eventdata, handles)
function redSomaticExtractCheck_Callback(hObject, eventdata, handles)
function neuropilExtractCheck_Callback(hObject, eventdata, handles)
function vascularExtractCheck_Callback(hObject, eventdata, handles)
function displayedROICounter_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function roiDisplaySlider_CreateFcn(hObject, eventdata, handles)

    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
function firstImageEntry_Callback(hObject, eventdata, handles)
function firstImageEntry_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function endImageEntry_Callback(hObject, eventdata, handles)
function endImageEntry_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function batchSmoothBtn_Callback(hObject, eventdata, handles)
function pixelCountReturn_Callback(hObject, eventdata, handles)
function pixelCountReturn_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function sortByMenu_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function diskRegFlag_Callback(hObject, eventdata, handles)
function diskExtractSkipByEntry_Callback(hObject, eventdata, handles)
function diskExtractSkipByEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function diskExtractSkipByToggle_Callback(hObject, eventdata, handles)
function diskExtractSkipByStartEntry_Callback(hObject, eventdata, handles)
function diskExtractSkipByStartEntry_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function workspaceVarBox_Callback(hObject, eventdata, handles)
function workspaceVarBox_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function corThresholdEntry_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function relatedValuesReturn_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function groupCounter_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function yLowTrace_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function yHighTrace_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function xLowTrace_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function xHighTrace_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% ****************** Standard MATLAB GUI Opening Functions
function extractor_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to extractor (see VARARGIN)

    % Choose default command line output for extractor
    handles.output = hObject;

    vars = evalin('base','who');
    set(handles.workspaceVarBox,'String',vars)

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes extractor wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = extractor_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;    


function plotAsDFToggle_Callback(hObject, eventdata, handles)


function plotSelectedROI_Callback(hObject, eventdata, handles)


function roiBrowserBox_Callback(hObject, eventdata, handles)


function roiBrowserBox_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function holdCurrentROILinesToggle_Callback(hObject, eventdata, handles)


function saveWSBtn_Callback(hObject, eventdata, handles)


function slidingBaselineBtn_Callback(hObject, eventdata, handles)
    
    frmWinSize=get(handles.movBaselineWinEntry,'String');
    if checkForWSVar('dispROIString')
        selectedROIString=evalin('base','dispROIString');
        tT=strsplit(selectedROIString,'R');
        selectedType=tT{1};
        if checkForWSVar([selectedType 'F_BLCutOffs'])==0
            evalin('base',[selectedType 'F_BLCutOffs=computeQunatileCutoffs(' selectedType  'F);']);
        else
        end
        evalin('base',['for n=1:size(' selectedType 'F,1),' selectedType 'BL(n,:)=slidingBaseline(' selectedType 'F(n,:),' frmWinSize ',' selectedType 'F_BLCutOffs(n));,end'])
        evalin('base',[selectedType 'F_nonBL=' selectedType 'F;'])
        evalin('base',[selectedType 'F=' selectedType 'F-'  selectedType 'BL;'])
        evalin('base',[selectedType 'F_DF=' selectedType 'F./'  selectedType 'BL;'])
    else
    end

    refreshWSVarsBtn_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);


function movBaselineWinEntry_Callback(hObject, eventdata, handles)


function movBaselineWinEntry_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function makeDFFBtn_Callback(hObject, eventdata, handles)


function quantDFEntry_Callback(hObject, eventdata, handles)


function quantDFEntry_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function useQuantForDFToggle_Callback(hObject, eventdata, handles)
