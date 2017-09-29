function varargout = roiMaker(varargin)
% ROIMAKER 
% 
% roiMaker is a simple gui and set of processes for making various ROIs in
% imaging data. 
%
% When you click a button on the left it will initiate selecting an roi that will become one of that type. 
% The sliders on the bottom adjust the low and high cuts of the images.
% You have to refresh the workspace variables when you first load.
% No Documentation (yet)
%
% Most Code: Chris Deister & Jakob Voigts
% Global XCorr Segmentation Idea: Stephan Junek et al., 2009, Spencer Smith
%
% Questions: cdeister@brown.edu

% 
% Last Modified by GUIDE v2.5 28-Sep-2017 23:11:35

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

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes roiMaker wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = roiMaker_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in somaButton.
function somaButton_Callback(hObject, eventdata, handles)

g=evalin('base','exist(''somaticRoiCounter'')');

if g==1
    h=evalin('base','somaticRoiCounter');
    r=evalin('base','somaticROIs');
    c=evalin('base','somaticROICenters');
    b=evalin('base','somaticROIBoundaries');
    pl=evalin('base','somaticROI_PixelLists');
    
    h=h+1;
    a=imfreehand;
    mask=a.createMask;
    
    
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
    a=imfreehand;
    mask=a.createMask;
    
    assignin('base','somaticROIs',{mask})
    assignin('base','somaticROICenters',{regionprops(mask,'Centroid')})
    assignin('base','somaticROI_PixelLists',{regionprops(mask,'PixelList')})
    assignin('base','somaticROIBoundaries',{bwboundaries(mask)})
    assignin('base','somaticRoiCounter',h)
end

guidata(hObject, handles);


function redSomaButton_Callback(hObject, eventdata, handles)

g=evalin('base','exist(''redSomaticRoiCounter'')');

if g==1
    h=evalin('base','redSomaticRoiCounter');
    r=evalin('base','redSomaticROIs');
    c=evalin('base','redSomaticROICenters');
    b=evalin('base','redSomaticROIBoundaries');
    pl=evalin('base','redSomaticROI_PixelLists');
    
    h=h+1;
    a=imfreehand;
    mask=a.createMask;
    
    
    r{h}=mask;
    b{h}=bwboundaries(mask);
    c{h}=regionprops(mask,'Centroid');
    pl{h}=regionprops(mask,'PixelList');
    
    
    assignin('base','redSomaticROIs',r)
    assignin('base','redSomaticROICenters',c)
    assignin('base','redSomaticROIBoundaries',b)
    assignin('base','redSomaticRoiCounter',h)
    assignin('base','redSomaticROI_PixelLists',pl)
    
else
    h=1;
    a=imfreehand;
    mask=a.createMask;
    
    assignin('base','redSomaticROIs',{mask})
    assignin('base','redSomaticROICenters',{regionprops(mask,'Centroid')})
    assignin('base','redSomaticROI_PixelLists',{regionprops(mask,'PixelList')})
    assignin('base','redSomaticROIBoundaries',{bwboundaries(mask)})
    assignin('base','redSomaticRoiCounter',h)
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in dendriteButton.
function dendriteButton_Callback(hObject, eventdata, handles)
% hObject    handle to dendriteButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
g=evalin('base','exist(''dendriticRoiCounter'')');
if g==1
    h=evalin('base','dendriticRoiCounter');
    r=evalin('base','dendriticROIs');
    c=evalin('base','dendriticROICenters');
    b=evalin('base','dendriticROIBoundaries');
    
    h=h+1;
    a=imfreehand;
    mask=a.createMask;
    
    
    r{h}=mask;
    b{h}=bwboundaries(mask);
    c{h}=regionprops(mask,'Centroid');
    
    
    assignin('base','dendriticROIs',r)
    assignin('base','dendriticROICenters',c)
    assignin('base','dendriticROIBoundaries',b)
    assignin('base','dendriticRoiCounter',h)
    
else
    h=1;
    a=imfreehand;
    mask=a.createMask;
    
    assignin('base','dendriticROIs',{mask})
    assignin('base','dendriticROICenters',{regionprops(mask,'Centroid')})
    assignin('base','dendriticROIBoundaries',{bwboundaries(mask)})
    assignin('base','dendriticRoiCounter',h)
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in axonButton.
function axonButton_Callback(hObject, eventdata, handles)
% hObject    handle to axonButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
g=evalin('base','exist(''axonalRoiCounter'')');
if g==1
    h=evalin('base','axonalRoiCounter');
    r=evalin('base','axonalROIs');
    c=evalin('base','axonalROICenters');
    b=evalin('base','axonalROIBoundaries');
    
    h=h+1;
    a=imfreehand;
    mask=a.createMask;
    
    
    r{h}=mask;
    b{h}=bwboundaries(mask);
    c{h}=regionprops(mask,'Centroid');
    
    
    assignin('base','axonalROIs',r)
    assignin('base','axonalROICenters',c)
    assignin('base','axonalROIBoundaries',b)
    assignin('base','axonalRoiCounter',h)
    
