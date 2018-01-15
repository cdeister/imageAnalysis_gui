function varargout = roiMaker(varargin)
% ROIMAKER 
% 
% roiMaker is a simple gui and set of processes for making various ROIs in
% imaging data. 
%
% No Documentation (yet)
%
%
% V1.0
% 10/12/2017
% Questions: cdeister@brown.edu
% Most Code: Chris Deister & Jakob Voigts (mfactor smoothing code! & speedy XCorr)
% Global XCorr Segmentation Idea: Stephan Junek et al., 2009 & Spencer Smith
% Global XCorr implimentation 



%***************************************************************
%
% Generic Matlab GUI Init Code
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @roiMaker_OpeningFcn, ...
                   'gui_OutputFcn',  @roiMaker_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before roiMaker is made visible.
function roiMaker_OpeningFcn(hObject, eventdata, handles, varargin)

    handles.output = hObject;

    vars = evalin('base','who');
    set(handles.workspaceVarBox,'String',vars)
    g=evalin('base','exist(''neuropilRoiCounter'')');

    if g
        set(handles.neuropilAlertString,'String','');
    else
        set(handles.neuropilAlertString,'ForegroundColor',[0 0 0]);
    end

    guidata(hObject, handles);
function varargout = roiMaker_OutputFcn(hObject, eventdata, handles) 

    varargout{1} = handles.output;
function [returnTypeStrings,typeAllColor]=returnAllTypes(hObject,eventdata,handles)
    
    % set all known ROI types here
    returnTypeStrings={'somatic','redSomatic','dendritic','axonal',...
    'bouton','vessel','neuropil'};
    typeAllColor={[0,0.8,0.3],[1,0,0],[0,0,1],[1,0,1],[1,1,0],...
    [0.7,0.3,0],[0.4,0.4,0.4]};
