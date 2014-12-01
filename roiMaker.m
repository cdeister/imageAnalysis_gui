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
% Latest Update: 11/30/2014 (more user friendly)
% Most Code: Chris Deister & Jakob Voigts
% Global XCor Code: Spencer Smith
%
% Questions: cdeister@brown.edu

% 
% Last Modified by GUIDE v2.5 30-Nov-2014 16:44:14

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
% hObject    handle to somaButton (see GCBO)
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

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in redSomaButton.
function redSomaButton_Callback(hObject, eventdata, handles)
% hObject    handle to redSomaButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in loadMeanProjectionButton.
function loadMeanProjectionButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadMeanProjectionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a = get(handles.lowCutEntry,'String');
b = get(handles.highCutEntry,'String');
lowCut=str2num(a)/65535;
highCut=str2num(b)/65535;

% set(handles.lowCutEntry,'String','0')
% set(handles.highCutEntry,'String','65535')

selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');

imageP=evalin('base',selections{selectionsIndex});
adjImage=imadjust(imageP,[lowCut highCut]);

axes(handles.imageWindow);
imshow(adjImage);

set(handles.lowCutEntry,'String',a)
set(handles.highCutEntry,'String',b)
assignin('base','currentImage',imageP)


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
vTr=get(handles.vesselRoisDisplayToggle, 'Value');

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
    vesselRoisDisplayToggle_Callback(handles.vesselRoisDisplayToggle,eventdata,handles)     
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
set(handles.vesselRoisDisplayToggle, 'Value', 0);


% --- Plot the image again
axes(handles.imageWindow);
imageP=evalin('base','currentImage');

aa = get(handles.lowCutEntry,'String');
bb = get(handles.highCutEntry,'String');
lowCut=str2num(aa)/65535;
highCut=str2num(bb)/65535;

adjImage=imadjust(imageP,[lowCut highCut]);

axes(handles.imageWindow);
imshow(adjImage);
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
hold all 
for n=1:numel(b)
    axes(handles.imageWindow);
    plot(b{1,n}{1,1}(:,2),b{1,n}{1,1}(:,1),'g','LineWidth',1)
    text(c{1,n}.Centroid(1)-1, c{1,n}.Centroid(2), num2str(n),'FontSize',10,'FontWeight','Bold','Color',[0 1 1]);
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
set(handles.vesselRoisDisplayToggle, 'Value', 0);


% --- Plot the image again
axes(handles.imageWindow);
imageP=evalin('base','currentImage');

aa = get(handles.lowCutEntry,'String');
bb = get(handles.highCutEntry,'String');
lowCut=str2num(aa)/65535;
highCut=str2num(bb)/65535;

adjImage=imadjust(imageP,[lowCut highCut]);

axes(handles.imageWindow);
imshow(adjImage);
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
set(handles.vesselRoisDisplayToggle, 'Value', 0);


% --- Plot the image again
axes(handles.imageWindow);
imageP=evalin('base','currentImage');
aa = get(handles.lowCutEntry,'String');
bb = get(handles.highCutEntry,'String');
lowCut=str2num(aa)/65535;
highCut=str2num(bb)/65535;

adjImage=imadjust(imageP,[lowCut highCut]);

axes(handles.imageWindow);
imshow(adjImage);
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

hold all    
for n=1:numel(b)
    plot(b{1,n}{1,1}(:,2),b{1,n}{1,1}(:,1),'g','LineWidth',1)
    text(c{1,n}.Centroid(1)-1, c{1,n}.Centroid(2), num2str(n),'FontSize',10,'FontWeight','Bold','Color',[0 1 1]);
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
set(handles.vesselRoisDisplayToggle, 'Value', 0);


% --- Plot the image again
axes(handles.imageWindow);
imageP=evalin('base','currentImage');
aa = get(handles.lowCutEntry,'String');
bb = get(handles.highCutEntry,'String');
lowCut=str2num(aa)/65535;
highCut=str2num(bb)/65535;

adjImage=imadjust(imageP,[lowCut highCut]);

axes(handles.imageWindow);
imshow(adjImage);
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
set(handles.vesselRoisDisplayToggle, 'Value', 0);


% --- Plot the image again
axes(handles.imageWindow);
imageP=evalin('base','currentImage');
aa = get(handles.lowCutEntry,'String');
bb = get(handles.highCutEntry,'String');
lowCut=str2num(aa)/65535;
highCut=str2num(bb)/65535;

adjImage=imadjust(imageP,[lowCut highCut]);

axes(handles.imageWindow);
imshow(adjImage);
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

hold all    
for n=1:numel(b)
    plot(b{1,n}{1,1}(:,2),b{1,n}{1,1}(:,1),'g','LineWidth',1)
    text(c{1,n}.Centroid(1)-1, c{1,n}.Centroid(2), num2str(n),'FontSize',10,'FontWeight','Bold','Color',[0 1 1]);
end
hold off

        
% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in vesselRoisDisplayToggle.
function vesselRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to vesselRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vesselRoisDisplayToggle
set(handles.somaRoisDisplayToggle, 'Value', 0);
set(handles.redSomaRoisDisplayToggle, 'Value', 0);
set(handles.dendriteRoisDisplayToggle, 'Value', 0);
set(handles.axonRoisDisplayToggle, 'Value', 0);
set(handles.boutonRoisDisplayToggle, 'Value', 0);
set(handles.vesselRoisDisplayToggle, 'Value', 1);


% --- Plot the image again
axes(handles.imageWindow);
imageP=evalin('base','currentImage');
aa = get(handles.lowCutEntry,'String');
bb = get(handles.highCutEntry,'String');
lowCut=str2num(aa)/65535;
highCut=str2num(bb)/65535;

adjImage=imadjust(imageP,[lowCut highCut]);