else
    h=1;
    a=imfreehand;
    mask=a.createMask;
    
    assignin('base','axonalROIs',{mask})
    assignin('base','axonalROICenters',{regionprops(mask,'Centroid')})
    assignin('base','axonalROIBoundaries',{bwboundaries(mask)})
    assignin('base','axonalRoiCounter',h)
end

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in boutonButton.
function boutonButton_Callback(hObject, eventdata, handles)
% hObject    handle to boutonButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
g=evalin('base','exist(''boutonRoiCounter'')');
if g==1
    h=evalin('base','boutonRoiCounter');
    r=evalin('base','boutonROIs');
    c=evalin('base','boutonROICenters');
    b=evalin('base','boutonROIBoundaries');
    
    h=h+1;
    a=imfreehand;
    mask=a.createMask;
    
    
    r{h}=mask;
    b{h}=bwboundaries(mask);
    c{h}=regionprops(mask,'Centroid');
    
    
    assignin('base','boutonROIs',r)
    assignin('base','boutonROICenters',c)
    assignin('base','boutonROIBoundaries',b)
    assignin('base','boutonRoiCounter',h)
    
else
    h=1;
    a=imfreehand;
    mask=a.createMask;
    
    assignin('base','boutonROIs',{mask})
    assignin('base','boutonROICenters',{regionprops(mask,'Centroid')})
    assignin('base','boutonROIBoundaries',{bwboundaries(mask)})
    assignin('base','boutonRoiCounter',h)
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in roiSelector.
function roiSelector_Callback(hObject, eventdata, handles)
% hObject    handle to roiSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns roiSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from roiSelector

roiNumber=get(handles.roiSelector,'Value');

% Figure out what roi type is selected
sTr=get(handles.somaRoisDisplayToggle, 'Value');
rSTr=get(handles.redSomaRoisDisplayToggle, 'Value');
dTr=get(handles.dendriteRoisDisplayToggle, 'Value');
aTr=get(handles.axonRoisDisplayToggle, 'Value');
bTr=get(handles.boutonRoisDisplayToggle, 'Value');
vTr=get(handles.vascularRoisDisplayToggle, 'Value');
nTr=get(handles.neuropilRoisDisplayToggle, 'Value');

loadMeanProjectionButton_Callback(hObject,eventdata, handles);

% If somatic
if sTr==1;
    h=evalin('base','somaticRoiCounter');
    c=evalin('base','somaticROICenters');
    b=evalin('base','somaticROIBoundaries');
elseif rSTr==1;
    h=evalin('base','redSomaticRoiCounter');
    c=evalin('base','redSomaticROICenters');
    b=evalin('base','redSomaticROIBoundaries');
elseif dTr==1;
    h=evalin('base','dendriticRoiCounter');
    c=evalin('base','dendriticROICenters');
    b=evalin('base','dendriticROIBoundaries');
elseif aTr==1;
    h=evalin('base','axonalRoiCounter');
    c=evalin('base','axonalROICenters');
    b=evalin('base','axonalROIBoundaries');
elseif bTr==1;
    h=evalin('base','boutonRoiCounter');
    c=evalin('base','boutonROICenters');
    b=evalin('base','boutonROIBoundaries');
elseif vTr==1;
    h=evalin('base','vesselRoiCounter');
    c=evalin('base','vesselROICenters');
    b=evalin('base','vesselROIBoundaries');
elseif nTr==1;
    h=evalin('base','neuropilRoiCounter'); 
    b=evalin('base','neuropilROIBoundaries');
    c=evalin('base','neuropilROICenters');

else
end

% Populate the box:
for n=1:h
    roisList{n}=n;
end
set(handles.roiSelector, 'String', '');
set(handles.roiSelector,'String',roisList);
set(handles.roiSelector,'Value',roiNumber)

% Plot
if strcmp(get(handles.colormapTextEntry,'String'),'jet')
    outColor='k';
    txtColor=[0 0 0];
else
    outColor='g';
    txtColor=[0 1 1];
end
axes(handles.imageWindow);
hold all 
for n=1:numel(b)
    for k=1:numel(c{1,n})
        plot(b{1,n}{k,1}(:,2),b{1,n}{k,1}(:,1),outColor,'LineWidth',2)
        text(c{1,n}(k).Centroid(1)-1, c{1,n}(k).Centroid(2), num2str(n),'FontSize',10,'FontWeight','Bold','Color',txtColor);
    end