function addROIsFromMask(hObject,eventdata,handles,mask)

    sL=get(handles.roiTypeMenu,'String');
    sV=get(handles.roiTypeMenu,'Value');
    roiTypeSelected=sL{sV};
    assignin('base','roiSelectString',roiTypeSelected)

    g=evalin('base',['exist(''' roiTypeSelected 'RoiCounter' ''');']);

    if g==1
        h=evalin('base',[roiTypeSelected 'RoiCounter']);
        r=evalin('base',[roiTypeSelected 'ROIs']);
        c=evalin('base',[roiTypeSelected 'ROICenters']);
        b=evalin('base',[roiTypeSelected 'ROIBoundaries']);
        pl=evalin('base',[roiTypeSelected 'ROI_PixelLists']);
        h=h+1;
        
        r{h}=mask;
        b{h}=bwboundaries(mask);
        c{h}=regionprops(mask,'Centroid');
        pl{h}=regionprops(mask,'PixelList');
        
        
        assignin('base',[roiTypeSelected 'ROIs'],r)
        assignin('base',[roiTypeSelected 'ROICenters'],c)
        assignin('base',[roiTypeSelected 'ROIBoundaries'],b)
        assignin('base',[roiTypeSelected 'RoiCounter'],h)
        assignin('base',[roiTypeSelected 'ROI_PixelLists'],pl)
        
    else
        h=1;
        assignin('base',[roiTypeSelected 'ROIs'],{mask})
        assignin('base',[roiTypeSelected 'ROICenters'],{regionprops(mask,'Centroid')})
        assignin('base',[roiTypeSelected 'ROI_PixelLists'],{regionprops(mask,'PixelList')})
        assignin('base',[roiTypeSelected 'ROIBoundaries'],{bwboundaries(mask)})
        assignin('base',[roiTypeSelected 'RoiCounter'],h)
    end
    roisDisplayToggle(hObject,eventdata,handles,1)
    refreshVarListButton_Callback(hObject, eventdata, handles);
    guidata(hObject, handles);
function freehandROI(hObject,eventdata,handles,typeString)

    g=evalin('base',['exist(' '''' typeString ''  'RoiCounter'')']);
    if g==1
        h=evalin('base',[typeString 'RoiCounter']);
        r=evalin('base',[typeString 'ROIs']);
        c=evalin('base',[typeString 'ROICenters']);
        b=evalin('base',[typeString 'ROIBoundaries']);
        pl=evalin('base',[typeString 'ROI_PixelLists']);
        
        h=h+1;
        a=imfreehand;
        mask=a.createMask;
        
        
        r{h}=mask;
        b{h}=bwboundaries(mask);
        c{h}=regionprops(mask,'Centroid');
        pl{h}=regionprops(mask,'PixelList');
        
        
        assignin('base',[typeString 'ROIs'],r)
        assignin('base',[typeString 'ROICenters'],c)
        assignin('base',[typeString 'ROIBoundaries'],b)
        assignin('base',[typeString 'RoiCounter'],h)
        assignin('base',[typeString 'ROI_PixelLists'],pl)
        assignin('base','roiSelectString',typeString)
        
    else
        h=1;
        a=imfreehand;
        mask=a.createMask;
        
        assignin('base',[typeString 'ROIs'],{mask})
        assignin('base',[typeString 'ROICenters'],{regionprops(mask,'Centroid')})
        assignin('base',[typeString 'ROIBoundaries'],{bwboundaries(mask)})
        assignin('base',[typeString 'RoiCounter'],h)
        assignin('base',[typeString 'ROI_PixelLists'],{regionprops(mask,'PixelList')})
        assignin('base','roiSelectString',typeString)
       
    end
    roisDisplayToggle(hObject,eventdata,handles,1)
    % eval([typeString 'RoisDisplayToggle_Callback(handles.' typeString 'RoisDisplayToggle,eventdata,handles,1)'])
    % eval([typeString 'RoisDisplayToggle_Callback(handles.' typeString 'RoisDisplayToggle,eventdata,handles,1)'])
    refreshVarListButton_Callback(hObject, eventdata, handles);
    guidata(hObject, handles);
function somaButton_Callback(hObject, eventdata, handles)

    freehandROI(hObject,eventdata,handles,'somatic')
function redSomaButton_Callback(hObject, eventdata, handles)
    
    freehandROI(hObject,eventdata,handles,'redSomatic')
function dendriteButton_Callback(hObject, eventdata, handles)
    
    freehandROI(hObject,eventdata,handles,'dendritic')
function axonButton_Callback(hObject, eventdata, handles)

    freehandROI(hObject,eventdata,handles,'axonal')
function boutonButton_Callback(hObject, eventdata, handles)
    
    freehandROI(hObject,eventdata,handles,'bouton')
function vesselButton_Callback(hObject, eventdata, handles)

    freehandROI(hObject,eventdata,handles,'vessel')

function [wsObj wsClass]=getWSVar(hObject, eventdata, handles)
    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    wsObj=evalin('base',selections{selectionsIndex});
    wsClass=class(wsObj);

function roiSelector_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function loadMeanProjectionButton_Callback(hObject, eventdata,handles,defImage)

    a = str2double(get(handles.lowCutEntry,'String'));
    b = str2double(get(handles.highCutEntry,'String'));
    updateHist=1;

    if nargin==3
    [imageP imClass]=getWSVar(hObject, eventdata, handles);
    else
        imageP=defImage;
        imClass=class(defImage);
        updateHist=0;
    end

    if strcmp(imClass,'logical')
        tMxVl=1;
        updateHist=0;
    else
        tMxVl=max(max(imageP(:,:,1)));
    end

    hSM = get(handles.highCutSlider,'Max');

    if tMxVl<=2
        rangeOne=1;
    else
        rangeOne=0;
    end

    if hSM==1
        lastLogical=1;
    else
        lastLogical=0;
    end

    if (rangeOne==0 && lastLogical==1) || (rangeOne==1 && lastLogical==0)
        typeChange=1;
    else
        typeChange=0;
    end

    if typeChange==1
        if rangeOne
          set(handles.highCutSlider,'Max',1.0);
          set(handles.highCutSlider,'Min',0.0);
          set(handles.lowCutSlider,'Max',1.0);
          set(handles.lowCutSlider,'Min',0.0);
          set(handles.highCutSlider,'Value',1.0);
          set(handles.lowCutSlider,'Value',0.0);
          set(handles.highCutEntry,'String','1.0');
          set(handles.lowCutEntry,'String','0.0');
          guidata(hObject, handles);
        else
          set(handles.highCutSlider,'Max',65535);
          set(handles.highCutSlider,'Min',0);
          set(handles.lowCutSlider,'Max',65535);
          set(handles.lowCutSlider,'Min',0);
          set(handles.highCutSlider,'Value',65535);
          set(handles.lowCutSlider,'Value',0);
          set(handles.highCutEntry,'String','65535');
          set(handles.lowCutEntry,'String','0');
          guidata(hObject, handles);
        end
    else
    end

    if numel(size(imageP))==3
        
        stackNum=size(imageP,3);
        stackInd=fix(str2num(get(handles.frameTextEntry,'String')));
        if stackInd>stackNum
            set(handles.frameTextEntry,'String','stackNum');
            guidata(hObject, handles);
        else
        end
        try
            imageP=imageP(:,:,stackInd);
        catch
        end

        sliderMin = 1;
        sliderMax = fix(stackNum); % this is variable
        sliderStep = [1, 1] / (sliderMax - sliderMin); % major and minor steps of 1
        
        set(handles.frameSlider, 'Min', sliderMin);
        set(handles.frameSlider, 'Max', sliderMax);
        set(handles.frameSlider, 'SliderStep', sliderStep);
        set(handles.frameSlider, 'Value', stackInd); % set to beginning of sequence
        guidata(hObject, handles);
        
    else
        set(handles.frameTextEntry,'String','1');
        sliderMin = 0;
        sliderMax = 1; % this is variable
        sliderStep = [1, 1] / (sliderMax - sliderMin); % major and minor steps of 1
        
        set(handles.frameSlider, 'Min', sliderMin);
        set(handles.frameSlider, 'Max', sliderMax);
        set(handles.frameSlider, 'SliderStep', sliderStep);
        set(handles.frameSlider, 'Value', 1); % set to beginning of sequence
        set(handles.frameTextEntry,'Value',1);
        guidata(hObject, handles);
    end

    a = str2double(get(handles.lowCutEntry,'String'));
    b = str2double(get(handles.highCutEntry,'String'));

    medFilter=get(handles.medianFilterToggle,'Value');
    if medFilter==1
        imageP=medfilt2(imageP);
    else
    end

    wienerFilter=get(handles.wienerFilterToggle,'Value');
    if wienerFilter==1
        imageP=wiener2(imageP);
    else
    end

    sL=get(handles.colormapTextEntry,'String');
    sV=get(handles.colormapTextEntry,'Value');
    cMap=sL{sV};

    axes(handles.imageWindow);

    imshow(imageP,'DisplayRange',[a b]);
    colormap(gca,cMap)

    if updateHist
        axes(handles.imageHistogram);
        nhist(nonzeros(imageP),'box','maxbins',40);
        xlim([0 b])
        hold all
        plot([a a],[0 20000],'r-')
        plot([b b],[0 20000],'b-')
        hold off
    else
    end
    roisDisplayToggle(hObject,eventdata,handles,1)
    refreshVarListButton_Callback(hObject, eventdata, handles);
    guidata(hObject, handles);

function deleteROIButton_Callback(hObject, eventdata, handles)

    boxNum=get(handles.roiSelector,'Value');
    boxStrings=get(handles.roiSelector,'String');
    specifiedString=boxStrings{boxNum};

    stringSplit=strsplit(specifiedString,'_');


    typeString=stringSplit{1};
    roiNumber=fix(str2double(stringSplit{2}));
    deleteROI(roiNumber,{typeString});

    roisDisplayToggle(hObject, eventdata, handles,1)

    % alert the user their neuropil masks will be out of sync.
    g=evalin('base','exist(''neuropilRoiCounter'')');
    if g 
        set(handles.neuropilAlertString,'String','regenerate neuropil masks -->',...
            'ForegroundColor',[1 0 0]);
    else
        set(handles.neuropilAlertString,'ForegroundColor',[0 0 0]);
    end
    if boxNum>1
        set(handles.roiSelector,'Value',boxNum-1);
    else
        
        set(handles.roiSelector,'Value',1);
    end

    roisDisplayToggle(hObject,eventdata,handles)
    refreshVarListButton_Callback(hObject, eventdata, handles);
    guidata(hObject, handles);
    
function plotAnROI(hObject,eventdata,handles,roiCenters,roiBoundaries,boundaryColors)
    if nargin==5
        boundaryColors=repmat({[1 0 0]},1,numel(roiCenters));        
    else
    end
    if numel(roiCenters)>0
        for n=1:numel(roiCenters)
            c=roiCenters{n};
            b=roiBoundaries{n};
            for k=1:numel(c)
                plot(b{1,n}{k,1}(:,2),b{1,n}{k,1}(:,1),'Color',boundaryColors{n},'LineWidth',2.5)
                % text(c{1,n}(k).Centroid(1)-1, c{1,n}(k).Centroid(2),num2str(n),'FontSize',10,'FontWeight','Bold','Color',textColors{n});
            end
        end
    else
    end
  
function plotSomeROIs(hObject,eventdata,handles,plotRemainder,roisToPlot)
    
    if numel(roisToPlot)
        axes(handles.imageWindow)
        a=gcf;
        try
            cI=a.CurrentAxes.Children(end).CData;
            loadMeanProjectionButton_Callback(hObject,eventdata,handles,cI);
        catch
            loadMeanProjectionButton_Callback(hObject,eventdata,handles);
        end
        hold all
        if plotRemainder
            roisDisplayToggle(hObject,eventdata,handles,1)
            hold all
        else
        end
        
        for n=1:numel(roisToPlot)    
            stringSplit=strsplit(roisToPlot{n},'_');
            typeString=stringSplit{1};
            roiNumber=fix(str2double(stringSplit{2}));
            c{n}=evalin('base',[typeString 'ROICenters([' num2str(roiNumber) ']);']);
            b{n}=evalin('base',[typeString 'ROIBoundaries([' num2str(roiNumber) ']);']);
        end
        plotAnROI(hObject,eventdata,handles,c,b)
        hold off
        refreshVarListButton_Callback(hObject, eventdata, handles);
        guidata(hObject, handles);
    else
    end
    
function roiSelector_Callback(hObject,eventdata,handles)

    boxNum=get(handles.roiSelector,'Value');
    boxStrings=get(handles.roiSelector,'String');

    if numel(boxNum)>0
        for n=1:numel(boxNum)
            specifiedStrings{n}=boxStrings{boxNum};
        end
        plotSomeROIs(hObject,eventdata,handles,1,specifiedStrings)
    else
    end 
    
    refreshVarListButton_Callback(hObject, eventdata, handles);
    guidata(hObject, handles);

function roisDisplayToggle(hObject,eventdata,handles,justUpdate,useTxtLabels)

    if nargin==3
        justUpdate=0;
        useTxtLabels=1;
    end

    if nargin == 4
        useTxtLabels=1;
    end
    % if justUpdate~=2
        % if you don't want to update clear all and start again
        % note no hold
        if justUpdate==0
            loadMeanProjectionButton_Callback(hObject, eventdata, handles)
        else
        end
    
        % this executes for all
        axes(handles.imageWindow)
        [allTypes,allColors]=returnAllTypes(hObject,eventdata,handles);
        % reset the box
        set(handles.roiSelector,'String','');
        guidata(hObject, handles);

        % see who is (still) on
        for n=1:numel(allTypes)
            whoIsOn(n)=eval(['get(handles.' allTypes{n} 'RoisDisplayToggle, ''Value'');']);
        end
        whoIsOn=find(whoIsOn==1);

        roiCounter=0;
        for rI=1:numel(whoIsOn)
            typeString=allTypes{whoIsOn(rI)};
            g=evalin('base',['exist(''' typeString 'ROICenters'');']);
            if g==1
                c=evalin('base',[typeString 'ROICenters']);
                b=evalin('base',[typeString 'ROIBoundaries']);
                if numel(c) ~= 0
                    plotRange=1:numel(c);
                    allCount=numel(c);

                    for n=1:allCount
                        roiCounter=roiCounter+1;
                        roisList{roiCounter}=[typeString '_' num2str(n)];
                    end

                    cVal=get(handles.roiSelector,'Value');
                    set(handles.roiSelector, 'String', '');
                    set(handles.roiSelector,'String',roisList);
                    if cVal~=1
                        set(handles.roiSelector,'Value',cVal)
                    else
                        set(handles.roiSelector,'Value',1)
                    end


                    % Plot
                    if strcmp(get(handles.colormapTextEntry,'String'),'jet')
                        outColor='k';
                        txtColor=[0 0 0];
                    else
                        outColor=allColors{whoIsOn(rI)};
                        txtColor=allColors{whoIsOn(rI)};
                    end

                    hold all
                    for n=1:numel(plotRange)            
                        for k=1:numel(c{1,n})
                            plot(b{1,n}{k,1}(:,2),b{1,n}{k,1}(:,1),'Color',...
                                outColor,'LineWidth',2)
                            if useTxtLabels
                                text(c{1,n}(k).Centroid(1)-1, c{1,n}(k).Centroid(2),...
                                    num2str(plotRange(n)),'FontSize',10,'FontWeight','Bold','Color',txtColor);
                            else
                            end
                        end
                    end
                    hold off
                else
                end
            else
            end
        end
        refreshVarListButton_Callback(hObject, eventdata, handles);
        guidata(hObject, handles);
    % else
    % end

function roiSelection(hObject,eventdata,handles)

    cI=evalin('base','metaData.currentImage');
    axes(handles.imageWindow)
    loadMeanProjection(hObject,eventdata,handles,cI);
   
    [allTypes,allColors]=returnAllTypes(hObject,eventdata,handles);

    for n=1:numel(allTypes)
        whoIsOn(n)=eval(['get(handles.' allTypes{n} 'RoisDisplayToggle, ''Value'');']);
    end

    whoIsOn=find(whoIsOn==1);

    if numel(whoIsOn)==0
        set(handles.roiSelector,'String','');
    else
    end

    roiCounter=0;
    lastTypeNumber=0;
    for rI=1:numel(whoIsOn)
        typeString=allTypes{whoIsOn(rI)};
        g=evalin('base',['exist(''' typeString 'RoiCounter'');']);
        if g==1
            if numel(indRange)==0
                c=evalin('base',[typeString 'ROICenters']);
                b=evalin('base',[typeString 'ROIBoundaries']);
                plotRange=1:numel(c);
                allCount=numel(c);
            else
                plotRange=indRange;
                
            end

            c=evalin('base',[typeString 'ROICenters([' num2str(plotRange) '])']);
            b=evalin('base',[typeString 'ROIBoundaries([' num2str(plotRange) '])']);
            

            % Populate the box:
            if justUpdate==0
                for n=1:allCount                    
                    roisList{n}=[typeString '_' num2str(n)];
                end

                set(handles.roiSelector, 'String', '');
                set(handles.roiSelector,'String',roisList);
                set(handles.roiSelector,'Value',plotRange(end))
            else
            end

            % Plot
            if strcmp(get(handles.colormapTextEntry,'String'),'jet')
                outColor='k';
                txtColor=[0 0 0];
            else
                outColor=allColors{whoIsOn(rI)};
                txtColor=allColors{whoIsOn(rI)};
            end

            hold all
            for n=1:numel(plotRange)
                
                for k=1:numel(c{1,n})
                    plot(b{1,n}{k,1}(:,2),b{1,n}{k,1}(:,1),'Color',...
                        outColor,'LineWidth',2)
                    if useTxtLabels
                        text(c{1,n}(k).Centroid(1)-1, c{1,n}(k).Centroid(2),...
                            num2str(plotRange(n)),'FontSize',10,'FontWeight','Bold','Color',txtColor);
                    else
                    end
                end
            end

            hold off
        else
        end
    end

        
    refreshVarListButton_Callback(hObject, eventdata, handles);
    guidata(hObject, handles);

function somaticRoisDisplayToggle_Callback(hObject, eventdata, handles)

    % cState=get(handles.somaticRoisDisplayToggle,'Value');
    roisDisplayToggle(hObject, eventdata, handles)

function redSomaticRoisDisplayToggle_Callback(hObject, eventdata, handles)
    
    roisDisplayToggle(hObject, eventdata, handles)

function dendriticRoisDisplayToggle_Callback(hObject, eventdata, handles)
    
    roisDisplayToggle(hObject, eventdata, handles)

function axonalRoisDisplayToggle_Callback(hObject, eventdata, handles)
    
    roisDisplayToggle(hObject, eventdata, handles)

function boutonRoisDisplayToggle_Callback(hObject, eventdata, handles)
    
    roisDisplayToggle(hObject, eventdata, handles)

function neuropilRoisDisplayToggle_Callback(hObject, eventdata, handles)
    
    roisDisplayToggle(hObject, eventdata, handles)

function vesselRoisDisplayToggle_Callback(hObject, eventdata, handles)
    
    roisDisplayToggle(hObject, eventdata, handles)

function lowCutSlider_Callback(hObject, eventdata, handles)

    sliderValue = get(handles.lowCutSlider,'Value');
    highSet = get(handles.highCutSlider,'Value');
    if sliderValue>=highSet
        sliderValue=highSet-0.1;
    else
    end
    set(handles.lowCutEntry,'String', num2str(sliderValue));
    guidata(hObject, handles); 

    loadMeanProjectionButton_Callback(hObject,eventdata, handles);

function lowCutSlider_CreateFcn(hObject, eventdata, handles)

    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end

function highCutSlider_Callback(hObject, eventdata, handles)

    sliderValue = get(handles.highCutSlider,'Value');
    lowSet = get(handles.lowCutSlider,'Value');
    if sliderValue<=lowSet
        sliderValue=lowSet+0.1;
    else
    end
    set(handles.highCutEntry,'String', num2str(sliderValue));
    guidata(hObject, handles);

    loadMeanProjectionButton_Callback(hObject,eventdata, handles);

function highCutSlider_CreateFcn(hObject, eventdata, handles)

    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end

function lowCutEntry_Callback(hObject, eventdata, handles)

    input = str2num(get(hObject,'String'));
    highSet = str2num(get(handles.highCutEntry,'String'));
    if input>=highSet
        input=highSet-0.1;
    else
    end

    %checks to see if input is empty. if so, default input1_editText to zero
    if (isempty(input))
         set(hObject,'String','0')
    end


    set(handles.lowCutSlider,'Value',input);
    guidata(hObject, handles);
    lowCutSlider_Callback(hObject, eventdata, handles)

function lowCutEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function highCutEntry_Callback(hObject, eventdata, handles)

    input = str2num(get(hObject,'String'));
    lowSet = str2num(get(handles.lowCutEntry,'String'));
    if input<=lowSet
        input=lowSet+0.1;
    else
    end

    %checks to see if input is empty. if so, default input1_editText to zero
    if (isempty(input))
         set(hObject,'String','1')
    end

    set(handles.highCutSlider,'Value',input);
    guidata(hObject, handles);
    highCutSlider_Callback(hObject, eventdata, handles)

function highCutEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function makeNeuropilMasks_Callback(hObject, eventdata, handles)


    % Handle Neuropil ROIs

    % because our somas can be irregular we need to smooth the boundaries.

    % parameters
    tempImage=evalin('base','somaticROIs{1,1}');
    sR=evalin('base','somaticROIs');


    npSpredPx = str2double(get(handles.neuropilPixelSpreadEntry,'String'));
    somaClosePx=10;
    somaBoundaryPx=6; %todo: should be entered by user.


    % todo: a possible error case if an image has fewer than 30 pixels.

    smoothSomasMask=zeros(size(tempImage)); % this will be an all containing mask we use to exclude from neuropils.
    smoothNeuropilsMask=zeros(size(tempImage)); 

    neuropilRoiCounter=0;
    % First make an array of individual smoothed somatic rois and build on the all inclusive image.
    for n=1:numel(sR)
        neuropilROIs{1,n}=imdilate(imclose(sR{1,n},strel('disk',somaClosePx)),strel('disk',somaBoundaryPx));
        smoothSomasMask=smoothSomasMask+neuropilROIs{1,n};
        neuropilRoiCounter=neuropilRoiCounter+1;
    end

    % normalize because after dialting each cell there will be more overlap.
    smoothSomasMask=smoothSomasMask>0;
    assignin('base','flatMasks_smoothSomas',smoothSomasMask)


    for n=1:neuropilRoiCounter
        neuropilROIs{1,n}=imdilate(neuropilROIs{1,n},strel('disk',npSpredPx));
        % Find and Subtract Overlap Between a Particular Neuropil Mask and ROI mask
        neuropilROIs{1,n}=neuropilROIs{1,n}-smoothSomasMask;
        % this will give 0's where there is overlap, 1's were there is none and -1 where there was no difference
        neuropilROIs{1,n}=neuropilROIs{1,n}>0;
        smoothNeuropilsMask=smoothNeuropilsMask+neuropilROIs{1,n};
        neuropilROIBoundaries{1,n}=bwboundaries(neuropilROIs{1,n});
        neuropilROICenters{1,n}=regionprops(neuropilROIs{1,n},'Centroid');
        neuropilROI_PixelLists{1,n}=regionprops(neuropilROIs{1,n},'PixelList');
    %     neuropilROI_PixelLists{1,n}=neuropilROI_PixelLists{1,n}.PixelList;
    end

    smoothNeuropilsMask=smoothNeuropilsMask>0;
    assignin('base','flatMasks_neuropilRings',smoothNeuropilsMask)


    assignin('base','neuropilROIs',neuropilROIs)
    assignin('base','neuropilROI_PixelLists',neuropilROI_PixelLists)
    assignin('base','neuropilROIBoundaries',neuropilROIBoundaries)
    assignin('base','neuropilRoiCounter',neuropilRoiCounter)
    assignin('base','neuropilROICenters',neuropilROICenters)

    set(handles.neuropilAlertString,'String','finished making neuropil masks','ForegroundColor',[0 0 0]);
    disp('neuropil masks made')


    % Update handles structure
    guidata(hObject, handles);

function neuropilPixelSpreadEntry_Callback(hObject, eventdata, handles)

    guidata(hObject, handles);

function neuropilPixelSpreadEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function workspaceVarBox_Callback(hObject, eventdata, handles)

function workspaceVarBox_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function refreshVarListButton_Callback(hObject, eventdata, handles)

    vars = evalin('base','who');
    set(handles.workspaceVarBox,'String',vars);

    % Update handles structure
    guidata(hObject, handles);

function meanProjectButton_Callback(hObject, eventdata, handles)

    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    for n=1:numel(selectionsIndex)
        s=evalin('base',selections{selectionsIndex(n)});
        mP=mean(s,3);
        if class(s)=='uint16'
            assignin('base',['meanProj_' selections{selectionsIndex(n)}],im2uint16(mP,'Indexed'));
        else
            assignin('base',['meanProj_' selections{selectionsIndex(n)}],mP);
        end
    end
    vars = evalin('base','who');
    set(handles.workspaceVarBox,'String',vars)
    


    % Update handles structure
    guidata(hObject, handles);

function stdevProjectionButton_Callback(hObject, eventdata, handles)


    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    for n=1:numel(selectionsIndex)
        s=evalin('base',selections{selectionsIndex(n)});
        mP=std(double(s),1,3);
        assignin('base',['stdevProj_' selections{selectionsIndex(n)}],mP);
    end
    vars = evalin('base','who');
    set(handles.workspaceVarBox,'String',vars)
        
    guidata(hObject, handles);

function maxProjectionButton_Callback(hObject, eventdata, handles)

    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    for n=1:numel(selectionsIndex)
        s=evalin('base',selections{selectionsIndex(n)});
        mP=max(s,[],3);
        assignin('base',['maxProj_' selections{selectionsIndex(n)}],mP);
    end
    vars = evalin('base','who');
    set(handles.workspaceVarBox,'String',vars)
        
    guidata(hObject, handles);

function getGXcorButton_Callback(hObject, eventdata, handles)

    % Poll Params
    filterState=get(handles.gXCorSmoothToggle,'Value');
    imsToCor=str2num(get(handles.gXCorImageCountEntry,'String'));

    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    selectStack=selections{selectionsIndex};

    numImages=evalin('base',['size(' selectStack ',3)']);

        
    sstack= [];
    c=0;
    ff=fspecial('gaussian',11,0.5);

    nstack=min(imsToCor,numImages);

    for n=1:nstack
        c=c+1;
        
        if (rem(n,100)==0)
            set(handles.feedbackString,'String',['finished ' num2str(n)...
                ' of ' num2str(numImages) ' | ' num2str(round(100*(n./nstack))) '% done'])
            pause(0.0000001);
            guidata(hObject, handles);
    %         fprintf('%d/%d (%d%%)\n',n,numImages,round(100*(n./nstack)));
        end

        fnum=n;
        evalStr=['double(' selectStack '(:,:,' num2str(n) '))'];
        I=evalin('base',evalStr);
        I=conv2(double(I),ff,'same');
        sstack(:,:,n)=I;
    end
    assignin('base','sstack',sstack);

    % make local Xcorr and/or PCA
    % global xcor image code ----> adapted from http://labrigger.com/blog/2013/06/13/local-cross-corr-images/
    % local xcor region growing Jakob Voigts

    set(handles.feedbackString,'String','computing local xcorr')
    pause(0.000001);
    guidata(hObject, handles);

    w=1; % window size

    % Initialize and set up parameters
    ymax=size(sstack,1);
    xmax=size(sstack,2);
    numFrames=size(sstack,3);
    ccimage=zeros(ymax,xmax);

    for y=1+w:ymax-w
        
        if (rem(y,20)==0)
            set(handles.feedbackString,'String',['finished ' num2str(y)...
                ' of ' num2str(ymax) ' | ' num2str(round(100*(y./ymax))) '% done'])
            pause(0.0000001);
            guidata(hObject, handles);
    %         fprintf('%d/%d (%d%%)\n',y,ymax,round(100*(y./ymax)));
        end
        
        for x=1+w:xmax-w
            % Center pixel
            thing1 = reshape(sstack(y,x,:)-mean(sstack(y,x,:),3),[1 1 numFrames]); 
            % Extract center pixel's time course and subtract its mean
            ad_a   = sum(thing1.*thing1,3);    % Auto corr, for normalization laterdf
            
            % Neighborhood
            a = sstack(y-w:y+w,x-w:x+w,:);         % Extract the neighborhood
            b = mean(sstack(y-w:y+w,x-w:x+w,:),3); % Get its mean
            thing2 = bsxfun(@minus,a,b);       % Subtract its mean
            ad_b = sum(thing2.*thing2,3);      % Auto corr, for normalization later
            
            % Cross corr
            ccs = sum(bsxfun(@times,thing1,thing2),3)./sqrt(bsxfun(@times,ad_a,ad_b));
            % Cross corr with normalization
            ccs((numel(ccs)+1)/2) = [];        % Delete the middle point
            ccimage(y,x) = mean(ccs(:));       % Get the mean cross corr of the local neighborhood
        end
    end

    m=mean(ccimage(:));
    ccimage(1,:)=m;
    ccimage(end,:)=m;
    ccimage(:,1)=m;
    ccimage(:,end)=m;


    assignin('base',['ccimage_' selectStack],ccimage);
    assignin('base','ccimage',ccimage);
    set(handles.feedbackString,'String','! done with xcor')
    pause(0.00001);
    guidata(hObject, handles);
    vars = evalin('base','who');
    set(handles.workspaceVarBox,'String',vars)

    % ---- end xcor image code


    % Update handles structure
    guidata(hObject, handles);

function gXCorImageCountEntry_Callback(hObject, eventdata, handles)

function gXCorImageCountEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function gXCorSmoothToggle_Callback(hObject, eventdata, handles)

function playStackMovButton_Callback(hObject, eventdata, handles)
    % main play
    playState=1;
    assignin('base','playState',playState)

    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    playStack=double(evalin('base',[selections{selectionsIndex}]));
    size(playStack)
    if size(playStack,3)>1 & size(playStack,4)<=1
        playRGB=0;
    elseif size(playStack,3)>1 & size(playStack,4)>1
        playRGB=1;
    else
    end


    if size(playStack,3)>1 && playRGB==0
        % This helps you start from where you left off.
        startFrame=str2num(get(handles.frameTextEntry,'String'));
        if startFrame==size(playStack,3)
            startFrame=1;
        else
        end

    elseif size(playStack,4)>1 && playRGB==1
        startFrame=str2num(get(handles.frameTextEntry,'String')); 
        if startFrame==size(playStack,4)
            startFrame=1;
        else
        end
    end


    sliderMin = 1;
    if playRGB==0
        sliderMax = fix(size(playStack,3)); % this is variable
    elseif playRGB==1
        sliderMax = fix(size(playStack,4)); % this is variable
    end
    sliderStep = [1, 1] / (sliderMax - sliderMin); % major and minor steps of 1

    set(handles.frameSlider, 'Min', sliderMin);
    set(handles.frameSlider, 'Max', sliderMax);
    set(handles.frameSlider, 'SliderStep', sliderStep);
    set(handles.frameSlider, 'Value', startFrame); % set to beginning of sequence

    % check if they want to overlay a mask
    pMO=get(handles.overlayIndRoiToggle,'Value');
    % override if there is no mask
    mE=evalin('base','exist(''cMask'')');
    if mE==0
        pMO=0;
    else
    end

    if pMO
        cMask=evalin('base','cMask');
    else
        cMask=1;
    end

    axes(handles.imageWindow);

    sL=get(handles.colormapTextEntry,'String');
    sV=get(handles.colormapTextEntry,'Value');
    cMap=sL{sV};


    mfactor=0.3;

    a = get(handles.lowCutEntry,'String');
    b = get(handles.highCutEntry,'String');
    lowCut=str2double(a);
    highCut=str2double(b);

    if playRGB==0
    ii=1;
        for i=startFrame:size(playStack,3)
            pS=evalin('base','playState');
            if pS==1
                ii=(ii.*(1-mfactor))+playStack(:,:,i).*mfactor;
                ii=ii.*cMask;
                set(handles.frameTextEntry,'String',num2str(fix(i)));
                set(handles.frameSlider, 'Value', i);
                h=imshow(ii,'DisplayRange',[lowCut highCut]);
                colormap(gca,cMap);
                daspect([1 1 1])
                drawnow;
                delete(h);
            elseif pS==0
                set(handles.frameTextEntry,'String',num2str(fix(i)));
                set(handles.frameSlider, 'Value', fix(i));
                guidata(hObject, handles);
                ii=(ii.*(1-mfactor))+playStack(:,:,i).*mfactor;
                ii=ii.*cMask;
                imshow(ii,'DisplayRange',[lowCut highCut]);
                colormap(gca,cMap);
                daspect([1 1 1])
                axes(handles.imageWindow);
                assignin('base','currentImage',ii)
                break
            end  
        end    

    mfactor=1;
    elseif playRGB==1
        ii=1;
        for i=startFrame:size(playStack,4)
            pS=evalin('base','playState');
            if pS==1
                ii=(ii.*(1-mfactor))+playStack(:,:,:,i).*mfactor;
                ii=ii.*cMask;
    %             set(handles.frameTextEntry,'String',num2str(i));
    %             set(handles.frameSlider, 'Value', i);
                h=imshow(ii);
    %             colormap(gca,cMap);
                daspect([1 1 1])
                drawnow;
                delete(h);
            elseif pS==0
                set(handles.frameTextEntry,'String',num2str(fix(i)));
                set(handles.frameSlider, 'Value', fix(i));
                guidata(hObject, handles);
                ii=(ii.*(1-mfactor))+playStack(:,:,:,i).*mfactor;
                ii=ii.*cMask;
                imshow(ii);
    %             colormap(gca,cMap);
                daspect([1 1 1])
                axes(handles.imageWindow);
                assignin('base','currentImage',ii)
                break
            end  
        end   

    end
    % Update handles structure
    guidata(hObject, handles);

function pasueMovieButton_Callback(hObject, eventdata, handles)

    playState=0;
    assignin('base','playState',playState)

function localXCorButton_Callback(hObject, eventdata, handles)

    I=evalin('base','ccimage');
    sstack=evalin('base','sstack');

    [x,y]=ginput(1);
    %iterative region growing
    ref= (squeeze(sstack(ceil(y),ceil(x),:) ));

    xc=I.*0;
    xc(ceil(y),ceil(x))=0.9; % seed

    it=1;
        while it<50
            sig=find(xc>0.04);
            mask=I.*0; mask(sig)=1;
            mask=conv2(mask,ones(5),'same')>0;
            update=find((xc==0).*(mask==1));
            if numel(update)<1
                it=500;
            end
            for fillin=update'
                [a,b]=ind2sub(size(I),fillin);
                c=corrcoef(squeeze(sstack(a,b,:)),ref);
                xc(a,b)=c(2,1);
            end
            it=it+1;
        end

    localCorMaskPlot=(1-mask).*I./10+ ((xc*1));
    imagesc(localCorMaskPlot),axis off
    colormap jet
    currentImage=localCorMaskPlot;
    assignin('base','currentImage',double(localCorMaskPlot))
    daspect([1 1 1]);

    axes(handles.cdfWindow);
    cdfplot(reshape(localCorMaskPlot,numel(I),1))

    roiTh=str2num(get(handles.roiThresholdEntry,'String'));
    axes(handles.roiPreviewWindow);
    imagesc(im2bw(currentImage,roiTh),[0 2]),colormap jet
    assignin('base','candidateRoi',im2bw(currentImage,roiTh))
    assignin('base','candidateRoi_rawVals',currentImage)
    evalin('base','scratch.candidateRoi=candidateRoi;')
    evalin('base','scratch.candidateRoi_rawVals=candidateRoi_rawVals;')


    % % Update handles structure
    % guidata(hObject, handles);
    roisDisplayToggle(hObject, eventdata, handles,1)
    refreshVarListButton_Callback(hObject, eventdata, handles);
    guidata(hObject, handles);

function roiThresholdEntry_Callback(hObject, eventdata, handles)


    % Hints: get(hObject,'String') returns contents of roiThresholdEntry as text
    %        str2double(get(hObject,'String')) returns contents of roiThresholdEntry as a double
    prevAt=evalin('base','exist(''scratch'',''var'')');
    if prevAt
        currentROI=evalin('base','scratch.candidateRoi_rawVals');
        roiTh=str2num(get(handles.roiThresholdEntry,'String'));
        axes(handles.roiPreviewWindow);
        imagesc(im2bw(currentROI,roiTh),[0 2]),colormap('jet')
        assignin('base','candidateRoi',im2bw(currentROI,roiTh))
        assignin('base','candidateRoi_rawVals',currentROI)
        evalin('base','scratch.candidateRoi=candidateRoi;')
        evalin('base','scratch.candidateRoi_rawVals=candidateRoi_rawVals;')
    end


    refreshVarListButton_Callback(hObject, eventdata, handles);
    guidata(hObject, handles);

function roiThresholdEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function pcaButton_Callback(hObject, eventdata, handles)

    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');

    imsToCor=str2num(get(handles.gXCorImageCountEntry,'String'));
    stack=evalin('base',[selections{selectionsIndex}]);
    pcaimage=evalin('base','ccimage');

    set(handles.feedbackString,'String','computing PCA ROI estimate')
    pause(0.00001);
    guidata(hObject, handles);

    stack_v=zeros(imsToCor,size(stack,1)*size(stack,2));
    for i=1:imsToCor
        x=stack(:,:,i);
        stack_v(i,:)=x(:);
    end
    stack_v=stack_v-mean(stack_v(:));
    [coeff, score] = pca(stack_v,'Economy','on','NumComponents',100);
    imcomponents=reshape(coeff',100,size(stack,1),size(stack,2));
    pcaimage=(squeeze(mean(abs(imcomponents(:,:,:)))));

    assignin('base','pcaimage',pcaimage./max(max(pcaimage)))

    set(handles.feedbackString,'String','done with PCA')
    pause(0.00001);





    guidata(hObject, handles);
    refreshVarListButton_Callback(hObject, eventdata, handles)
    % Update handles structure
    guidata(hObject, handles);

function colormapTextEntry_Callback(hObject, eventdata, handles)

    loadMeanProjectionButton_Callback(hObject, eventdata, handles)

function colormapTextEntry_CreateFcn(hObject, eventdata, handles)
    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function frameSlider_Callback(hObject, eventdata, handles)
    % fix and ceil are unreliable here. 
    sliderValue = get(handles.frameSlider,'Value');    
    set(handles.frameTextEntry,'String', num2str(sliderValue));
    trackFrame(hObject, eventdata, handles);
    guidata(hObject, handles);
    loadMeanProjectionButton_Callback(hObject,eventdata, handles);

function frameSlider_CreateFcn(hObject, eventdata, handles)

    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end

function frameTextEntry_Callback(hObject, eventdata, handles)

    trackFrame(hObject, eventdata, handles);
    loadMeanProjectionButton_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);

function frameTextEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function addToSomasButton_Callback(hObject, eventdata, handles)

    g=evalin('base','exist(''somaticRoiCounter'')');
    if g==1
        h=evalin('base','somaticRoiCounter');
        r=evalin('base','somaticROIs');
        c=evalin('base','somaticROICenters');
        b=evalin('base','somaticROIBoundaries');
        pl=evalin('base','somaticROI_PixelLists');
        
        h=h+1;
        mask=evalin('base','scratch.candidateRoi');
       
        
        
        r{h}=mask;
        b{h}=bwboundaries(mask);
        c{h}=regionprops(mask,'Centroid');
        pl{h}=regionprops(mask,'PixelList');
        
        
        assignin('base','somaticROIs',r)
        assignin('base','somaticROICenters',c)
        assignin('base','somaticROIBoundaries',b)
        assignin('base','somaticRoiCounter',h)
        assignin('base','somaticROI_PixelLists',pl)
        
    else
        h=1;
        mask=evalin('base','scratch.candidateRoi');
        assignin('base','somaticROIs',{mask})
        assignin('base','somaticROICenters',{regionprops(mask,'Centroid')})
        assignin('base','somaticROI_PixelLists',{regionprops(mask,'PixelList')})
        assignin('base','somaticROIBoundaries',{bwboundaries(mask)})
        assignin('base','somaticRoiCounter',h)
    end

    loadMeanProjectionButton_Callback(hObject, eventdata, handles)

    guidata(hObject, handles);

function addToDendritesButton_Callback(hObject, eventdata, handles)

    g=evalin('base','exist(''dendriticRoiCounter'')');
    if g==1
        h=evalin('base','dendriticRoiCounter');
        r=evalin('base','dendriticROIs');
        c=evalin('base','dendriticROICenters');
        b=evalin('base','dendriticROIBoundaries');
        pl=evalin('base','dendriticROI_PixelLists');
        
        h=h+1;
        mask=evalin('base','scratch.candidateRoi');
       
        
        
        r{h}=mask;
        b{h}=bwboundaries(mask);
        c{h}=regionprops(mask,'Centroid');
        pl{h}=regionprops(mask,'PixelList');
        
        
        assignin('base','dendriticROIs',r)
        assignin('base','dendriticROICenters',c)
        assignin('base','dendriticROIBoundaries',b)
        assignin('base','dendriticRoiCounter',h)
        assignin('base','dendriticROI_PixelLists',pl)
        
    else
        h=1;
        mask=evalin('base','scratch.candidateRoi');
        assignin('base','dendriticROIs',{mask})
        assignin('base','dendriticROICenters',{regionprops(mask,'Centroid')})
        assignin('base','dendriticROI_PixelLists',{regionprops(mask,'PixelList')})
        assignin('base','dendriticROIBoundaries',{bwboundaries(mask)})
        assignin('base','dendriticRoiCounter',h)
    end

    loadMeanProjectionButton_Callback(hObject, eventdata, handles)

    % Update handles structure
    guidata(hObject, handles);

function addToBoutonsButton_Callback(hObject, eventdata, handles)

    g=evalin('base','exist(''boutonRoiCounter'')');
    if g==1
        h=evalin('base','boutonRoiCounter');
        r=evalin('base','boutonROIs');
        c=evalin('base','boutonROICenters');
        b=evalin('base','boutonROIBoundaries');
        pl=evalin('base','boutonROI_PixelLists');
        
        h=h+1;
        mask=evalin('base','scratch.candidateRoi');
       
        
        
        r{h}=mask;
        b{h}=bwboundaries(mask);
        c{h}=regionprops(mask,'Centroid');
        pl{h}=regionprops(mask,'PixelList');
        
        
        assignin('base','boutonROIs',r)
        assignin('base','boutonROICenters',c)
        assignin('base','boutonROIBoundaries',b)
        assignin('base','boutonRoiCounter',h)
        assignin('base','boutonROI_PixelLists',pl)
        
    else
        h=1;
        mask=evalin('base','scratch.candidateRoi');
        assignin('base','boutonROIs',{mask})
        assignin('base','boutonROICenters',{regionprops(mask,'Centroid')})
        assignin('base','boutonROI_PixelLists',{regionprops(mask,'PixelList')})
        assignin('base','boutonROIBoundaries',{bwboundaries(mask)})
        assignin('base','boutonRoiCounter',h)
    end

    loadMeanProjectionButton_Callback(hObject, eventdata, handles)

    % Update handles structure
    guidata(hObject, handles);

function nnmfButton_Callback(hObject, eventdata, handles)
    % performs non-negative matrix factorization with defaults
    % this is a 'feature' based PCA that only allows non-negative values.
    % assuming you have a matrix of features with magnitudes of 0->something
    % this is then ideal for finding the most variance predicting features that
    % correspond more to intuitive features than PCA.
    % see Lee and Seung, 1999 Nature for the first and very lucid description
    % of the method. NM1 are the image sized feature filters (masks) and NM2 is
    % the frame varying weights. Think of NM2 as your PCA'd proportional
    % variance, but varying in time. This tells you the realtive weight of your
    % feature at any momment in time!

    tic
    set(handles.feedbackString,'String','performing nnmf prediction')
    pause(0.0000000001);
    guidata(hObject, handles);

    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    tStack=double(evalin('base',selections{selectionsIndex}));
    s1=size(tStack,1);
    s2=size(tStack,2);

    % sSize=size(tStack,3);
    sSize=fix(str2double(get(handles.gXCorImageCountEntry,'String')));
    if sSize<size(tStack,3)
        tStack=tStack(:,:,1:sSize);
    else
        sSize=size(tStack,3);
    end

    fNum=fix(str2double(get(handles.featureCountEntry,'String')));

    if fNum>=sSize
        fNum=sSize-1;
    else
    end

    tStack=reshape(tStack,size(tStack,1)*size(tStack,2),size(tStack,3));

    size(tStack,1)
    size(tStack,2)
    size(tStack,3)

    [nm1,nm2,nm3]=nmf(tStack,fNum,'MAX_ITER',100);
    nm1=nm1./max(max(max(nm1)));

    nm1=reshape(nm1,s1,s2,fNum);
    clear tStack

    assignin('base','nm1',nm1);
    assignin('base','nm2',nm2);
    assignin('base','nm3',nm3);

    clear nm1 nm2 nm3

    nmTim=toc;
    set(handles.feedbackString,'String',['finished nnmf in ' num2str(nmTim) 'seconds'])
    pause(0.000000001);
    guidata(hObject, handles);
    refreshVarListButton_Callback(hObject, eventdata, handles)

function featureCountEntry_Callback(hObject, eventdata, handles)

function featureCountEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function medianFilterToggle_Callback(hObject, eventdata, handles)

    loadMeanProjectionButton_Callback(hObject, eventdata, handles)

function wienerFilterToggle_Callback(hObject, eventdata, handles)

    loadMeanProjectionButton_Callback(hObject, eventdata, handles)

function importerButton_Callback(hObject, eventdata, handles)

    evalin('base','importer')

function extractorButton_Callback(hObject, eventdata, handles)


    evalin('base','extractor')

function [curFrame]=trackFrame(hObject, eventdata, handles)
    curFrame=fix(str2double(get(handles.frameTextEntry,'String')));        
    assignin('base','currentFrame',curFrame)
    evalin('base','metaData.currentFrame=currentFrame;,clear ''currentFrame''');
    % debug

function cMaskToggle_Callback(hObject, eventdata, handles)
    
    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    selectedItem=selections{selectionsIndex};
    curFrame=get(handles.frameTextEntry,'String');
    
    try currentFrame=evalin('base','metaData.currentFrame');
    catch
        currentFrame=trackFrame(hObject, eventdata, handles);
    end
    
    set(handles.frameTextEntry,'String',num2str(currentFrame))
    guidata(hObject, handles);

    loadMeanProjectionButton_Callback(hObject,eventdata,handles)
    binaryThreshold=str2double(get(handles.binaryThrValEntry,'String'));
    axes(handles.imageWindow);
    a=gcf;
    cImage=a.CurrentAxes.Children(end).CData;
    cMask=imbinarize(cImage,binaryThreshold);
    assignin('base','cMask',cMask);
    evalin('base','metaData.currentMask=cMask;')
    
    loadMeanProjectionButton_Callback(hObject,eventdata,handles,cMask)
    
    refreshVarListButton_Callback(hObject, eventdata, handles);
    guidata(hObject, handles);

function curImageToMaskButton_Callback(hObject, eventdata, handles)


    axes(handles.roiPreviewWindow);
    tA=gca;
    cMask=tA.Children.CData;
    
    assignin('base','tcMask',cMask)
    evalin('base','metaData.currentMask=tcMask;');
    
    refreshVarListButton_Callback(hObject, eventdata, handles);
    guidata(hObject, handles);


function segmentMaskBtn_Callback(hObject, eventdata, handles)

    sR=evalin('base','metaData.currentMask');
    if strcmp(class(sR),'logical')
        set(handles.feedbackString,'String','');
        guidata(hObject, handles);
        imSize=[size(sR,1) size(sR,2)];
        minROISize=fix(str2double(get(handles.minRoiEntry,'String')));
        linThr=1;
        pROIs=bwboundaries(sR,'holes');
        pROIsizes=fix(cellfun(@numel,pROIs)/2);
        stROIs=find(pROIsizes>=minROISize);
        usedNum=numel(stROIs);
        linearROIs=[];

        goodCount=0;
        for n=1:usedNum
            tSegMask=zeros(imSize(1),imSize(2),1);
            tROI=pROIs{stROIs(n)};

            c1Mean=mean(abs(diff(tROI(:,1))));
            c2Mean=mean(abs(diff(tROI(:,2))));

            if c1Mean==linThr || c2Mean==linThr
                linearROIs=[linearROIs; n];
            else
                goodCount=goodCount+1;
                tROIs(:,:,goodCount)=roipoly(imSize(1),imSize(2),tROI(:,2),tROI(:,1));
                addROIsFromMask(hObject, eventdata, handles,tROIs(:,:,goodCount))
            end
        end

        refreshVarListButton_Callback(hObject, eventdata, handles);
        set(handles.feedbackString,'String',['segmented ' num2str(goodCount) ' rois'])   
        loadMeanProjectionButton_Callback(hObject, eventdata,handles,sR)

        try 
            curIm=evalin('base','metaData.currentFrame');
        catch
            curIm=1;
        end

        set(handles.frameTextEntry,'String',num2str(curIm+1))
        loadMeanProjectionButton_Callback(hObject, eventdata,handles)
        trackFrame(hObject, eventdata, handles);
        guidata(hObject, handles);
    else
        set(handles.feedbackString,'String','image is not a mask');
        guidata(hObject, handles);
    end

function autoMaskBtn_Callback(hObject, eventdata, handles)

    
    try 
        currentFrame=evalin('base','metaData.currentFrame');
    
    catch
        
        currentFrame=trackFrame(hObject, eventdata, handles);
    end
    
    set(handles.frameTextEntry,'String',num2str(currentFrame))
    guidata(hObject, handles);

    loadMeanProjectionButton_Callback(hObject,eventdata,handles)
    binaryThreshold=str2double(get(handles.binarySensEntry,'String'));
    axes(handles.imageWindow);
    a=gcf;
    cImage=a.CurrentAxes.Children(end).CData;
    cMask=imbinarize(cImage,'adaptive','sensitivity',binaryThreshold);
    assignin('base','cMask',cMask);
    evalin('base','metaData.currentMask=cMask; ')
    
    
    loadMeanProjectionButton_Callback(hObject,eventdata,handles,cMask)
    
    refreshVarListButton_Callback(hObject, eventdata, handles);
    guidata(hObject, handles);

function binarySensEntry_Callback(hObject, eventdata, handles)

    cMaskToggle_Callback(hObject, eventdata, handles)

function binarySensEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function minRoiEntry_Callback(hObject, eventdata, handles)

function minRoiEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function manROIBtn_Generic_Callback(hObject, eventdata, handles)

function roiTypeMenu_Callback(hObject, eventdata, handles)

function roiTypeMenu_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function deleteWSVar_Callback(hObject, eventdata, handles)

    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    selectedItem=selections{selectionsIndex};
    evalin('base',['clear ' selectedItem]);
    refreshVarListButton_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);

