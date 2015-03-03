function varargout = traceProcessor(varargin)
% TRACEPROCESSOR MATLAB code for traceProcessor.fig
%      TRACEPROCESSOR, by itself, creates a new TRACEPROCESSOR or raises the existing
%      singleton*.
%
%      H = TRACEPROCESSOR returns the handle to a new TRACEPROCESSOR or the handle to
%      the existing singleton*.
%
%      TRACEPROCESSOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACEPROCESSOR.M with the given input arguments.
%
%      TRACEPROCESSOR('Property','Value',...) creates a new TRACEPROCESSOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before traceProcessor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to traceProcessor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help traceProcessor

% Last Modified by GUIDE v2.5 17-Feb-2015 10:14:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @traceProcessor_OpeningFcn, ...
                   'gui_OutputFcn',  @traceProcessor_OutputFcn, ...
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


% --- Executes just before traceProcessor is made visible.
function traceProcessor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to traceProcessor (see VARARGIN)

% Choose default command line output for traceProcessor
handles.output = hObject;

% Load Workspace Variables
vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes traceProcessor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = traceProcessor_OutputFcn(hObject, eventdata, handles) 
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

tnum=str2double(get(handles.displayedROICounter,'String'));
axes(handles.traceDisplay);
plot(traces(:,tnum));

axes(handles.histogramDisplay);
nhist(traces(:,tnum),'box');

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



function displayedROICounter_Callback(hObject, eventdata, handles)
% hObject    handle to displayedROICounter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of displayedROICounter as text
%        str2double(get(hObject,'String')) returns contents of displayedROICounter as a double


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

traces=evalin('base',selectStack);

tnum=str2double(get(handles.displayedROICounter,'String'));

% set slider steps ----
sliderMin = 1;
sliderMax = size(traces,2); % this is variable
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
% end slider steps ---

% start plot code ---
axes(handles.traceDisplay);
plot(traces(:,tnum));

axes(handles.histogramDisplay);
nhist(traces(:,tnum),'box');
% end plot code ---

% Update handles structure
guidata(hObject, handles);



function quantileEntry_Callback(hObject, eventdata, handles)
% hObject    handle to quantileEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of quantileEntry as text
%        str2double(get(hObject,'String')) returns contents of quantileEntry as a double


% --- Executes during object creation, after setting all properties.
function quantileEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to quantileEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in acceptDataButton.
function acceptDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to acceptDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function windowSizeEntry_Callback(hObject, eventdata, handles)
% hObject    handle to windowSizeEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of windowSizeEntry as text
%        str2double(get(hObject,'String')) returns contents of windowSizeEntry as a double


% --- Executes during object creation, after setting all properties.
function windowSizeEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to windowSizeEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
