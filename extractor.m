function varargout = extractor(varargin)

% extractor: provides tools for extracting and processing intensity 
% values from ROIs made in roiMaker
%
% Will extract from disk, or a selected matrix in your workspace.
% This will be improved soon to  give options to control parallelization,
% image types etc.
%
%
% Version: 0.99
% 10/8/2017
% Code by: Chris Deister
% Questions: cdeister@brown.edu
%


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
    imPath=evalin('base','metaData.importPath');
    importType=evalin('base','metaData.importType;');
    
    % get images
    firstIm=str2num(get(handles.firstImageEntry,'string'));
    endIm=str2num(get(handles.endImageEntry,'string'));
    skipImagesToggle=get(handles.diskExtractSkipByToggle,'Value');
    binImagesToggle=get(handles.binByToggle,'Value');
    if binImagesToggle 
        binFac=str2num(get(handles.binByEntry,'String'));
    else
        binFac=1;
    end
    
    if skipImagesToggle==1
        skipF=str2num(get(handles.diskExtractSkipByEntry,'String'));
    else
        skipF=1;
    end
    imRange=firstIm:skipF:endIm;
    imCount=numel(imRange);
    
 
  
    % we set it up differently depending on if folder, mptiff or hdf.
    if importType==0 %folder of files
        fileList=evalin('base','metaData.filteredFiles');
        imageSize=evalin('base','metaData.imSize;');
    elseif importType==2 % hdf
        hdfSize=evalin('base','metaData.hdfSize');
        imageSize=[hdfSize(1),hdfSize(2)];
        tP=evalin('base','metaData.importPath');
        tH=evalin('base','metaData.hdfFile');
        tDS_select=evalin('base','metaData.tDS_select');
    else
    end

    disp(['after skiping you will extract from ' num2str(imCount) ' images'])

    % ************ handle concatination of roi types
    roiStringMap={'somaticROIs','dendriticROIs','axonalROIs','boutonROIs','neuropilROIs','vesselROIs','redSomaticROIs'};
    roiToggleTruth=[get(handles.somaExtractCheck,'Value'),get(handles.dendriteExtractCheck,'Value'),...
        get(handles.axonExtractCheck,'Value'),get(handles.boutonExtractCheck,'Value'),...
        get(handles.neuropilExtractCheck,'Value'),get(handles.vascularExtractCheck,'Value'),...
        get(handles.redSomaticExtractCheck,'Value')];
    
    warnBit=1;
    rois=[];
    
    disp(numel(roiToggleTruth))
    for n=1:numel(roiToggleTruth)
        if roiToggleTruth(n)==1
            warnBit=0;      % if anything is selected flip the warning to 0.
            roisToMap=evalin('base', roiStringMap{n});
            rois=[rois roisToMap];
        else
        end
    end
    roiStack=zeros(fix(imageSize(1)/binFac),fix(imageSize(2)/binFac),numel(rois));
    

    for n=1:numel(rois)
        roiStack(:,:,n)=rois{1,n};
    end
    assignin('base','roiStack',roiStack);
    
    if warnBit==1
        disp('no rois')
    end
    % ************ end handle concatination of roi types


    tempF=zeros(numel(rois),imCount);
    regFlag=get(handles.diskRegFlag,'Value');
    disp(['about to extract, this should take ~ ' ...
    	num2str((numel(rois)*.0004*imCount)./60) ' minutes'])
    cc=clock;
    disp(['started at ' num2str(cc(4)) ':'  num2str(cc(5))])
    tic
    disp('extracting')
    
    if importType==2
        tP=evalin('base','metaData.importPath');
        tH=evalin('base','metaData.hdfFile');
        tDS_select=evalin('base','metaData.tDS_select');
    else
    end

    if regFlag==1
        template=double(evalin('base','regTemplate'));
        regTransforms=zeros(4,imCount);
        fTemplate=fft2(template);
    else
    end
    
    for n=1:numel(imRange)
        tic
        % import the image
        if importType==2
            impImage=h5read([tP tH],['/' tDS_select],[1 1 n],[hdfSize(1) hdfSize(2) 1]);
        else 
            impImage=imread([imPath filesep fileList(n).name]);
        end
        
        if binImagesToggle
            impImage=binImages(impImage,binFac);
        % assignin('base','dImpImage',impImage);
        % debug
        else
        end
        
        
        % register it (if we want).
        if regFlag==1
            [out1,out2]=dftregistration(fTemplate,fft2(impImage),1);
            regTransforms(:,n)=out1;
            impImage=abs(ifft2(out2));
        else
        end

        
        %***** vectorized a tad slower
        ff=double(impImage).*roiStack;
        ffMu=squeeze(sum(sum(ff))./sum(sum(ff ~= 0)));
        tempF(:,n)=ffMu;
        %****
        
        %for q=1:size(roiStack,3)
        %   tempF(q,n)=mean(impImage(roiStack(:,:,q)==1));
        %end
        
        
        if mod(n,100)==0
            set(handles.diskExtractButton,'String',[num2str(n) '/' num2str(numel(imRange))])
            pause(0.00000000000000001)
            guidata(hObject, handles);
        else
        end 

        dTm(n)=toc;
    end


    eT=toc;    
    disp(['done extracting, this took ' num2str(eT./60) ' minutes'])

    for n=1:numel(roiToggleTruth)
        if roiToggleTruth(n)==1
            roisToMapCount=evalin('base', ['numel(' roiStringMap{n} ')']);
            assignin('base',[roiStringMap{n}(1:end-4) 'F'],tempF(1:roisToMapCount,:));
            tempF(1:roisToMapCount,:)=[];
        else
        end
    end
    assignin('base','dTm',dTm);
    
    set(handles.diskExtractButton,'String','Disk Extract')
    set(handles.extractFeedbackString,'String','')
    guidata(hObject, handles);