end
hold all
n=roiNumber;
outColor='r';
txtColor=[1 0 0];
for k=1:numel(c{1,n})
    plot(b{1,n}{k,1}(:,2),b{1,n}{k,1}(:,1),outColor,'LineWidth',2)
    text(c{1,n}(k).Centroid(1)-1, c{1,n}(k).Centroid(2), num2str(n),'FontSize',10,'FontWeight','Bold','Color',txtColor);
end

hold off

set(handles.roiSelector,'Value',roiNumber);

% Update handles structure
guidata(hObject, handles);

    


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


% --- Executes on button press in vesselButton.
function vesselButton_Callback(hObject, eventdata, handles)
% hObject    handle to vesselButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
g=evalin('base','exist(''vesselRoiCounter'')');
if g==1
    h=evalin('base','vesselRoiCounter');
    r=evalin('base','vesselROIs');
    c=evalin('base','vesselROICenters');
    b=evalin('base','vesselROIBoundaries');
    
    h=h+1;
    a=imfreehand;
    mask=a.createMask;
    
    
    r{h}=mask;
    b{h}=bwboundaries(mask);
    c{h}=regionprops(mask,'Centroid');
    
    
    assignin('base','vesselROIs',r)
    assignin('base','vesselROICenters',c)
    assignin('base','vesselROIBoundaries',b)
    assignin('base','vesselRoiCounter',h)
    
else
    h=1;
    a=imfreehand;
    mask=a.createMask;
    
    assignin('base','vesselROIs',{mask})
    assignin('base','vesselROICenters',{regionprops(mask,'Centroid')})
    assignin('base','vesselROIBoundaries',{bwboundaries(mask)})
    assignin('base','vesselRoiCounter',h)
end

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in loadMeanProjectionButton.
function loadMeanProjectionButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadMeanProjectionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a = str2double(get(handles.lowCutEntry,'String'));
b = str2double(get(handles.highCutEntry,'String'));

selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');


imageP=evalin('base',selections{selectionsIndex});

if numel(size(imageP))==3
    stackNum=size(imageP,3);
    stackInd=fix(str2num(get(handles.frameTextEntry,'String')));
    imageP=imageP(:,:,stackInd);
    maxTest=max(max(imageP));
    if maxTest<=1
        imageP=imageP*65535;
    else
    end
    
    sliderMin = 1;
    sliderMax = stackNum; % this is variable
    sliderStep = [1, 1] / (sliderMax - sliderMin); % major and minor steps of 1
    
    set(handles.frameSlider, 'Min', sliderMin);
    set(handles.frameSlider, 'Max', sliderMax);
    set(handles.frameSlider, 'SliderStep', sliderStep);
    set(handles.frameSlider, 'Value', stackInd); % set to beginning of sequence
    
else
    maxTest=max(max(imageP));
    if maxTest<=1
        imageP=imageP*65535;
    else
    end
    
    sliderMin = 0;
    sliderMax = 1; % this is variable
    sliderStep = [1, 1] / (sliderMax - sliderMin); % major and minor steps of 1
    
    set(handles.frameSlider, 'Min', sliderMin);
    set(handles.frameSlider, 'Max', sliderMax);
    set(handles.frameSlider, 'SliderStep', sliderStep);
    set(handles.frameSlider, 'Value', 1); % set to beginning of sequence
    set(handles.frameTextEntry,'Value',1);
end

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

cMap=get(handles.colormapTextEntry,'String');
axes(handles.imageWindow);
imshow(imageP,'DisplayRange',[a b]);
colormap(cMap)


assignin('base','currentImage',imageP)

axes(handles.imageHistogram);
nhist(double(imageP),'box');
xlim([a b])
hold all
plot([a a],[0 10000],'r-')
plot([b b],[0 10000],'b-')
hold off

axes(handles.imageWindow);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in deleteROIButton.
function deleteROIButton_Callback(hObject, eventdata, handles)
% hObject    handle to deleteROIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sTr=get(handles.somaRoisDisplayToggle, 'Value');
rSTr=get(handles.redSomaRoisDisplayToggle, 'Value');
dTr=get(handles.dendriteRoisDisplayToggle, 'Value');
aTr=get(handles.axonRoisDisplayToggle, 'Value');
bTr=get(handles.boutonRoisDisplayToggle, 'Value');
vTr=get(handles.vascularRoisDisplayToggle, 'Value');
nTr=get(handles.neuropilRoisDisplayToggle, 'Value');