function binaryThrValEntry_Callback(hObject, eventdata, handles)

    cMaskToggle_Callback(hObject, eventdata, handles)

function binaryThrValEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function cutByBtn_Callback(hObject, eventdata, handles)

    cImage=double(evalin('base','currentImage'));
    eString=get(handles.imageCutEntry,'String');
    preMin=min(min(nonzeros(cImage)));
    preMax=max(max(nonzeros(cImage)));
    
    eval(['cImage(find(cImage ' eString '))=0']);
    newMin=min(min(nonzeros(cImage)))
    newMax=max(max(nonzeros(cImage)))
    cImage=remap(cImage,[preMin preMax],[newMin newMax]);
    assignin('base','currentImage',cImage);
    evalin('base','metaData.currentImage=currentImage;');
    loadMeanProjectionButton_Callback(hObject,eventdata,handles,cImage);

function imageCutEntry_Callback(hObject, eventdata, handles)

    cutByBtn_Callback(hObject, eventdata, handles)

function imageCutEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function deDupeRoisBtn_Callback(hObject, eventdata, handles)

    % get pixel counts per roi
    % kill small ones

    sL=get(handles.roiTypeMenu,'String');
    sV=get(handles.roiTypeMenu,'Value');
    roiTypeSelected=sL{sV};
    assignin('base','roiSelectString',roiTypeSelected)

    r=evalin('base',[roiTypeSelected 'ROIs']);
    c=evalin('base',[roiTypeSelected 'ROICenters']);
    b=evalin('base',[roiTypeSelected 'ROIBoundaries']);
    pl=evalin('base',[roiTypeSelected 'ROI_PixelLists']);

    numIt=0;
    posNums=nchoosek(numel(r),2);
    pCount=cellfun(@numel,cellfun(@(x) find(x==1),r,'UniformOutput',0));

    for n=1:(numel(r)-1)
        for j=n+1:numel(r)
            numIt=numIt+1;
            ovPixels{1,numIt}=find((r{n}+r{j})==2);
            numOvPixels(numIt)=numel(ovPixels{1,numIt});
            totalPixelsInPair(numIt)=pCount(n)+pCount(j);
            pairIDs(:,numIt)=[n,j];
            pixSizePairs(:,numIt)=[pCount(n),pCount(j)];
        end
    end


    propOverlap=numOvPixels./totalPixelsInPair;
    thrOverlap=find(propOverlap>0.01);
    overlapingPairs=pairIDs(:,thrOverlap);
    overlapingPairsSizes=pixSizePairs(:,thrOverlap);
    [~,kl]=min(overlapingPairsSizes);

    try 
        for n=1:numel(kl)
            toKill=overlapingPairs(kl(n),:);
        end
        toKill=unique(toKill);
    catch
        toKill=[];
    end

    %%
    deleteROI(toKill,repmat({roiTypeSelected},1,numel(toKill)));
    disp(['deleted ' num2str(numel(toKill)) ' potential dupes'])
    roisDisplayToggle(hObject,eventdata,handles)

