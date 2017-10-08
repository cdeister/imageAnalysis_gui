function varargout = roiMaker(varargin)
% ROIMAKER 
% 
% roiMaker is a simple gui and set of processes for making various ROIs in
% imaging data. 
%
% No Documentation (yet)
%
% Most Code: Chris Deister & Jakob Voigts
% Global XCorr Segmentation Idea: Stephan Junek et al., 2009, Spencer Smith
%
% Questions: cdeister@brown.edu
% 
% Last Modified by GUIDE v2.5 07-Oct-2017 23:39:08

% Begin initialization code - DO NOT EDIT
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
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to roiMaker (see VARARGIN)

% Choose default command line output for roiMaker
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

% UIWAIT makes roiMaker wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function varargout = roiMaker_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function [returnTypeStrings,typeAllColor]=returnAllTypes(hObject,eventdata,handles)
% set all known ROI types here
returnTypeStrings={'somatic','redSomatic','dendritic','axonal','bouton','vessel','neuropil'};
typeAllColor={[0,0.8,0.3],[1,0,0],[0,0,1],[1,0,1],[1,1,0],[0.7,0.3,0],[0.4,0.4,0.4]};

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

eval([typeString 'RoisDisplayToggle_Callback(handles.somaticRoisDisplayToggle,eventdata,handles)'])
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


function selected=checkROISelections(hObject, eventdata, handles)
sTr=get(handles.somaticRoisDisplayToggle, 'Value');
rSTr=get(handles.redSomaticRoisDisplayToggle, 'Value');
dTr=get(handles.dendriticRoisDisplayToggle, 'Value');
aTr=get(handles.axonalRoisDisplayToggle, 'Value');
bTr=get(handles.boutonRoisDisplayToggle, 'Value');
vTr=get(handles.vesselRoisDisplayToggle, 'Value');
nTr=get(handles.neuropilRoisDisplayToggle, 'Value');
selected=[sTr rSTr dTr aTr bTr vTr nTr]; 


function [wsObj wsClass]=getWSVar(hObject, eventdata, handles)
selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
wsObj=evalin('base',selections{selectionsIndex});
wsClass=class(wsObj);

% --- Executes during object creation, after setting all properties.
function roiSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roiSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in loadMeanProjectionButton.
function loadMeanProjectionButton_Callback(hObject, eventdata,handles,defImage)
% main load image


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
      % Update handles structure
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
      % Update handles structure
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
    imageP=imageP(:,:,stackInd);

    sliderMin = 1;
    sliderMax = stackNum; % this is variable
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


assignin('base','currentImage',imageP)
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

axes(handles.imageWindow);

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


h=evalin('base',[typeString 'RoiCounter']);
r=evalin('base',[typeString 'ROIs']);
c=evalin('base',[typeString 'ROICenters']);
b=evalin('base',[typeString 'ROIBoundaries']);
pl=evalin('base',[typeString 'ROI_PixelLists']);

h=h-1;
r(roiNumber)=[];
c(roiNumber)=[];
b(roiNumber)=[];
pl(roiNumber)=[];

assignin('base',[typeString 'ROIs'],r)
assignin('base',[typeString 'ROICenters'],c)
assignin('base',[typeString 'ROIBoundaries'],b)
assignin('base',[typeString 'RoiCounter'],h)
assignin('base',[typeString 'ROI_PixelLists'],pl)

roisDisplayToggle(hObject, eventdata, handles,1)

% alert the user their neuropil masks will be out of sync.
g=evalin('base','exist(''neuropilRoiCounter'')');
if g 
    set(handles.neuropilAlertString,'String','regenerate neuropil masks -->','ForegroundColor',[1 0 0]);
else
    set(handles.neuropilAlertString,'ForegroundColor',[0 0 0]);
end

if roiNumber>1
    set(handles.roiSelector,'Value',roiNumber-1);
else
    set(handles.roiSelector,'Value',1);
end

roisDisplayToggle(hObject,eventdata,handles)
refreshVarListButton_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes on selection change in roiSelector.
function roiSelector_Callback(hObject, eventdata, handles)