roiNumber=get(handles.roiSelector,'Value');

if sTr
    h=evalin('base','somaticRoiCounter');
    r=evalin('base','somaticROIs');
    c=evalin('base','somaticROICenters');
    b=evalin('base','somaticROIBoundaries');
    pl=evalin('base','somaticROI_PixelLists');
    
    h=h-1;
    r(roiNumber)=[];
    c(roiNumber)=[];
    b(roiNumber)=[];
    pl(roiNumber)=[];
    
    assignin('base','somaticROIs',r)
    assignin('base','somaticROICenters',c)
    assignin('base','somaticROIBoundaries',b)
    assignin('base','somaticRoiCounter',h)
    assignin('base','somaticROI_PixelLists',pl)
    somaRoisDisplayToggle_Callback(handles.somaRoisDisplayToggle,eventdata,handles)
    
    % alert the user their neuropil masks will be out of sync.
    g=evalin('base','exist(''neuropilRoiCounter'')');
    if g 
        set(handles.neuropilAlertString,'String','regenerate neuropil masks -->','ForegroundColor',[1 0 0]);
    else
        set(handles.neuropilAlertString,'ForegroundColor',[0 0 0]);
    end

elseif rSTr
    h=evalin('base','redSomaticRoiCounter');
    r=evalin('base','redSomaticROIs');
    c=evalin('base','redSomaticROICenters');
    b=evalin('base','redSomaticROIBoundaries');
    pl=evalin('base','redSomaticROI_PixelLists');
    
    h=h-1;
    r(roiNumber)=[];
    c(roiNumber)=[];
    b(roiNumber)=[];
    pl(roiNumber)=[];
    
    assignin('base','redSomaticROIs',r)
    assignin('base','redSomaticROICenters',c)
    assignin('base','redSomaticROIBoundaries',b)
    assignin('base','redSomaticRoiCounter',h)
    assignin('base','redSomaticROI_PixelLists',pl)
    redSomaRoisDisplayToggle_Callback(handles.redSomaRoisDisplayToggle,eventdata,handles)
    
    
elseif dTr
    h=evalin('base','dendriticRoiCounter');
    r=evalin('base','dendriticROIs');
    c=evalin('base','dendriticROICenters');
    b=evalin('base','dendriticROIBoundaries');
    
    h=h-1;
    r(roiNumber)=[];
    c(roiNumber)=[];
    b(roiNumber)=[];
    
    assignin('base','dendriticROIs',r)
    assignin('base','dendriticROICenters',c)
    assignin('base','dendriticROIBoundaries',b)
    assignin('base','dendriticRoiCounter',h)
    dendriteRoisDisplayToggle_Callback(handles.dendriteRoisDisplayToggle,eventdata,handles)

elseif aTr
    h=evalin('base','axonalRoiCounter');
    r=evalin('base','axonalROIs');
    c=evalin('base','axonalROICenters');
    b=evalin('base','axonalROIBoundaries');
    
    h=h-1;
    r(roiNumber)=[];
    c(roiNumber)=[];
    b(roiNumber)=[];
    
    assignin('base','axonalROIs',r)
    assignin('base','axonalROICenters',c)
    assignin('base','axonalROIBoundaries',b)
    assignin('base','axonalRoiCounter',h)
    axonRoisDisplayToggle_Callback(handles.axonRoisDisplayToggle,eventdata,handles)
elseif bTr
    h=evalin('base','boutonRoiCounter');
    r=evalin('base','boutonROIs');
    c=evalin('base','boutonROICenters');
    b=evalin('base','boutonROIBoundaries');
    
    h=h-1;
    r(roiNumber)=[];
    c(roiNumber)=[];
    b(roiNumber)=[];
    
    assignin('base','boutonROIs',r)
    assignin('base','boutonROICenters',c)
    assignin('base','boutonROIBoundaries',b)
    assignin('base','boutonRoiCounter',h)
    boutonRoisDisplayToggle_Callback(handles.boutonRoisDisplayToggle,eventdata,handles)
elseif vTr
    h=evalin('base','vesselRoiCounter');
    r=evalin('base','vesselROIs');
    c=evalin('base','vesselROICenters');
    b=evalin('base','vesselROIBoundaries');
    
    h=h-1;
    r(roiNumber)=[];
    c(roiNumber)=[];
    b(roiNumber)=[];
    
    assignin('base','vesselROIs',r)
    assignin('base','vesselROICenters',c)
    assignin('base','vesselROIBoundaries',b)
    assignin('base','vesselRoiCounter',h)
    vesselRoisDisplayToggle_Callback(handles.neuropilRoisDisplayToggle,eventdata,handles)     