function somaButton_KeyPressFcn(hObject, eventdata, handles)
    if get(gcf,'currentcharacter') == 'h'
    
    else
    end

function clusterMaskBtn_Callback(hObject, eventdata, handles)
    ccimage=evalin('base','ccimage');
    stImg=ccimage-mean2(ccimage);
    stImgThr=0.19;

    imLn=size(stImg,1);
    imPx=size(stImg,2);

    thrMask=zeros(imLn,imPx);
    thrPX=find(stImg>stImgThr);

    for n=1:numel(thrPX)
        cline=ceil(thrPX(n)/imLn);
        cpixel=thrPX(n)-(imLn*(cline-1));
        thrMask(cpixel,cline)=1;
    end
    
    minROISize=4;
    pROIs=bwboundaries(thrMask,'holes');
    pROIsizes=fix(cellfun(@numel,pROIs)/2);
    
    szROIs=find(pROIsizes>=minROISize);
    usedNum=numel(szROIs);
    usedROIsizes=pROIsizes(szROIs);
    segMasks=zeros(imLn,imPx,usedNum);

    for n=1:usedNum
        tROI=pROIs{szROIs(n)};
        segMasks(:,:,n)=roipoly(imLn,imPx,tROI(:,2),tROI(:,1));
    end
    
    poolCounter=0;
    dataToClusterOn=ccimage-mean2(ccimage);
    
    for p=1:size(segMasks,3)
        mNum=p;
        ws=usedROIsizes(mNum);
        dataThrIDs=find(segMasks(:,:,mNum)==1);
        dataThrVals=dataToClusterOn(segMasks(:,:,mNum)==1);
        if numel(dataThrIDs)>1
            clear seg2Masks
            fMask=zeros(imLn,imPx);
            fMaskData=zeros(imLn,imPx);



            for n=1:numel(dataThrIDs)
                cline=ceil(dataThrIDs(n)/imLn);
                cpixel=dataThrIDs(n)-(imLn*(cline-1));
                fMaskData(cpixel,cline)=dataThrVals(n);
                fMask(cpixel,cline)=1;
            end



            mClust=ceil(ws/15);
            minROISize=3;

            clusData=clusterdata(fMaskData(fMask==1),'maxclust',mClust);
            clusPXs=find(fMask==1);

            cNum=numel(unique(clusData));
            clusMask=zeros(imLn,imPx);

            % kill small
            smallClusts=[];
            bigClusts=[];
            bigClustSize=[];
            smCnt=0;

            for n=1:cNum
                tC=find(clusData==n);
                if numel(tC)<minROISize
                    smCnt=smCnt+1;
                    smallClusts(smCnt)=n;
                else
                end
            end


            for n=1:numel(clusPXs)

                cline=ceil(clusPXs(n)/imLn);
                cpixel=clusPXs(n)-(imLn*(cline-1));
                if ismember(clusData(n),smallClusts)
                    clusMask(cpixel,cline)=0;
                else
                    clusMask(cpixel,cline)=1;
                end

            end


            minROISize2=2;
            pROIs=bwboundaries(clusMask,'holes','conn',8);
            pROIsizes=fix(cellfun(@numel,pROIs)/2);
            stROIs=find(pROIsizes>=minROISize2);
            usedNum=numel(stROIs);
        
            poolRois=zeros(imLn,imPx,usedNum);
            for n=1:usedNum
                tempROIMask=zeros(imLn,imPx);
                tROI=pROIs{stROIs(n)};
                for k=1:fix(numel(tROI)/2)
                    tempROIMask(tROI(k,1),tROI(k,2))=1; 
                end
                poolRois(:,:,n)=imfill(tempROIMask);
            end
        
            for k=1:size(poolRois,3)
%                 poolCounter=poolCounter+1;
%                 poolClusMasks(:,:,poolCounter)=poolRois(:,:,k);
                addROIsFromMask(hObject, eventdata, handles,poolRois(:,:,k));
            end
            clear poolRois
                
        else
        end
    end
    
refreshVarListButton_Callback(hObject, eventdata, handles)
guidata(hObject, handles);

    
function maxClusterEntry_Callback(hObject, eventdata, handles)
    

% **************************************************************
% **************** Junkyard ************************************
% **************************************************************

function maxClusterEntry_CreateFcn(hObject, eventdata, handles)


    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