function extractButton_Callback(hObject, eventdata, handles)

    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    selectStack=selections{selectionsIndex};


    dStackSize=evalin('base',['size(' selectStack ');']);

    if dStackSize(3)>1

    % ************ handle concatination of roi types
    roiStringMap={'somaticROIs','dendriticROIs','axonalROIs','boutonROIs','neuropilROIs','vesselROIs','redSomaticROIs'};
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

    if warnBit==1
        disp('no rois')
    end
    % ************ end handle concatination of roi types

    %--- extract
    set(handles.extractButton,'string','running','ForegroundColor','red','enable','off');
    pause(0.00000001);
    guidata(hObject, handles);

    sED=zeros(numel(rois),dStackSize(3));
    medianFlag=get(handles.medianExtractToggle,'Value');

    

    tic

    for n=1:dStackSize(3)
        for q=1:numel(rois)
            aIm=double(evalin('base',[selectStack '(:,:,' num2str(n) ')']));
            if medianFlag==0
            	sED(q,n)=mean(aIm(rois{q}(:,:)==1));
        	elseif medianFlag==1
            	sED(q,n)=median(aIm(rois{q}(:,:)==1)); 
            end
        end
        if mod(n,500)==0
            set(handles.extractButton,'String',[num2str(n) '/' num2str(dStackSize(3))])
            pause(0.00000000000000001)
            guidata(hObject, handles);
        else
        end 
    end
    
    aa=toc;
    set(handles.extractButton,'String','Extract')
    
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
    % make sure the slider is caught up
    sliderValue = fix(get(handles.roiDisplaySlider,'Value'));
    if sliderValue<1
        sliderValue=1;
    else
    end
    
    % make sure the slider text entry is caught up
    set(handles.displayedROICounter,'String', num2str(sliderValue));
    set(handles.roiSelector,'Value',sliderValue);
    guidata(hObject, handles);
    plotROI(hObject, eventdata, handles)
