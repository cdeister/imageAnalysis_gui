
function varargout = roiInspector(varargin)
% ROIINSPECTOR MATLAB code for roiInspector.fig
% roiInspector is a very simple (incomplete) but effective extraction tool.
% it will load any number of tif files from disk and extract F values from
% defined ROI types (made in roiMaker).
%
% This will be improved soon to give options to control parallelization,
% image types etc.
%
% Note: This used to detect the images in a folder you point to after
% selecting disk extract. I removed this due to a weird edge case bug. 
% So for now, you have to manually define the image range.
%
% Code by: Chris Deister
% Questions: cdeister@brown.edu



% Last Modified by GUIDE v2.5 09-Apr-2016 13:23:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @roiInspector_OpeningFcn, ...
                   'gui_OutputFcn',  @roiInspector_OutputFcn, ...
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

% TODO List:

% --- Executes just before roiInspector is made visible.
function roiInspector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to roiInspector (see VARARGIN)

% Choose default command line output for roiInspector
handles.output = hObject;

vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes roiInspector wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = roiInspector_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;





% --- Executes on slider movement.
function roiDisplaySlider_Callback(hObject, eventdata, handles)
% hObject    handle to roiDisplaySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider



sliderValue = get(handles.roiDisplaySlider,'Value');
set(handles.displayedROICounter,'String', num2str(sliderValue));

selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
selectStack=selections{selectionsIndex};

traces=evalin('base',selectStack);

dimensionIntent = get(handles.flipXY_Toggle,'Value');
if dimensionIntent
    traces=traces';
else
end

tnum=str2double(get(handles.displayedROICounter,'String'));
axes(handles.traceDisplay);
sTr=get(handles.traceSmoothToggle, 'Value');
if sTr
    tempT=traces(tnum,:)';
    plot(batchSmooth(tempT))
else
plot(traces(tnum,:));
end

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function roiDisplaySlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roiDisplaySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function displayedROICounter_Callback(hObject, eventdata, handles)
% hObject    handle to displayedROICounter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of displayedROICounter as text
%        str2double(get(hObject,'String')) returns contents of displayedROICounter as a double
input = str2num(get(hObject,'String'));

%checks to see if input is empty. if so, default input1_editText to zero
if (isempty(input))
     set(hObject,'String','1')
end

set(handles.roiDisplaySlider,'Value',input);

if sTr
    traces=evalin('base','somaticF')';
elseif nTr
    traces=evalin('base','neuropilF')';
elseif bTr
    traces=evalin('base','boutonF')';
elseif dTr
    traces=evalin('base','dendriticF')';
end

dimensionIntent = get(handles.flipXY_Toggle,'Value');
if dimensionIntent
    traces=traces';
else
end

tnum=str2double(get(handles.displayedROICounter,'String'));
axes(handles.traceDisplay);
plot(traces(tnum,:));

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function displayedROICounter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displayedROICounter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in loadDataButton.
function loadDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
selectStack=selections{selectionsIndex};

assignin('base',[selectStack '_t'],selectStack)
evalin('base',['scratch.loadedData=' selectStack '_t;'])
evalin('base',['clear ' selectStack '_t;']);

traces=evalin('base',selectStack);

dimensionIntent = get(handles.flipXY_Toggle,'Value');
if dimensionIntent
    traces=traces';
else
end

tnum=str2double(get(handles.displayedROICounter,'String'));


sliderMin = 1;
sliderMax = size(traces,1); % this is variable
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

axes(handles.traceDisplay);
plot(traces(tnum,:));

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in flagROIButton.
function flagROIButton_Callback(hObject, eventdata, handles)
% hObject    handle to flagROIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dataToFlag=evalin('base','scratch.loadedData');
flagString=['flagged_' dataToFlag];
prevAt=evalin('base',['exist(''' flagString ''',''var'')']);

roiToFlag=str2num(get(handles.displayedROICounter,'String'));

if prevAt
    tFD=evalin('base',flagString);
    tFD(end+1)=roiToFlag;
    tFD=unique(tFD);
    assignin('base',flagString,tFD);
else
    assignin('base',flagString,roiToFlag);
end


% Update handles structure
guidata(hObject, handles);

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


% --- Executes on button press in traceSmoothToggle.
function traceSmoothToggle_Callback(hObject, eventdata, handles)
% hObject    handle to traceSmoothToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of traceSmoothToggle

sliderValue = get(handles.roiDisplaySlider,'Value');
set(handles.displayedROICounter,'String', num2str(sliderValue));

selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
selectStack=selections{selectionsIndex};

traces=evalin('base',selectStack);

dimensionIntent = get(handles.flipXY_Toggle,'Value');
if dimensionIntent
    traces=traces';
else
end

tnum=str2double(get(handles.displayedROICounter,'String'));
axes(handles.traceDisplay);
sTr=get(handles.traceSmoothToggle, 'Value');
if sTr
    tempT=traces(tnum,:)';
    plot(batchSmooth(tempT))
else
plot(traces(tnum,:));
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in traceWriteButton.
function traceWriteButton_Callback(hObject, eventdata, handles)
% hObject    handle to traceWriteButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sliderValue = get(handles.roiDisplaySlider,'Value');
set(handles.displayedROICounter,'String', num2str(sliderValue));

selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
selectStack=selections{selectionsIndex};

traces=evalin('base',selectStack);

dimensionIntent = get(handles.flipXY_Toggle,'Value');
if dimensionIntent
    traces=traces';
else
end

tnum=str2double(get(handles.displayedROICounter,'String'));
axes(handles.traceDisplay);
sTr=get(handles.traceSmoothToggle, 'Value');
if sTr
    tempT=traces(tnum,:)';
    tempT=batchSmooth(tempT)';
    
    % if the xy toggle is on, then flip before you save.
    if dimensionIntent
        tempT=tempT';
        assignin('base','tempT',tempT);
        evalin('base',[selectStack '(:,' num2str(tnum) ')=tempT;,clear tempT'])
    else
        assignin('base','tempT',tempT);
        evalin('base',[selectStack '(' num2str(tnum) ',:)=tempT;,clear tempT'])
    end
else
    evalin('base',[]);
end


traces=evalin('base',selectStack);

if dimensionIntent
    traces=traces';
else
end

tnum=str2double(get(handles.displayedROICounter,'String'));
axes(handles.traceDisplay);
sTr=get(handles.traceSmoothToggle, 'Value');
if sTr
    tempT=traces(tnum,:)';
    plot(batchSmooth(tempT))
else
plot(traces(tnum,:));
end


% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in flipXY_Toggle.
function flipXY_Toggle_Callback(hObject, eventdata, handles)
% hObject    handle to flipXY_Toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flipXY_Toggle


% --- Executes on button press in refreshVarListButton.
function refreshVarListButton_Callback(hObject, eventdata, handles)
% hObject    handle to refreshVarListButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)

% Update handles structure
guidata(hObject, handles);