boxNum=get(handles.roiSelector,'Value');
boxStrings=get(handles.roiSelector,'String');

if numel(boxNum)>0
specifiedString=boxStrings{boxNum};

stringSplit=strsplit(specifiedString,'_');

typeString=stringSplit{1};
roiNumber=fix(str2double(stringSplit{2}));

c=evalin('base',[typeString 'ROICenters']);
b=evalin('base',[typeString 'ROIBoundaries']);

axes(handles.imageWindow)
aa=evalin('base','currentImage');
loadMeanProjectionButton_Callback(hObject, eventdata, handles,aa)
roisDisplayToggle(hObject,eventdata,handles,1)

hold all
for n=roiNumber
    for k=1:numel(c{1,n})
        plot(b{1,n}{k,1}(:,2),b{1,n}{k,1}(:,1),'Color',...
            [0,0.1,0.2],'LineWidth',6)
        text(c{1,n}(k).Centroid(1)-1, c{1,n}(k).Centroid(2),...
            num2str(n),'FontSize',15,'FontWeight','Normal','Color',[0,0,0]);
    end
end
hold off
else
end

set(handles.roiSelector,'Value',boxNum);

refreshVarListButton_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

function roisDisplayToggle(hObject,eventdata,handles,justUpdate)

if nargin==3
    justUpdate=0;
else
end

if justUpdate==0
    loadMeanProjectionButton_Callback(hObject, eventdata, handles)
else
end
axes(handles.imageWindow)

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
for rI=1:numel(whoIsOn)

    typeString=allTypes{whoIsOn(rI)};
    g=evalin('base',['exist(''' typeString 'RoiCounter'');']);
    if g==1
        h=evalin('base',[typeString 'RoiCounter']);
    else
        h=0;
    end
    if h>0
        c=evalin('base',[typeString 'ROICenters']);
        b=evalin('base',[typeString 'ROIBoundaries']);

        % Populate the box:

        if justUpdate==0
            for n=1:h
                roiCounter=roiCounter+1;
                roisList{roiCounter}=[typeString '_' num2str(n)];
            end

            set(handles.roiSelector, 'String', '');
            set(handles.roiSelector,'String',roisList);
            set(handles.roiSelector,'Value',h)

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
        for n=1:numel(b)
            for k=1:numel(c{1,n})
                plot(b{1,n}{k,1}(:,2),b{1,n}{k,1}(:,1),'Color',...
                    outColor,'LineWidth',2)
                text(c{1,n}(k).Centroid(1)-1, c{1,n}(k).Centroid(2),...
                    num2str(n),'FontSize',10,'FontWeight','Bold','Color',txtColor);
            end
        end

        hold off
    else
    end
end

        
refreshVarListButton_Callback(hObject, eventdata, handles);
guidata(hObject, handles);


function somaticRoisDisplayToggle_Callback(hObject, eventdata, handles)
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


% --- Executes during object creation, after setting all properties.
function lowCutSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowCutSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
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

% --- Executes during object creation, after setting all properties.
function highCutSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to highCutSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
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


% --- Executes during object creation, after setting all properties.
function highCutEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to highCutEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in makeNeuropilMasks.
function makeNeuropilMasks_Callback(hObject, eventdata, handles)
% hObject    handle to makeNeuropilMasks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
% hObject    handle to neuropilPixelSpreadEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of neuropilPixelSpreadEntry as text
%        str2double(get(hObject,'String')) returns contents of neuropilPixelSpreadEntry as a double

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function neuropilPixelSpreadEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to neuropilPixelSpreadEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in workspaceVarBox.
function workspaceVarBox_Callback(hObject, eventdata, handles)
% hObject    handle to workspaceVarBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns workspaceVarBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from workspaceVarBox


% --- Executes during object creation, after setting all properties.
function workspaceVarBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to workspaceVarBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in refreshVarListButton.
function refreshVarListButton_Callback(hObject, eventdata, handles)
% hObject    handle to refreshVarListButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of refreshVarListButton

vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in meanProjectButton.
function meanProjectButton_Callback(hObject, eventdata, handles)
% hObject    handle to meanProjectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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



% --- Executes on button press in stdevProjectionButton.
function stdevProjectionButton_Callback(hObject, eventdata, handles)
% hObject    handle to stdevProjectionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
for n=1:numel(selectionsIndex)
    s=evalin('base',selections{selectionsIndex(n)});
    mP=std(double(s),1,3);
    assignin('base',['stdevProj_' selections{selectionsIndex(n)}],mP);
end
vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)
    


% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in maxProjectionButton.
function maxProjectionButton_Callback(hObject, eventdata, handles)
% hObject    handle to maxProjectionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
for n=1:numel(selectionsIndex)
    s=evalin('base',selections{selectionsIndex(n)});
    mP=max(s,[],3);
    assignin('base',['maxProj_' selections{selectionsIndex(n)}],mP);
end
vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)
    


% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in getGXcorButton.
function getGXcorButton_Callback(hObject, eventdata, handles)
% hObject    handle to getGXcorButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
        set(handles.feedbackString,'String',['finished ' num2str(n) ' of ' num2str(numImages) ' | ' num2str(round(100*(n./nstack))) '% done'])
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
        set(handles.feedbackString,'String',['finished ' num2str(y) ' of ' num2str(ymax) ' | ' num2str(round(100*(y./ymax))) '% done'])
        pause(0.0000001);
        guidata(hObject, handles);
%         fprintf('%d/%d (%d%%)\n',y,ymax,round(100*(y./ymax)));
    end
    
    for x=1+w:xmax-w
        % Center pixel
        thing1 = reshape(sstack(y,x,:)-mean(sstack(y,x,:),3),[1 1 numFrames]); % Extract center pixel's time course and subtract its mean
        ad_a   = sum(thing1.*thing1,3);    % Auto corr, for normalization laterdf
        
        % Neighborhood
        a = sstack(y-w:y+w,x-w:x+w,:);         % Extract the neighborhood
        b = mean(sstack(y-w:y+w,x-w:x+w,:),3); % Get its mean
        thing2 = bsxfun(@minus,a,b);       % Subtract its mean
        ad_b = sum(thing2.*thing2,3);      % Auto corr, for normalization later
        
        % Cross corr
        ccs = sum(bsxfun(@times,thing1,thing2),3)./sqrt(bsxfun(@times,ad_a,ad_b)); % Cross corr with normalization
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
% hObject    handle to gXCorImageCountEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gXCorImageCountEntry as text
%        str2double(get(hObject,'String')) returns contents of gXCorImageCountEntry as a double


% --- Executes during object creation, after setting all properties.
function gXCorImageCountEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gXCorImageCountEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in gXCorSmoothToggle.
function gXCorSmoothToggle_Callback(hObject, eventdata, handles)

function playStackMovButton_Callback(hObject, eventdata, handles)
% main play
playState=1;
assignin('base','playState',playState)

selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
playStack=double(evalin('base',[selections{selectionsIndex}]));
if size(playStack,3)>1
% This helps you start from where you left off.
startFrame=str2num(get(handles.frameTextEntry,'String'));
if startFrame==size(playStack,3)
    startFrame=1;
else
end

sliderMin = 1;
sliderMax = size(playStack,3); % this is variable
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


ii=1;
    for i=startFrame:size(playStack,3)
        pS=evalin('base','playState');
        if pS==1
            ii=(ii.*(1-mfactor))+playStack(:,:,i).*mfactor;
            ii=ii.*cMask;
            set(handles.frameTextEntry,'String',num2str(i));
            set(handles.frameSlider, 'Value', i);
            h=imshow(ii,'DisplayRange',[lowCut highCut]);
            colormap(gca,cMap);
            daspect([1 1 1])
            drawnow;
            delete(h);
        elseif pS==0
            set(handles.frameTextEntry,'String',num2str(i));
            set(handles.frameSlider, 'Value', i);
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
    