elseif nTr
    h=evalin('base','neuropilRoiCounter');
    r=evalin('base','neuropilROIs');
    c=evalin('base','neuropilROICenters');
    b=evalin('base','neuropilROIBoundaries');
    
    h=h-1;
    r(roiNumber)=[];
    c(roiNumber)=[];
    b(roiNumber)=[];
    
    assignin('base','neuropilROIs',r)
    assignin('base','neuropilROICenters',c)
    assignin('base','neuropilROIBoundaries',b)
    assignin('base','neuropilRoiCounter',h)
    neuropilRoisDisplayToggle_Callback(handles.neuropilRoisDisplayToggle,eventdata,handles)        
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in somaRoisDisplayToggle.
function somaRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to somaRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of somaRoisDisplayToggle


set(handles.somaRoisDisplayToggle, 'Value', 1);
set(handles.redSomaRoisDisplayToggle, 'Value', 0);
set(handles.dendriteRoisDisplayToggle, 'Value', 0);
set(handles.axonRoisDisplayToggle, 'Value', 0);
set(handles.boutonRoisDisplayToggle, 'Value', 0);
set(handles.neuropilRoisDisplayToggle, 'Value', 0);


% --- Plot the image again
loadMeanProjectionButton_Callback(hObject,eventdata, handles);
% --- end image plot

h=evalin('base','somaticRoiCounter');
c=evalin('base','somaticROICenters');
b=evalin('base','somaticROIBoundaries');

% Populate the box:
for n=1:h
    roisList{n}=n;
end
set(handles.roiSelector, 'String', '');
set(handles.roiSelector,'String',roisList);
set(handles.roiSelector,'Value',1)

% Plot
if strcmp(get(handles.colormapTextEntry,'String'),'jet')
    outColor='k';
    txtColor=[0 0 0];
else
    outColor='g';
    txtColor=[0 1 1];
end
axes(handles.imageWindow);
hold all 
for n=1:numel(b)
    for k=1:numel(c{1,n})
        plot(b{1,n}{k,1}(:,2),b{1,n}{k,1}(:,1),outColor,'LineWidth',2)
        text(c{1,n}(k).Centroid(1)-1, c{1,n}(k).Centroid(2), num2str(n),'FontSize',10,'FontWeight','Bold','Color',txtColor);

    end
end

hold off

        
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in redSomaRoisDisplayToggle.
function redSomaRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to redSomaRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of redSomaRoisDisplayToggle
set(handles.somaRoisDisplayToggle, 'Value', 0);
set(handles.redSomaRoisDisplayToggle, 'Value', 1);
set(handles.dendriteRoisDisplayToggle, 'Value', 0);
set(handles.axonRoisDisplayToggle, 'Value', 0);
set(handles.boutonRoisDisplayToggle, 'Value', 0);
set(handles.neuropilRoisDisplayToggle, 'Value', 0);


% --- Plot the image again
loadMeanProjectionButton_Callback(hObject,eventdata, handles);

% --- end image plot

h=evalin('base','redSomaticRoiCounter');
c=evalin('base','redSomaticROICenters');
b=evalin('base','redSomaticROIBoundaries');

% Populate the box:
for n=1:h
    roisList{n}=n;
end
set(handles.roiSelector, 'String', '');
set(handles.roiSelector,'String',roisList);
set(handles.roiSelector,'Value',1)

% Plot
hold all 
for n=1:numel(b)
    axes(handles.imageWindow);
    plot(b{1,n}{1,1}(:,2),b{1,n}{1,1}(:,1),'r','LineWidth',1)
    text(c{1,n}.Centroid(1)-1, c{1,n}.Centroid(2), num2str(n),'FontSize',10,'FontWeight','Bold','Color',[1 0 0]);
end

hold off

        
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in dendriteRoisDisplayToggle.
function dendriteRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to dendriteRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dendriteRoisDisplayToggle

set(handles.somaRoisDisplayToggle, 'Value', 0);
set(handles.redSomaRoisDisplayToggle, 'Value', 0);
set(handles.dendriteRoisDisplayToggle, 'Value', 1);
set(handles.axonRoisDisplayToggle, 'Value', 0);
set(handles.boutonRoisDisplayToggle, 'Value', 0);
set(handles.neuropilRoisDisplayToggle, 'Value', 0);


% --- Plot the image again
loadMeanProjectionButton_Callback(hObject,eventdata, handles);
% --- end image plot

h=evalin('base','dendriticRoiCounter');
c=evalin('base','dendriticROICenters');
b=evalin('base','dendriticROIBoundaries');

% Populate the box:
for n=1:h
    roisList{n}=n;