function plotROI(hObject, eventdata, handles)
    
    % main roi load
    [allTypes,allColors,allWidths]=returnAllTypes(hObject,eventdata,handles);
    mainROIBoxID=get(handles.roiSelector,'Value');
    allROIStrings=get(handles.roiSelector,'String');
    totalROIs=numel(allROIStrings);
    mainROIString=allROIStrings{mainROIBoxID};
    mainROIStringSplit=strsplit(mainROIString,'_');
    mainType=mainROIStringSplit{1};
    mainTypeID=fix(str2double(mainROIStringSplit{2}));
    
    % plot main trace
    pltDF=get(handles.plotAsDFToggle,'Value');
    if pltDF
        mainTrace=evalin('base',[mainType 'F_DF(' num2str(mainTypeID) ',:);']);
    else
        mainTrace=evalin('base',[mainType 'F(' num2str(mainTypeID) ',:);']);
    end
    
    try
        timeVec=evalin('base','imTime');
    catch
        timeVec=1:numel(mainTrace);
    end
    
    yLow=str2num(get(handles.yLowTrace,'String'));
    yHigh=str2num(get(handles.yHighTrace,'String'));
    
    axes(handles.traceDisplay)
    
    holdLast=get(handles.holdCurrentROILinesToggle,'Value');
    if holdLast
        lstAx=gca;
        lastLines=lstAx.Children;
        for n=1:numel(lastLines)
            lastLine(n).Color=[1,0,0];
        end
        hold all
    else
        hold off
    end
    
    mainColor=[0,0,0];
    plot(timeVec,mainTrace(1,:)','Color',mainColor,'LineWidth',1.1);
    lstAx=gca;
    h=lstAx.Children;
    if numel(h)>1
        for k=2:numel(h)
            h(k).Color=[1,0,0];
        end
    else
    end
    hold off
    
    ylim([yLow yHigh])
    
    % plot the mask too
    
    axes(handles.roiMaskAxis)
        
    mainMask=evalin('base',[mainType 'ROIs{' num2str(mainTypeID) '}']); %*relatedCorrelations(n);
    g=[1,1,1]; % the mainROI color is white
    rgb=cat(3,mainMask*g(1),mainMask*g(2),mainMask*g(3));
    
    
    if holdLast
        lAx=gca;
        lastMask=lAx.Children.CData;
        g=[1,0,0]; % the current color is white, hold is red
        % last mask is already rgb
        rgb=(lastMask+rgb);
    end
    
    
    mP=imshow(rgb);
    a=gca;
    a.YTick=[];
    a.XTick=[];
    
    assignin('base','curHMask',mP);
    
    % plot related traces
    plotRelated=get(handles.showCorrelatedToggle,'Value');
    relatedThreshold=str2double(get(handles.corThresholdEntry,'String'));
    if plotRelated
        % get all traces and masks of the types selected
        allTypes=returnAllTypes(hObject,eventdata,handles);

        for n=1:numel(allTypes)
            whoIsOn(n)=eval(['get(handles.' allTypes{n} 'ROIs_DisplayToggle, ''Value'');']);
        end
        
        whoIsOn=find(whoIsOn==1);
        tracesToGrab=eval(['allTypes([' num2str(whoIsOn) ']);']);
        allTraces=[];
        allROIMasks=[];
        allROICentroids=[];
        for k=1:numel(tracesToGrab)
            pltDF=get(handles.plotAsDFToggle,'Value');
            if pltDF
                allTraces=vertcat(allTraces,evalin('base',[tracesToGrab{k} 'F_DF;']));
            else
                allTraces=vertcat(allTraces,evalin('base',[tracesToGrab{k} 'F;']));
            end
                allROIMasks=horzcat(allROIMasks,evalin('base',[tracesToGrab{k} 'ROIs;']));
                allROICentroids=horzcat(allROICentroids,evalin('base',[tracesToGrab{k} 'ROICenters;']));
        end
        
        % compute the correlations between the primary and the rest
        curCorr=corr(repmat(mainTrace,size(allTraces,1),1)',allTraces');
        
        axes(handles.corAxis)
        plot(curCorr','k-','linewidth',0.5)
        hold all
        plot([1 totalROIs],[relatedThreshold relatedThreshold],'r:','LineWidth',1)
        hold off
        ylim([-0.1,1.1])
        
        [csV,csI]=sort(curCorr','descend');
        csV=csV(:,1);
        csI=csI(:,1);
        
        % threshold the correlations and plot the values
        relatedROIs=csI(csV>=relatedThreshold);
        relatedCorrelations=csV(csV>=relatedThreshold);
        
        hold all
        scatter(relatedROIs,relatedCorrelations,'filled','MarkerEdgeColor',[0 0 0],...
            'MarkerFaceColor',[0.0,0.5,1.0],'SizeData',70)
        hold off
        
        
        % get primary and secondary masks based on their previous ids
        primaryMask=allROIMasks{mainROIBoxID};
        primaryCentroid=allROICentroids{mainROIBoxID};

        % related pairwise distance (Euclidean) b is the primary reference
        for n=1:numel(relatedROIs)
            relatedPixelCounts(:,n)=numel(find(allROIMasks{n}==1));
            b=primaryCentroid.Centroid;
            a=allROICentroids{n}.Centroid;
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
        % allROIStrings

        relatedROIs=relatedROIs(tSrtI);
        relatedCorrelations=relatedCorrelations(tSrtI);
        relatedDistances=relatedDistances(tSrtI);
        relatedPixelCounts=relatedPixelCounts(tSrtI);

        
        % shrink the total mask and traces to the related ones (including
        % primary)
        % keep the traces and masks of interest
        % the primary is in all, but this is convinent.
        primarySubgroupID=find(relatedROIs==mainROIBoxID);
        nonPrimarySubgroupID=setdiff(1:numel(relatedROIs),primarySubgroupID);
        
        allTraces=allTraces(relatedROIs,:);
        allROIMasks=allROIMasks(relatedROIs);
        allROICentroids=allROICentroids(relatedROIs);
        
        % now get the roi types for all realted
        allRelatedTypeStrings=allROIStrings(relatedROIs);
        for n=1:numel(allRelatedTypeStrings)
            tSplt=strsplit(allRelatedTypeStrings{n},'_');
            tAcum(n)=tSplt(1);
        end
        
        allRelatedTypeStrings=tAcum;
        primaryTypeString=allRelatedTypeStrings(primarySubgroupID);
        nonPrimaryTypeString=allRelatedTypeStrings(nonPrimarySubgroupID);

        % update the masks
        axes(handles.roiMaskAxis)
        lAx=gca;
        lastMask=lAx.Children.CData;
        % last mask is already rgb
        rVals=fix(tSrtV*10);
        vRange=max(rVals)-min(rVals);
        mapValNum=numel(rVals)*1;


        aa=colormap(jet(mapValNum));
        rgb=zeros(size(lastMask));
        for n=1:numel(nonPrimarySubgroupID)
            mainMask=allROIMasks{nonPrimarySubgroupID(n)};
            g=aa(n,:);
            trgb=cat(3,mainMask*g(1),mainMask*g(2),mainMask*g(3));
            rgb=(rgb+trgb);
        end
        rgb=lastMask+rgb;
        mP=imshow(rgb);
        mCA=gca;
        mCA.YTick=[];
        mCA.XTick=[];
    
        assignin('base','curHMask',mP);
        
        % plot the related traces exclude the primary as we've plotted it.
        axes(handles.traceDisplay)
        % add to accumulating h's for making figures etc.
        lastH=numel(h);
        
        for n=1:numel(nonPrimarySubgroupID)
            % allColors{strcmp(allTypes,nonPrimaryTypeString{n})},
            g=aa(n,:);
            hold all
            h(n+lastH)=plot(timeVec,allTraces(nonPrimarySubgroupID(n),:)','Color',g,...
                'LineWidth',allWidths(strcmp(allTypes,nonPrimaryTypeString{n}))); 
        end
        hold off
        assignin('base','curh',h);
        set(h,'ButtonDownFcn',{@LineSelected,h})
        

        relCString=strjoin(allROIStrings(relatedROIs),',');
        set(handles.relatedCellsReturn,'String',relCString);

        relVString=strjoin(arrayfun(@(x) num2str(x),relatedCorrelations,'UniformOutput',false),',');
        set(handles.relatedValuesReturn,'String',relVString)
        % assignin('base','dbugV',relatedCorrelations') %todo: 3dplot

        relDString=strjoin(arrayfun(@(x) num2str(x),relatedDistances,'UniformOutput',false),',');
        set(handles.relatedDistReturn,'String',relDString);
        % assignin('base','dbugD',relatedDistances)

        relPCString=strjoin(arrayfun(@(x) num2str(x),relatedPixelCounts,'UniformOutput',false),',');
        set(handles.relatedPixelCountReturn,'String',relPCString);
        % assignin('base','dbugPC',relatedPixelCounts)
        

        % relatedDistances=[1]; % debug
        if numel(relatedDistances)>=2
            axes(handles.featureHist)
            nhist(relatedDistances,'box');
            xlim([0 200])

            axes(handles.featurePlot)

            
            for n=1:numel(relatedROIs)
                g=aa(n,:);
                plot(relatedROIs(n),relatedDistances(n),'o','Color',g)
                hold all
            end

            plot([1 size(curCorr,1)],[20 20],'r:','linewidth',1)
            hold off
            ylim([0 200])

        else
            axes(handles.featureHist)
            plot([],[])
            ylim([0 200])
            axes(handles.featurePlot)
            plot([],[])
            hold on
            plot([1 size(curCorr,1)],[20 20],'r:','linewidth',1)
            hold off
            ylim([0 200])
        end
    else
        axes(handles.corAxis)
        plot([1 totalROIs],[relatedThreshold relatedThreshold],'r:','LineWidth',1)
        ylim([-0.1,1.1])
        
    end
    
    
    clear  mainTrace allTraces allROIMasks allROICentroids
    guidata(hObject, handles);
function displayedROICounter_Callback(hObject, eventdata, handles)
    input = str2num(get(hObject,'String'));
    minVal=get(handles.roiDisplaySlider, 'Min');
    maxVal=get(handles.roiDisplaySlider, 'Max');
    
    %checks to see if input is empty. if so, default input1_editText to zero
    if (isempty(input))
         set(hObject,'String','1')
    end

    if input<1
        input=1;
        set(handles.displayedROICounter,'Value',input);
    else
    end
    
    if input<minVal
        input=minVal;
        set(handles.displayedROICounter,'Value',input);
    elseif input>maxVal
        input=maxVal;
        set(handles.displayedROICounter,'Value',input);
    else
    end
    
    set(handles.roiDisplaySlider,'Value',input);

    roiDisplaySlider_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);

% *********************************************************************
% *********** These Functions Deal With the roiDisplayToggles *********
% *********************************************************************

function [returnTypeStrings,typeAllColor,lWidths]=returnAllTypes(hObject,eventdata,handles)
    % set all known ROI types here
    returnTypeStrings={'somatic','redSomatic','dendritic','axonal','bouton','vessel','neuropil'};
    typeAllColor={[0,0.8,0.3],[1,0,0],[0,0,1],[1,0,1],[1,1,0],[0.7,0.3,0],[1 0.1 0]};
    lWidths=[1,1,1,1,1,1,1];
function [typeList]=getKnownROITypes(hObject, eventdata, handles)
    typeList={'neuropilRois','vascularRois','boutonRois',...
    'axonRois','dendriteRois','somaRois','redSomaticRois'};
    typeList={'neuropil','vessel','bouton',...
    'axonal','dendritic','somatic','redSomatic'};
    % todo: fix names with 'knownTypes', the typeList is a temp hack.
function genericDispalyTypeToggle(hObject, eventdata, handles)
    
    [allTypes,allColors]=returnAllTypes(hObject,eventdata,handles);

    for n=1:numel(allTypes)
        whoIsOn(n)=eval(['get(handles.' allTypes{n} 'ROIs_DisplayToggle, ''Value'');']);
    end

    whoIsOn=find(whoIsOn==1);

    if numel(whoIsOn)==0
        set(handles.roiSelector,'String','');
    else
    end

    roiCounter=0;
    for rI=1:numel(whoIsOn)
        typeString=allTypes{whoIsOn(rI)};
        gf=checkForWSVar([typeString 'F']);
        gdf=checkForWSVar([typeString 'F_DF']);
        if gf==1 | gdf==1
            h=evalin('base',[typeString 'RoiCounter']);
            % Populate the box:
            for n=1:h
                roiCounter=roiCounter+1;
                roisList{roiCounter}=[typeString '_' num2str(n)];
            end
            set(handles.roiSelector, 'String', '');
            set(handles.roiSelector,'String',roisList);
            set(handles.roiSelector,'Value',h)
        else
        end
    end
    
    % now we need to reset the sliders
    tCnt=roiCounter;
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
    
    guidata(hObject, handles);
function somaticROIs_DisplayToggle_Callback(hObject, eventdata, handles)
    genericDispalyTypeToggle(hObject, eventdata, handles)
    guidata(hObject, handles);
function dendriticROIs_DisplayToggle_Callback(hObject, eventdata, handles)
    genericDispalyTypeToggle(hObject, eventdata, handles)
    guidata(hObject, handles);
function boutonROIs_DisplayToggle_Callback(hObject, eventdata, handles)
    genericDispalyTypeToggle(hObject, eventdata, handles)
    guidata(hObject, handles);
function axonalROIs_DisplayToggle_Callback(hObject, eventdata, handles)
    genericDispalyTypeToggle(hObject, eventdata, handles)
    guidata(hObject, handles);
function vesselROIs_DisplayToggle_Callback(hObject, eventdata, handles)
    genericDispalyTypeToggle(hObject, eventdata, handles)
    guidata(hObject, handles);
function redSomaticROIs_DisplayToggle_Callback(hObject, eventdata, handles)
    genericDispalyTypeToggle(hObject, eventdata, handles)
    guidata(hObject, handles);
function neuropilROIs_DisplayToggle_Callback(hObject, eventdata, handles)

    genericDispalyTypeToggle(hObject, eventdata, handles)
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
    % gIs=str2num(get(handles.relatedCellsReturn,'String'));
    gIs=get(handles.relatedCellsReturn,'String');
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
function rcBtn_generic_Callback(hObject, eventdata, handles)

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


    related=get(handles.relatedCellsReturn,'String');
    rCell=strsplit(related,',');
    rCell=rCell(2:end);
    tString=[];
    for n=1:numel(rCell)
        selectedSplit=strsplit(rCell{n},'_');
        tString{n}=selectedSplit{1};
        tID{n}=str2double(selectedSplit{2});
    end


    roiNumList=cell2mat(tID);
    % assignin('base','troiNumList',roiNumList)
    assignin('base','tString',tString)


    try
        unStr=cellfun(@unique,{dtString},'UniformOutput',0);
        for p=1:numel(unStr{1})
            for n=1:numel(rCell)
                kIDs=cell2mat(tID(tString{n}==unStr{1}{n}));
            end
            evalin('base',[tString{n} 'ROI_PixelLists([' num2str(kIDs) '])=[]'])
            evalin('base',[tString{n} 'ROIBoundaries([' num2str(kIDs) '])=[]'])
            evalin('base',[tString{n} 'ROICenters([' num2str(kIDs) '])=[];'])
            evalin('base',[tString{n} 'ROIs([' num2str(kIDs) '])=[];'])
            evalin('base',[tString{n} 'RoiCounter=numel(' uniqueTypes{n} 'ROIs);'])
        end
    catch
    end
    guidata(hObject, handles);

    % evalin(scopeString,[uniqueTypes{n} 'ROI_PixelLists([' num2str(roisToDelete) '])=[];'])
    % evalin(scopeString,[uniqueTypes{n} 'ROIBoundaries([' num2str(roisToDelete) '])=[];'])
    % evalin(scopeString,[uniqueTypes{n} 'ROICenters([' num2str(roisToDelete) '])=[];'])
    % evalin(scopeString,[uniqueTypes{n} 'ROIs([' num2str(roisToDelete) '])=[];'])
    % evalin(scopeString,[uniqueTypes{n} 'RoiCounter=numel(' uniqueTypes{n} 'ROIs);'])

    %     advance=1;

    % rN=fix(str2double(get(handles.displayedROICounter,'String')))+advance;
    % set(handles.roiDisplaySlider,'Value',rN)
    % guidata(hObject, handles);
    % roiDisplaySlider_Callback(hObject, eventdata, handles)
    % somaRoisDisplayToggle_Callback(hObject, eventdata, handles)

    % try
    %     unStr=cellfun(@unique,{dtString},'UniformOutput',0);
    %     for p=1:numel(unStr{1})
    %         for n=1:numel(rCell)
    %             kIDs=cell2mat(dtID(dtString{n}==unStr{1}{n}));
    %             deleteROI(tID,tString);
    %         end
    % catch
    % end
    



    % deleteROI(tID,tString);

    
    % kill=related(2:end);
    % killNum=numel(kill);
    % if killNum>=1
    % tKS=strjoin(arrayfun(@(x) num2str(x),kill,'UniformOutput',false),',');
    % killString=['[' tKS ']'];


    % evalin('base',['somaticF(' killString ',:)=[];']);
    % evalin('base','somaticRoiCounter=size(somaticF,1);');
    % evalin('base',['somaticROI_PixelLists(' killString ')=[];']);
    % evalin('base',['somaticROIBoundaries(' killString ')=[];']);
    % evalin('base',['somaticROICenters(' killString ')=[];']);
    % evalin('base',['somaticROIs(' killString ')=[];']);

    % refreshWSVarsBtn_Callback(hObject, eventdata, handles)
    % guidata(hObject, handles);
    % advance=0;
    % else
    %     advance=1;
    % end
    % rN=fix(str2double(get(handles.displayedROICounter,'String')))+advance;
    % set(handles.roiDisplaySlider,'Value',rN)
    % guidata(hObject, handles);
    % roiDisplaySlider_Callback(hObject, eventdata, handles)
    % somaRoisDisplayToggle_Callback(hObject, eventdata, handles)
function killSelectedBtn_Callback(hObject, eventdata, handles)
    
    selections = get(handles.roiSelector,'String');
    selectionsIndex = get(handles.roiSelector,'Value');
    selectedSplit=strsplit(selections{selectionsIndex},'_');
    tString=selectedSplit(1);
    tID=str2double(selectedSplit(2));
    deleteROI(tID,tString);
    genericDispalyTypeToggle(hObject, eventdata, handles)
    
    if selectionsIndex>1
        nV=selectionsIndex;
    else
        nV=1;
    end
    
    set(handles.roiSelector,'Value',nV);
    roiSelector_Callback(hObject, eventdata, handles)
    refreshWSVarsBtn_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
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
    % hh(1,end).Color=[0,0,0];
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
    % hh(1,end).Color=[1,1,1];
function sortByMenu_Callback(hObject, eventdata, handles)
    
    roiDisplaySlider_Callback(hObject, eventdata, handles)
function sortAscend_Callback(hObject, eventdata, handles)
    
    roiDisplaySlider_Callback(hObject, eventdata, handles)
function [numSel]=LineSelected(hObject, eventdata, handels)
    set(hObject, 'LineWidth', 1.5);
    set(handels(handels ~= hObject), 'LineWidth', 0.4);
    sI=(handels==hObject);
    numSel=find(sI==1);
    
    assignin('base','selectedTraceNum',numSel)
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

function roiSelector_CreateFcn(hObject, eventdata, handles)

    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
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
function quantDFEntry_CreateFcn(hObject, eventdata, handles)
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
function relatedPixelCountReturn_Callback(hObject, eventdata, handles)
function relatedPixelCountReturn_CreateFcn(hObject, eventdata, handles)
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
function movBaselineWinEntry_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function typeSelectorMenu_CreateFcn(hObject, eventdata, handles)


    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function medianExtractToggle_Callback(hObject, eventdata, handles)


% ****************** Standard MATLAB GUI Opening Functions

function extractor_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    vars = evalin('base','who');
    set(handles.workspaceVarBox,'String',vars)
    refreshCSVarBtn_Callback(hObject, eventdata, handles)

    if strcmp(computer,'MACI64') || strcmp(computer,'GLNXA64')
        macHeaderSize=12;
        macFontSize=11;
        macUIDecSize=10;

    elseif strcmp(computer,'PCWIN64') 
        macHeaderSize=8;
        macFontSize=7;
        macUIDecSize=6;
    else
    end

    uiElements={'saveWSBtn','refreshWSVarsBtn','deleteSelection','workspaceVarBox',...
    'firstImageEntry','endImageEntry','diskExtractButton','diskRegFlag','checkbox15',...
    'dataAppendToggle','diskExtractSkipByToggle','diskExtractSkipByEntry',...
    'diskExtractSkipByStartEntry','somaExtractCheck','dendriteExtractCheck',...
    'axonExtractCheck','boutonExtractCheck','medianExtractToggle','extractButton',...
    'vascularExtractCheck','neuropilExtractCheck','redSomaticExtractCheck',...
    'somaticROIs_DisplayToggle','dendriticROIs_DisplayToggle','axonalROIs_DisplayToggle',...
    'boutonROIs_DisplayToggle','redSomaticROIs_DisplayToggle','neuropilROIs_DisplayToggle',...
    'vesselROIs_DisplayToggle','plotAsDFToggle','movingAvgBtn','smoothWindowEntry',...
    'typeSelectorMenu','slidingBaselineBtn','useQuantForDFToggle','movBaselineWinEntry',...
    'yHighTrace','yLowTrace','xLowTrace','xHighTrace','saveTracesPDFBtn','holdCurrentROILinesToggle',...
    'roiSelector','displayedROICounter','showCorrelatedToggle','corThresholdEntry','sortByMenu',...
    'sortAscend','relatedCellsReturn','relatedValuesReturn','relatedDistReturn',...
    'relatedPixelCountReturn','groupCounter','killGroupBtn','killFirstBtn','keepFirstBtn',...
    'groupMarkerBtn','killSelectedBtn','rcBtn_generic','deleteFlagged','flagROIButton','importerBtn',...
    'roiMakerBtn','loadCSHDF','csListbox','plotCSVar','setImageTime','setCSTime','refreshCSVarBtn',...
    'plotNormToggle','upSampleTrimImages','plotScaleEntry','binByToggle','binByEntry'};

    for n=1:numel(uiElements)
        eval(['handles.' uiElements{n} '.FontSize=macFontSize;'])
    end
    
    decUIElements={'text29','text4','text14','text11','text15','text16',...
    'corAxis','featureHist','featurePlot','text1','text9','text24','relatedValuesSt',...
    'text18','text22','text27','text19','text37','text36'};
    
    for n=1:numel(decUIElements)
        eval(['handles.' decUIElements{n} '.FontSize=macUIDecSize;'])
    end
    
    titleUIElements={'uipanel13','uipanel6','uipanel7','uipanel8','uipanel9',...
    'uipanel5','uipanel1','uipanel15','uipanel10','uipanel6','uipanel16','csParserPanel'};
    
    for n=1:numel(titleUIElements)
        eval(['handles.' titleUIElements{n} '.FontSize=macHeaderSize;'])
    end

    refreshWSVarsBtn_Callback(hObject, eventdata, handles);
    guidata(hObject, handles);
function varargout = extractor_OutputFcn(hObject, eventdata, handles) 

    varargout{1} = handles.output;    

% ****************** end

% ****************** New Stuff

function plotAsDFToggle_Callback(hObject, eventdata, handles)
function roiSelector_Callback(hObject, eventdata, handles)
    
    roiSelectionNum=get(handles.roiSelector,'Value');
    
    % make sure the slider is caught up
    set(handles.roiDisplaySlider,'Value',roiSelectionNum);
    sliderValue = get(handles.roiDisplaySlider,'Value');
    
    % make sure the slider text entry is caught up
    set(handles.displayedROICounter,'String', num2str(sliderValue));
    
    guidata(hObject, handles)
    plotROI(hObject, eventdata, handles)
function holdCurrentROILinesToggle_Callback(hObject, eventdata, handles)
function slidingBaselineBtn_Callback(hObject, eventdata, handles)
    
    
    pause(0.0000000000001);
    guidata(hObject, handles);
        
    frmWinSize=get(handles.movBaselineWinEntry,'String');
    typeID=get(handles.typeSelectorMenu,'Value');
    tString=get(handles.typeSelectorMenu,'String');
    
    selectedType=tString{typeID};
    set(handles.feedbackString,'String',['Baselining: ' selectedType])
    pause(0.0000000000001);
    guidata(hObject, handles);

    if checkForWSVar([selectedType 'F_BLCutOffs'])==0
        evalin('base',[selectedType 'F_BLCutOffs=computeQunatileCutoffs(' selectedType  'F);']);
    else
    end
    evalin('base',['for n=1:size(' selectedType 'F,1),' selectedType 'BL(n,:)=slidingBaseline(' ...
        selectedType 'F(n,:),' frmWinSize ',' selectedType 'F_BLCutOffs(n));,end'])
    evalin('base',[selectedType 'F_nonBL=' selectedType 'F;'])
    evalin('base',[selectedType 'F=' selectedType 'F-'  selectedType 'BL;'])
    evalin('base',[selectedType 'F_DF=' selectedType 'F./'  selectedType 'BL;'])

    set(handles.feedbackString,'String',['Done With: ' selectedType])
    pause(0.0000000000001);
    guidata(hObject, handles);

    refreshWSVarsBtn_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
function movBaselineWinEntry_Callback(hObject, eventdata, handles)
function makeDFFBtn_Callback(hObject, eventdata, handles)
function quantDFEntry_Callback(hObject, eventdata, handles)
function useQuantForDFToggle_Callback(hObject, eventdata, handles)
function saveWSBtn_Callback(hObject, eventdata, handles)
function deleteSelection_Callback(hObject, eventdata, handles)
    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    selectedItem=selections{selectionsIndex};
    evalin('base',['clear ' selectedItem]);
    refreshWSVarsBtn_Callback(hObject, eventdata, handles)
    
    guidata(hObject, handles);
function typeSelectorMenu_Callback(hObject, eventdata, handles)
function pushbutton38_Callback(hObject, eventdata, handles)
function loadCSHDF_Callback(hObject, eventdata, handles)
    [hdfName,hdfPath]=uigetfile('*','what what?');
    try
      behavHDFPath=[hdfPath hdfName];
      behavHDFInfo=h5info(behavHDFPath);
      curDatasetPath=['/' behavHDFInfo.Datasets.Name];
      curBData=h5read(behavHDFPath,curDatasetPath);
      % attributes have int32 encoding and need to be converted.
      curOrientations=double(h5readatt(behavHDFPath,curDatasetPath,'orientations')).*10;
      curContrasts=double(h5readatt(behavHDFPath,curDatasetPath,'contrasts'))/10;
      % The way csVisual is set now, we end up with an extra trial's metadata.
      % So, I trim here.
      curOrientations=curOrientations(1:end-1);
      curContrasts=curContrasts(1:end-1);
      assignin('base','curOrientations',curOrientations');
      evalin('base',['bData.curOrientations=curOrientations;,clear curOrientations ans'])
      
      assignin('base','curContrasts',curContrasts');
      evalin('base',['bData.curContrasts=curContrasts;,clear curContrasts ans'])
      
      assignin('base','interrupts',curBData(1,:));
      evalin('base',['bData.interrupts=interrupts;,clear interrupts ans'])
      
      assignin('base','sessionTime',curBData(2,:)./1000);
      evalin('base',['bData.sessionTime=sessionTime;,clear sessionTime ans'])
      
      assignin('base','stateTime',curBData(3,:)./1000);
      evalin('base',['bData.stateTime=stateTime;,clear stateTime ans'])
      
      assignin('base','states',curBData(4,:));
      evalin('base',['bData.states=states;,clear states ans'])
      
      assignin('base','loadCell',curBData(5,:));
      evalin('base',['bData.loadCell=loadCell;,clear states ans'])
      
      assignin('base','pyStates',curBData(9,:));
      evalin('base',['bData.pyStates=pyStates;,clear pyStates ans'])
      
      assignin('base','motion',curBData(7,:));
      evalin('base',['bData.motion=motion;,clear motion ans'])
      
      assignin('base','scopePF',curBData(8,:));
      evalin('base',['bData.scopePFI=scopePF;,clear tLick1 ans'])
      
      assignin('base','thrLicks',curBData(10,:));
      evalin('base',['bData.thrLicks=thrLicks;,clear thrLicks ans'])
      
      

      position=decodeShaftEncoder(curBData(7,:),4);
      velocity=nPointDeriv(position,curBData(2,:),1000);
      velocity(find(isnan(velocity)==1))=0;
      assignin('base','position',position);
      evalin('base',['bData.position=position;,clear position ans'])
      assignin('base','velocity',velocity);
      evalin('base',['bData.velocity=velocity;,clear velocity ans'])
      evalin('base','[bData.stimSamps,bData.stimVector]=getStateSamps(bData.states,2,1);')



      
      
      bvars = evalin('base','fieldnames(bData)');
      set(handles.csListbox,'String',bvars)
      
      guidata(hObject, handles);
      
    catch
    end
    guidata(hObject, handles);
function csListbox_Callback(hObject, eventdata, handles)
function csListbox_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function refreshCSVarBtn_Callback(hObject, eventdata, handles)

    try
        bvars = evalin('base','fieldnames(bData)');
        set(handles.csListbox,'String',bvars)
    catch
    end
    guidata(hObject, handles);
function plotCSVar_Callback(hObject, eventdata, handles)

    selections = get(handles.csListbox,'String');
    selectionsIndex = get(handles.csListbox,'Value');
    selectTrace=selections{selectionsIndex};
    tTrace=evalin('base',['bData.' selectTrace]);
    csTime=evalin('base','bData.sessionTime');
    try
        scaleEntry=str2num(get(handles.plotScaleEntry,'String'));
    catch
        scaleEntry=1;
    end
    
    normTrace=get(handles.plotNormToggle,'Value');
    if normTrace==1
        tTrace=scaleEntry*((tTrace-min(tTrace))./max(tTrace-min(tTrace)));
      
    else
    end
    
    axes(handles.traceDisplay)
    holdLast=get(handles.holdCurrentROILinesToggle,'Value');
    if holdLast
        lstAx=gca;
        lastLines=lstAx.Children;
        for n=1:numel(lastLines)
            lastLine(n).Color=[1,0,0];
        end
        hold all
    else
        hold off
    end
    
    mainColor=[0,0,0];
    plot(csTime,tTrace(1,:)','Color',mainColor,'LineWidth',1.1);
    lstAx=gca;
    h=lstAx.Children;
    if numel(h)>1
        for k=2:numel(h)
            h(k).Color=[1,0,0];
        end
    else
    end
    hold off
    guidata(hObject, handles);
function setCSTime_Callback(hObject, eventdata, handles)
function setImageTime_Callback(hObject, eventdata, handles)

    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    selectTrace=selections{selectionsIndex};
    imTime=evalin('base',selectTrace);
    assignin('base','imTime',imTime);
    refreshWSVarsBtn_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
function plotNormToggle_Callback(hObject, eventdata, handles)
function upSampleTrimImages_Callback(hObject, eventdata, handles)
    try
        absTime=evalin('base','imTime');
        bTime=evalin('base','bData.sessionTime');
    catch
        return
    end
    
    imEnd=absTime(end);
    bhEnd=bTime(end);
    
    imOver=find(absTime>bhEnd);
    try
        imTrim=imOver(1)-1;
    catch
        imTrim=numel(absTime);
    end

    assignin('base','imTrim',imTrim);

    % this should always be true. 
    if imEnd>bhEnd
        absTime=absTime(1:imTrim);
        assignin('base','imTime',absTime); 
        assignin('base','imTrim',imTrim);   
    else
    end

    upsampleList={}
    upCount=1;
    try
        evalin('base','somaticF=somaticF(:,1:imTrim);')
        upsampleList{upCount}='somaticF'
        upCount=upCount+1;
    catch
    end

    try
        evalin('base','somaticF_DF=somaticF_DF(:,1:imTrim);')
        upsampleList{upCount}='somaticF_DF'
        upCount=upCount+1;
    catch
    end

    try
        evalin('redSomaticF=redSomaticF(:,1:imTrim);')
        upsampleList{upCount}='redSomaticF'
        upCount=upCount+1;
    catch
    end

    try
        evalin('redSomaticF_DF=redSomaticF_DF(:,1:imTrim);')
        upsampleList{upCount}='redSomaticF_DF'
        upCount=upCount+1;
    catch
    end
    
    
    for n=1:numel(upsampleList)
        evalin('base',['rsDataDF=rsCaData(transpose(' upsampleList{n}  '),transpose(imTime),bData.sessionTime);'])
        evalin('base','rsDataDF(find(isnan(rsDataDF)==1))=0;')
        evalin('base',[upsampleList{n} '=transpose(rsDataDF);, clear rsDataDF'])
    end
    assignin('base','imTime',transpose(bTime));

    

function plotScaleEntry_Callback(hObject, eventdata, handles)
function plotScaleEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function binByToggle_Callback(hObject, eventdata, handles)


function binByEntry_Callback(hObject, eventdata, handles)


function binByEntry_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