else
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pasueMovieButton.
function pasueMovieButton_Callback(hObject, eventdata, handles)
% hObject    handle to pasueMovieButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
playState=0;
assignin('base','playState',playState)


% --- Executes on button press in localXCorButton.
function localXCorButton_Callback(hObject, eventdata, handles)
% hObject    handle to localXCorButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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

refreshVarListButton_Callback(hObject, eventdata, handles);
guidata(hObject, handles);



function roiThresholdEntry_Callback(hObject, eventdata, handles)
% hObject    handle to roiThresholdEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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

% --- Executes during object creation, after setting all properties.
function roiThresholdEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roiThresholdEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pcaButton.
function pcaButton_Callback(hObject, eventdata, handles)
% hObject    handle to pcaButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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




guidata(hObject, handles);
refreshVarListButton_Callback(hObject, eventdata, handles)
% Update handles structure
guidata(hObject, handles);



function colormapTextEntry_Callback(hObject, eventdata, handles)
% hObject    handle to colormapTextEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of colormapTextEntry as text
%        str2double(get(hObject,'String')) returns contents of colormapTextEntry as a double
% disp(get(handles.colormapTextEntry,'String'))
% disp(get(handles.colormapTextEntry,'Value'))


loadMeanProjectionButton_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function colormapTextEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colormapTextEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function frameSlider_Callback(hObject, eventdata, handles)
% hObject    handle to frameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sliderValue = get(handles.frameSlider,'Value');
set(handles.frameTextEntry,'String', num2str(sliderValue));
guidata(hObject, handles);
loadMeanProjectionButton_Callback(hObject,eventdata, handles);






% --- Executes during object creation, after setting all properties.
function frameSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function frameTextEntry_Callback(hObject, eventdata, handles)


loadMeanProjectionButton_Callback(hObject, eventdata, handles)
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function frameTextEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameTextEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in addToSomasButton.
function addToSomasButton_Callback(hObject, eventdata, handles)
% hObject    handle to addToSomasButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in addToDendritesButton.
function addToDendritesButton_Callback(hObject, eventdata, handles)
% hObject    handle to addToDendritesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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


% --- Executes on button press in addToBoutonsButton.
function addToBoutonsButton_Callback(hObject, eventdata, handles)
% hObject    handle to addToBoutonsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
pause(0.00000001);
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

[nm1,nm2,nm3]=nmf(tStack,fNum,'MAX_ITER',150);
nm1=nm1./max(max(max(nm1)));

nm1=reshape(nm1,s1,s2,fNum);
clear tStack

assignin('base','nm1',nm1);
assignin('base','nm2',nm2);
assignin('base','nm3',nm3);

clear nm1 nm2 nm3

nmTim=toc;
set(handles.feedbackString,'String',['finished nnmf in ' num2str(nmTim) 'seconds'])
pause(0.000001);
guidata(hObject, handles);
refreshVarListButton_Callback(hObject, eventdata, handles)


function featureCountEntry_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function featureCountEntry_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in medianFilterToggle.
function medianFilterToggle_Callback(hObject, eventdata, handles)
% hObject    handle to medianFilterToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of medianFilterToggle

loadMeanProjectionButton_Callback(hObject, eventdata, handles)


% --- Executes on button press in wienerFilterToggle.
function wienerFilterToggle_Callback(hObject, eventdata, handles)
% hObject    handle to wienerFilterToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of wienerFilterToggle
loadMeanProjectionButton_Callback(hObject, eventdata, handles)


% --- Executes on button press in importerButton.
function importerButton_Callback(hObject, eventdata, handles)
% hObject    handle to importerButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

evalin('base','importer')

% --- Executes on button press in extractorButton.
function extractorButton_Callback(hObject, eventdata, handles)
% hObject    handle to extractorButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

evalin('base','extractor')