end
set(handles.roiSelector, 'String', '');
set(handles.roiSelector,'String',roisList);
set(handles.roiSelector,'Value',1)

% Plot
if strcmp(get(handles.colormapTextEntry,'String'),'jet')
    outColor='k';
    txtColor=[0 0 0];
else
    outColor='g';
    txtColor=[0 1 1];
end
axes(handles.imageWindow);
hold all 
for n=1:numel(b)
    for k=1:numel(c{1,n})
        plot(b{1,n}{k,1}(:,2),b{1,n}{k,1}(:,1),outColor,'LineWidth',2)
        text(c{1,n}(k).Centroid(1)-1, c{1,n}(k).Centroid(2), num2str(n),'FontSize',10,'FontWeight','Bold','Color',txtColor);

    end
end

hold off

        
% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in axonRoisDisplayToggle.
function axonRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to axonRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of axonRoisDisplayToggle
set(handles.somaRoisDisplayToggle, 'Value', 0);
set(handles.redSomaRoisDisplayToggle, 'Value', 0);
set(handles.dendriteRoisDisplayToggle, 'Value', 0);
set(handles.axonRoisDisplayToggle, 'Value', 1);
set(handles.boutonRoisDisplayToggle, 'Value', 0);
set(handles.neuropilRoisDisplayToggle, 'Value', 0);


% --- Plot the image again
loadMeanProjectionButton_Callback(hObject,eventdata, handles);
% --- end image plot

h=evalin('base','axonalRoiCounter');
c=evalin('base','axonalROICenters');
b=evalin('base','axonalROIBoundaries');

% Populate the box:
for n=1:h
    roisList{n}=n;
end
set(handles.roiSelector, 'String', '');
set(handles.roiSelector,'String',roisList);
set(handles.roiSelector,'Value',1)

% Plot

hold all    
for n=1:numel(b)
    plot(b{1,n}{1,1}(:,2),b{1,n}{1,1}(:,1),'g','LineWidth',1)
    text(c{1,n}.Centroid(1)-1, c{1,n}.Centroid(2), num2str(n),'FontSize',10,'FontWeight','Bold','Color',[0 1 1]);
end
hold off

        
% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in boutonRoisDisplayToggle.
function boutonRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to boutonRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of boutonRoisDisplayToggle
set(handles.somaRoisDisplayToggle, 'Value', 0);
set(handles.redSomaRoisDisplayToggle, 'Value', 0);
set(handles.dendriteRoisDisplayToggle, 'Value', 0);
set(handles.axonRoisDisplayToggle, 'Value', 0);
set(handles.boutonRoisDisplayToggle, 'Value', 1);
set(handles.neuropilRoisDisplayToggle, 'Value', 0);
set(handles.vascularRoisDisplayToggle, 'Value', 0);



% --- Plot the image again
loadMeanProjectionButton_Callback(hObject,eventdata, handles);
% --- end image plot

h=evalin('base','boutonRoiCounter');
c=evalin('base','boutonROICenters');
b=evalin('base','boutonROIBoundaries');

% Populate the box:
for n=1:h
    roisList{n}=n;
end
set(handles.roiSelector, 'String', '');
set(handles.roiSelector,'String',roisList);
set(handles.roiSelector,'Value',1)

% Plot
if strcmp(get(handles.colormapTextEntry,'String'),'jet')
    outColor='k';
    txtColor=[0 0 0];
else
    outColor='g';
    txtColor=[0 1 1];
end
axes(handles.imageWindow);
hold all 
for n=1:numel(b)
    for k=1:numel(c{1,n})
        plot(b{1,n}{k,1}(:,2),b{1,n}{k,1}(:,1),outColor,'LineWidth',2)
        text(c{1,n}(k).Centroid(1)-1, c{1,n}(k).Centroid(2), num2str(n),'FontSize',10,'FontWeight','Bold','Color',txtColor);
    end
end

hold off

        
% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in neuropilRoisDisplayToggle.
function neuropilRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to neuropilRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of neuropilRoisDisplayToggle
set(handles.somaRoisDisplayToggle, 'Value', 0);
set(handles.redSomaRoisDisplayToggle, 'Value', 0);
set(handles.dendriteRoisDisplayToggle, 'Value', 0);
set(handles.axonRoisDisplayToggle, 'Value', 0);
set(handles.boutonRoisDisplayToggle, 'Value', 0);
set(handles.neuropilRoisDisplayToggle, 'Value', 1);


% --- Plot the image again
loadMeanProjectionButton_Callback(hObject,eventdata, handles);
% --- end image plot