axes(handles.imageWindow);
imshow(adjImage);
% --- end image plot

h=evalin('base','vesselRoiCounter');
c=evalin('base','vesselROICenters');
b=evalin('base','vesselROIBoundaries');

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
a = get(handles.lowCutEntry,'String');
b = get(handles.highCutEntry,'String');
lowCut=str2num(a)/65535;
highCut=str2num(b)/65535;

adjImage=imadjust(imageP,[lowCut highCut]);

axes(handles.imageWindow);
imshow(adjImage);
% axes(handles.axes2);
% imhist(adjImage,100);
% --- end 

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
a = get(handles.lowCutEntry,'String');
b = get(handles.highCutEntry,'String');
lowCut=str2num(a)/65535;
highCut=str2num(b)/65535;
%gamA=str2num(get(handles.gammaBox,'String'));

adjImage=imadjust(imageP,[lowCut highCut]);

axes(handles.imageWindow);
imshow(adjImage);
% axes(handles.axes2);
% imhist(adjImage,100);
% --- end 


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
%gamA=str2double(get(handles.gammaBox,'String'));

adjImage=imadjust(imageP,[lowCut highCut]);

axes(handles.imageWindow);
imshow(adjImage);
% axes(handles.axes2);
% imhist(adjImage,100);
% --- end 


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
% axes(handles.axes2);
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

% parameters
tempImage=evalin('base','currentImage');
aspectR=[size(tempImage,1),size(tempImage,2)];
sR=evalin('base','somaticROIs');
sR_PL=evalin('base','somaticROI_PixelLists');
pxSpred = str2double(get(handles.neuropilPixelSpreadEntry,'String'));
seDisk=strel('disk',pxSpred);

% We will make individual masks for each roi and then dilate by a specific
% number of pixels.


for n=1:numel(sR)
    neuropilROIs{1,n}=imdilate(sR{1,n},seDisk);
    neuropilROIBoundaries{1,n}=bwboundaries(neuropilROIs{1,n});
    neuropilROICenters{1,n}=regionprops(neuropilROIs{1,n},'Centroid');
    neuropilROI_PixelLists{1,n}=regionprops(neuropilROIs{1,n},'PixelList');
    neuropilROI_PixelLists{1,n}=neuropilROI_PixelLists{1,n}.PixelList;
    sR_PL{1,n}=sR_PL{1,n}.PixelList;
end

% Find and Subtract Overlap Between a Particular Neuropil Mask and ROI mask
for n=1:numel(sR)
    for h=1:numel(sR)
    % loop through each cell and look for overlap between all cells
    neuropilROI_PixelLists{1,n}=setdiff(neuropilROI_PixelLists{1,n},sR_PL{1,h},'rows');
    end
end

% Draw the annulus
for n=1:numel(sR),
        neuropilROIs{1,n}=false(aspectR(1),aspectR(2));
        for h=1:size(neuropilROI_PixelLists{1,n},1)
            neuropilROIs{1,n}(neuropilROI_PixelLists{1,n}(h,2),neuropilROI_PixelLists{1,n}(h,1))=1;
        end
    neuropilROIBoundaries{1,n}=bwboundaries(neuropilROIs{1,n});
end

assignin('base','neuropilROIs',neuropilROIs)
assignin('base','neuropilROI_PixelLists',neuropilROI_PixelLists)
assignin('base','neuropilROIBoundaries',neuropilROIBoundaries)


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



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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

for n=1:nstack;
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

% make local Xcorr and/or PCA (CAD: I removed PCA for now, I will give option to users if someone asks)
% xcor image code ----> adapted from http://labrigger.com/blog/2013/06/13/local-cross-corr-images/


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
% hObject    handle to gXCorSmoothToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gXCorSmoothToggle


% --- Executes on button press in playStackMovButton.
function playStackMovButton_Callback(hObject, eventdata, handles)
% hObject    handle to playStackMovButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Toggle the play state of the movie with wonky code
playState=1;
assignin('base','playState',playState)


% play the movie
sstack=evalin('base','sstack');
axes(handles.imageWindow);
mfactor=.35;

a = get(handles.lowCutEntry,'String');
b = get(handles.highCutEntry,'String');
lowCut=str2double(a);
highCut=str2double(b);



ii=1;
    for i=1:size(sstack,3)
        pS=evalin('base','playState');
        if pS==1
            ii=(ii.*(1-mfactor))+sstack(:,:,i).*mfactor;
            h=imagesc(ii,[lowCut highCut]);
            % axis off;
            drawnow;
            delete(h);
        elseif pS==0
            ii=(ii.*(1-mfactor))+sstack(:,:,i).*mfactor;
            imagesc(ii,[lowCut highCut]);
            % axes(handles.imageWindow);
            assignin('base','currentImage',im2uint16(ii,'Indexed'))
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
xc(ceil(y),ceil(x))=0.11; % seed
it=1;
    while it<50
        sig=find(xc>0.04);
        mask=I.*0; mask(sig)=1;
        mask=conv2(mask,ones(5),'same')>0;
        update=find((xc==0).*(mask==1));
        if numel(update)<1
            it=500;
        end
        for fillin=update' % fill in where we detected any corr >.1s
            [a,b]=ind2sub(size(I),fillin);
            c=corrcoef(squeeze(sstack(a,b,:)),ref);
            xc(a,b)=c(2,1);
        end
        it=it+1;
    end

localCorMaskPlot=(1-mask).*I./10+ ((xc*200));
imagesc(localCorMaskPlot),axis off, colorbar
colormap jet
currentImage=localCorMaskPlot;
assignin('base','currentImage',uint16(localCorMaskPlot))
daspect([1 1 1]);

% Update handles structure
guidata(hObject, handles);