% --- Executes on button press in pushbutton27.
function pushbutton27_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in overlayIndRoiToggle.
function overlayIndRoiToggle_Callback(hObject, eventdata, handles)
% hObject    handle to overlayIndRoiToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of overlayIndRoiToggle
loadMeanProjectionButton_Callback(hObject, eventdata, handles)


% --- Executes on button press in cMaskToggle.
function cMaskToggle_Callback(hObject, eventdata, handles)
% hObject    handle to cMaskToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
bT=str2double(get(handles.binaryThrValEntry,'String'));

cImage=evalin('base','currentImage');
cMask=imbinarize(cImage,bT);
assignin('base','cMask',cMask);

axes(handles.imageWindow)
imshow(cMask)
assignin('base','segMask',cMask);

refreshVarListButton_Callback(hObject, eventdata, handles);
guidata(hObject, handles);


% --- Executes on button press in curImageToCandButton.
function curImageToCandButton_Callback(hObject, eventdata, handles)
% hObject    handle to curImageToCandButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

imSelection=getWSVar(hObject, eventdata, handles);
if size(imSelection,3)
    sID=fix(str2double(get(handles.frameTextEntry,'String')));
    imageP=imSelection(:,:,sID);
    clear imSelection
else
    imageP=imSelection;
    clear imSelection
end
axes(handles.roiPreviewWindow);
imagesc(imageP,[0 2]),colormap('jet')

refreshVarListButton_Callback(hObject, eventdata, handles);
guidata(hObject, handles);


% --- Executes on button press in segmentMaskBtn.
function segmentMaskBtn_Callback(hObject, eventdata, handles)
% hObject    handle to segmentMaskBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sR=evalin('base','segMask');
imSize=[size(sR,1) size(sR,2)];
minROISize=fix(str2double(get(handles.minRoiEntry,'String')));
linThr=1;
pROIs=bwboundaries(sR,'holes');
pROIsizes=cellfun(@numel,pROIs)/2;
disp(pROIsizes)
ogNum=numel(pROIs);
stROIs=find(pROIsizes>=minROISize);
usedNum=numel(stROIs);


%pre allocate
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

guidata(hObject, handles);
curIm=str2double(get(handles.frameTextEntry,'String'));
set(handles.frameTextEntry,'String',num2str(curIm+1))
guidata(hObject, handles);
loadMeanProjectionButton_Callback(hObject, eventdata,handles)



% --- Executes on button press in autoMaskBtn.
function autoMaskBtn_Callback(hObject, eventdata, handles)
% hObject    handle to autoMaskBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sens=str2double(get(handles.binarySensEntry,'String'));
tI=getWSVar(hObject, eventdata, handles);
stackInd=fix(str2double(get(handles.frameTextEntry,'String')));
if size(tI,3)>1
    tI=tI(:,:,stackInd);
end

ogMs=double(tI)./max(max(double(tI)));
bthr=0;
thMs=imbinarize(ogMs,'adaptive','sensitivity',sens);
thMs=medfilt2(thMs);
axes(handles.imageWindow)
imshow(thMs)
assignin('base','segMask',thMs);

refreshVarListButton_Callback(hObject, eventdata, handles);
guidata(hObject, handles);


function binarySensEntry_Callback(hObject, eventdata, handles)
% hObject    handle to binarySensEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of binarySensEntry as text
%        str2double(get(hObject,'String')) returns contents of binarySensEntry as a double
cMaskToggle_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function binarySensEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to binarySensEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function minRoiEntry_Callback(hObject, eventdata, handles)
% hObject    handle to minRoiEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minRoiEntry as text
%        str2double(get(hObject,'String')) returns contents of minRoiEntry as a double


% --- Executes during object creation, after setting all properties.
function minRoiEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minRoiEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in manROIBtn_Generic.
function manROIBtn_Generic_Callback(hObject, eventdata, handles)
% hObject    handle to manROIBtn_Generic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in roiTypeMenu.
function roiTypeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to roiTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns roiTypeMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from roiTypeMenu


% --- Executes during object creation, after setting all properties.
function roiTypeMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roiTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in deleteWSVar.
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