h=evalin('base','neuropilRoiCounter');
c=evalin('base','neuropilROICenters');
b=evalin('base','neuropilROIBoundaries');

% Populate the box:
for n=1:h
    roisList{n}=n;
end
set(handles.roiSelector, 'String', '');
set(handles.roiSelector,'String',roisList);
set(handles.roiSelector,'Value',1)

% Plot
if strcmp(get(handles.colormapTextEntry,'String'),'jet')
    outColor='k';
    txtColor=[0 0 0];
else
    outColor='g';
    txtColor=[0 1 1];
end
axes(handles.imageWindow);
hold all 
for n=1:numel(b)
    for k=1:numel(c{1,n})
        plot(b{1,n}{k,1}(:,2),b{1,n}{k,1}(:,1),outColor,'LineWidth',2)
        text(c{1,n}(k).Centroid(1)-1, c{1,n}(k).Centroid(2), num2str(n),'FontSize',10,'FontWeight','Bold','Color',txtColor);

    end
end

hold off


        
% Update handles structure
guidata(hObject, handles);




% --- Executes on slider movement.
function lowCutSlider_Callback(hObject, eventdata, handles)
% hObject    handle to lowCutSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderValue = get(handles.lowCutSlider,'Value');
set(handles.lowCutEntry,'String', num2str(sliderValue));

% --- adjust the image
axes(handles.imageWindow);
imageP=evalin('base','currentImage');
a = str2double(get(handles.lowCutEntry,'String'));
b = str2double(get(handles.highCutEntry,'String'));

axes(handles.imageWindow);
imshow(imageP,[a b]);

guidata(hObject, handles); 


% --- Executes during object creation, after setting all properties.
function lowCutSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowCutSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function highCutSlider_Callback(hObject, eventdata, handles)
% hObject    handle to highCutSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderValue = get(handles.highCutSlider,'Value');
set(handles.highCutEntry,'String', num2str(sliderValue));

% --- adjust the image
axes(handles.imageWindow);
imageP=evalin('base','currentImage');
a = str2double(get(handles.lowCutEntry,'String'));
b = str2double(get(handles.highCutEntry,'String'));


axes(handles.imageWindow);
imshow(imageP,[a b]);


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
% hObject    handle to lowCutEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lowCutEntry as text
%        str2double(get(hObject,'String')) returns contents of lowCutEntry as a double
input = str2num(get(hObject,'String'));

%checks to see if input is empty. if so, default input1_editText to zero
if (isempty(input))
     set(hObject,'String','0')
end

set(handles.lowCutSlider,'Value',input);  

% --- adjust the image
axes(handles.imageWindow);
imageP=evalin('base','currentImage');
a = get(handles.lowCutEntry,'String');
b = get(handles.highCutEntry,'String');
lowCut=str2double(a)/65535;
highCut=str2double(b)/65535;

adjImage=imadjust(imageP,[lowCut highCut]);

axes(handles.imageWindow);
imshow(adjImage);


% --- Executes during object creation, after setting all properties.
function lowCutEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowCutEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function highCutEntry_Callback(hObject, eventdata, handles)
% hObject    handle to highCutEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of highCutEntry as text
%        str2double(get(hObject,'String')) returns contents of highCutEntry as a double
input = str2num(get(hObject,'String'));

%checks to see if input is empty. if so, default input1_editText to zero
if (isempty(input))
     set(hObject,'String','65535')
end

set(handles.highCutSlider,'Value',input);  

% --- adjust the image
axes(handles.imageWindow);
imageP=evalin('base','currentImage');
a = get(handles.lowCutEntry,'String');
b = get(handles.highCutEntry,'String');
lowCut=str2double(a)/65535;
highCut=str2double(b)/65535;
%gamA=str2double(get(handles.gammaBox,'String'));

adjImage=imadjust(imageP,[lowCut highCut]);

axes(handles.imageWindow);
imshow(adjImage);
% axes(handles.cdfWindow);
% imhist(adjImage,100);
% --- end 

guidata(hObject, handles);


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
    neuropilROI_PixelLists{1,n}=neuropilROI_PixelLists{1,n}.PixelList;
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
    assignin('base',['meanProj_' selections{selectionsIndex(n)}],im2uint16(mP,'Indexed'));
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
        fprintf('%d/%d (%d%%)\n',n,numImages,round(100*(n./nstack)));
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


disp('computing local xcorr');
w=1; % window size

% Initialize and set up parameters
ymax=size(sstack,1);
xmax=size(sstack,2);
numFrames=size(sstack,3);
ccimage=zeros(ymax,xmax);