cImage=evalin('base','currentImage');
eString=get(handles.imageCutEntry,'String');
disp(eString)
disp(['cImage(find(cImage ' eString '))=0'])
eval(['cImage(find(cImage ' eString '))=0']);
mV=min(min(nonzeros(cImage)));
cImage=remap(cImage,[mV 0.9],[0 0.9]);
assignin('base','currentImage',cImage);
loadMeanProjectionButton_Callback(hObject, eventdata, handles,cImage)

function imageCutEntry_Callback(hObject, eventdata, handles)

cutByBtn_Callback(hObject, eventdata, handles)

function imageCutEntry_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function deDupeRoisBtn_Callback(hObject, eventdata, handles)

sL=get(handles.roiTypeMenu,'String');
sV=get(handles.roiTypeMenu,'Value');
roiTypeSelected=sL{sV};
assignin('base','roiSelectString',roiTypeSelected)

typeMasks=evalin('base',[roiTypeSelected 'ROIs']);

corrCount=0;
flag1=[];
flag2=[];
totalCs=nchoosek(numel(typeMasks),2);

for n=1:numel(typeMasks)
    for j=(n+1):numel(typeMasks)
        corrCount=corrCount+1;
        pCor(:,corrCount)=corr2(typeMasks{n},typeMasks{j});
        if pCor(:,corrCount)>=0.2
            flag1=[flag1; n];
            flag2=[flag2; j];
        else
        end
        if mod(corrCount,1000)==0
            disp([num2str(corrCount) '/' num2str(totalCs) ' done'])
        else
        end
    end
end

toNull=[];
for n=1:numel(flag1)
    s1=numel(find(typeMasks{flag1(n)}==1));
    s2=numel(find(typeMasks{flag2(n)}==1));
    if s1>s2
        toNull(:,n)=flag2(n);
    else
        toNull(:,n)=flag1(n);
    end
end

disp(['will remove ' num2str(numel(toNull)) ' potentially duplicated ROIs'])


r=evalin('base',[roiTypeSelected 'ROIs']);
c=evalin('base',[roiTypeSelected 'ROICenters']);
b=evalin('base',[roiTypeSelected 'ROIBoundaries']);
pl=evalin('base',[roiTypeSelected 'ROI_PixelLists']);

r(toNull)=[];
c(toNull)=[];
b(toNull)=[];
pl(toNull)=[];

assignin('base',[roiTypeSelected 'ROIs'],r)
assignin('base',[roiTypeSelected 'ROICenters'],c)
assignin('base',[roiTypeSelected 'ROIBoundaries'],b)
assignin('base',[roiTypeSelected 'RoiCounter'],numel(pl))
assignin('base',[roiTypeSelected 'ROI_PixelLists'],pl)

clear toNull

toNull=[];
for n=1:numel(typeMasks)
    if numel(find(typeMasks{n}==1))<3
        toNull=[toNull; n];
    else
    end
end

if numel(toNull)>=1
    r=evalin('base',[roiTypeSelected 'ROIs']);
    c=evalin('base',[roiTypeSelected 'ROICenters']);
    b=evalin('base',[roiTypeSelected 'ROIBoundaries']);
    pl=evalin('base',[roiTypeSelected 'ROI_PixelLists']);

    r(toNull)=[];
    c(toNull)=[];
    b(toNull)=[];
    pl(toNull)=[];

    assignin('base',[roiTypeSelected 'ROIs'],r)
    assignin('base',[roiTypeSelected 'ROICenters'],c)
    assignin('base',[roiTypeSelected 'ROIBoundaries'],b)
    assignin('base',[roiTypeSelected 'RoiCounter'],numel(pl))
    assignin('base',[roiTypeSelected 'ROI_PixelLists'],pl)

    disp(['also removed ' num2str(numel(toNull)) ' tiny ROIs'])
else
end

clear toNull s1 s2 n pCor flag1 flag2 corrCount

function somaButton_KeyPressFcn(hObject, eventdata, handles)
if get(gcf,'currentcharacter') == 'h'
disp('yo')
else
end