for y=1+w:ymax-w
    
    if (rem(y,10)==0)
        fprintf('%d/%d (%d%%)\n',y,ymax,round(100*(y./ymax)));
    end;
    
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
disp('! done with xcor');

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

playState=1;
assignin('base','playState',playState)

selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
playStack=evalin('base',[selections{selectionsIndex}]);

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



axes(handles.imageWindow);
mfactor=.35;

a = get(handles.lowCutEntry,'String');
b = get(handles.highCutEntry,'String');
lowCut=str2double(a);
highCut=str2double(b);
cMap=get(handles.colormapTextEntry,'String');

ii=1;
    for i=startFrame:size(playStack,3)
        pS=evalin('base','playState');
        if pS==1
            ii=playStack(:,:,i);
            set(handles.frameTextEntry,'String',num2str(i));
            set(handles.frameSlider, 'Value', i);
            h=imshow(ii,'DisplayRange',[lowCut highCut]);

            colormap(cMap)
            daspect([1 1 1])
            drawnow;
            delete(h);
        elseif pS==0
            ii=playStack(:,:,i);
%             ii=(ii.*(1-mfactor))+playStack(:,:,i).*mfactor;
            imshow(ii,'DisplayRange',[lowCut highCut]);
            daspect([1 1 1])
            axes(handles.imageWindow);
            assignin('base','currentImage',ii)
            break
        end  
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
evalin('base','scratch.candidateRoi=candidateRoi;,clear ''candidateRoi'' ')
evalin('base','scratch.candidateRoi_rawVals=candidateRoi_rawVals;,clear ''candidateRoi_rawVals'' ')


% Update handles structure
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
    evalin('base','scratch.candidateRoi=candidateRoi;,clear ''candidateRoi'' ')
    evalin('base','scratch.candidateRoi_rawVals=candidateRoi_rawVals;,clear ''candidateRoi_rawVals'' ')
end
    

% Update handles structure
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

disp('computing PCA ROI prediction');
    % make PCA composite, this seems to display good roi candidates
stack_v=zeros(imsToCor,size(stack,1)*size(stack,2));
for i=1:imsToCor;
    x=stack(:,:,i);
    stack_v(i,:)=x(:);
end
stack_v=stack_v-mean(stack_v(:));
[coeff, score] = pca(stack_v,'Economy','on','NumComponents',100);
imcomponents=reshape(coeff',100,size(stack,1),size(stack,2));
pcaimage=(squeeze(mean(abs(imcomponents(:,:,:)))));

assignin('base','pcaimage',pcaimage./max(max(pcaimage)))

disp('done');

vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)



% Update handles structure
guidata(hObject, handles);



function colormapTextEntry_Callback(hObject, eventdata, handles)
% hObject    handle to colormapTextEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of colormapTextEntry as text
%        str2double(get(hObject,'String')) returns contents of colormapTextEntry as a double


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

sliderValue = fix(get(handles.frameSlider,'Value'));
set(handles.frameTextEntry,'String', num2str(sliderValue));
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
% hObject    handle to frameTextEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frameTextEntry as text
%        str2double(get(hObject,'String')) returns contents of frameTextEntry as a double

% frame=get(hObject,'String');
% selections = get(handles.workspaceVarBox,'String');
% selectionsIndex = get(handles.workspaceVarBox,'Value');
% frameFromStack=evalin('base',[selections{selectionsIndex} '(:,:,' frame ')']);
% axes(handles.imageWindow);
% a = str2double(get(handles.lowCutEntry,'String'));
% b = str2double(get(handles.highCutEntry,'String'));
% 
% cMap=get(handles.colormapTextEntry,'String');
% 
% imshow(frameFromStack,[a b]);
% colormap(cMap)
% 
% assignin('base','currentImage',frameFromStack)

loadMeanProjectionButton_Callback(hObject, eventdata, handles)
% somaRoisDisplayToggle_Callback(hObject, eventdata, handles)




% Update handles structure
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
somaRoisDisplayToggle_Callback(hObject, eventdata, handles)

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
dendriteRoisDisplayToggle_Callback(hObject, eventdata, handles)

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
boutonRoisDisplayToggle_Callback(hObject, eventdata, handles)

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in vascularRoisDisplayToggle.
function vascularRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to vascularRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vascularRoisDisplayToggle


% --- Executes on button press in nnmfButton.
function nnmfButton_Callback(hObject, eventdata, handles)
% hObject    handle to nnmfButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function featureCountEntry_Callback(hObject, eventdata, handles)
% hObject    handle to featureCountEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of featureCountEntry as text
%        str2double(get(hObject,'String')) returns contents of featureCountEntry as a double


% --- Executes during object creation, after setting all properties.
function featureCountEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to featureCountEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
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
