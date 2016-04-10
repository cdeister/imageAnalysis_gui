
function varargout = eventInspector(varargin)
% EVENTINSPECTOR MATLAB code for eventInspector.fig
% eventInspector is a very simple (incomplete) but effective extraction tool.
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



% Last Modified by GUIDE v2.5 09-Apr-2016 23:11:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @eventInspector_OpeningFcn, ...
                   'gui_OutputFcn',  @eventInspector_OutputFcn, ...
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

% --- Executes just before eventInspector is made visible.
function eventInspector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to eventInspector (see VARARGIN)

% Choose default command line output for eventInspector
handles.output = hObject;

vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes eventInspector wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = eventInspector_OutputFcn(hObject, eventdata, handles) 
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

updateTracePlot_Callback(hObject, eventdata, handles)


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

updateTracePlot_Callback(hObject, eventdata, handles)


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
traceDimensions=numel(size(traces));

dimensionIntent = get(handles.flipXY_Toggle,'Value');
if dimensionIntent
    traces=traces';
else
end

tnum=str2double(get(handles.displayedROICounter,'String'));
tempTrialNum=str2double(get(handles.displayedTrialCounter,'String'));

% --- $$$$ ---- Update/Initialize Sliders
% @@@@@@ ROIS
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

% @@@@@@ TRIALS
tempTrialNum=str2double(get(handles.displayedTrialCounter,'String'));

trialSliderMin = 1;
trialSliderMax = str2num(get(handles.stimTime_trialCountEntry,'String')); % this is variable
if (trialSliderMax - trialSliderMin)>0
    trialSliderStep = [1, 1] / (trialSliderMax - trialSliderMin); % major and minor steps of 1
    set(handles.trialDisplaySlider, 'Enable', 'On');
else
    set(handles.trialDisplaySlider, 'Enable', 'Off');
    trialSliderStep = [1, 1];
end


set(handles.trialDisplaySlider, 'Min', trialSliderMin);
set(handles.trialDisplaySlider, 'Max', trialSliderMax);
set(handles.trialDisplaySlider, 'SliderStep', trialSliderStep);
if tempTrialNum<=trialSliderMax
    set(handles.trialDisplaySlider, 'Value', tempTrialNum); % set to beginning of sequence
    set(handles.displayedTrialCounter,'String', num2str(tempTrialNum));
else
    set(handles.trialDisplaySlider, 'Value', trialSliderMin); % set to beginning of sequence
    tempTrialNum=1;
    set(handles.displayedTrialCounter,'String', '1');
end



% ^^^^^^^^^ DONE

xCount=size(traces(tnum,:),2);

if get(handles.plotTimingToggle_Time,'Value');
    tDel=str2num(get(handles.imTime_frameIntervalEntry,'String'));
    tV=(tDel/2:tDel:xCount*tDel-(tDel/2));
else
    tV=1:xCount;
end

axes(handles.traceDisplay);
plot(tV,traces(tnum,:));

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in flagROIButton.
function flagROIButton_Callback(hObject, eventdata, handles)
% hObject    handle to flagROIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dataToFlag=evalin('base','scratch.loadedData');
flagString=['flagged_rois_' dataToFlag];
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

updateTracePlot_Callback(hObject, eventdata, handles)

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in traceWriteButton.
function traceWriteButton_Callback(hObject, eventdata, handles)
% hObject    handle to traceWriteButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updateTracePlotWithSave_Callback(hObject, eventdata, handles)
updateTracePlot_Callback(hObject, eventdata, handles)

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in flipXY_Toggle.
function flipXY_Toggle_Callback(hObject, eventdata, handles)
% hObject    handle to flipXY_Toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flipXY_Toggle
set(handles.plotAsTrialsToggle, 'Value',0);
set(handles.plotTimingToggle_Frame, 'Value',1);
set(handles.plotTimingToggle_Time, 'Value',0);

updateRoiSlider_Callback(hObject, eventdata, handles)
updateTracePlot_Callback(hObject, eventdata, handles)

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in refreshVarListButton.
function refreshVarListButton_Callback(hObject, eventdata, handles)
% hObject    handle to refreshVarListButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in assignStimTimes.
function assignStimTimes_Callback(hObject, eventdata, handles)
% hObject    handle to assignStimTimes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
selectTimes=selections{selectionsIndex};
selectTimesT=evalin('base',selectTimes);
assignin('base','stimesTemp',selectTimesT);
evalin('base','scratch.stimTimes=stimesTemp;,clear stimesTemp')

set(handles.stimTime_trialCountEntry,'String',numel(selectTimesT));
stimTime_trialCountEntry_Callback(hObject,eventdata,handles)

updateTrialSlider_Callback(hObject, eventdata, handles)

% Update handles structure
guidata(hObject, handles);


% --- Executes on slider movement.
function trialDisplaySlider_Callback(hObject, eventdata, handles)
% hObject    handle to trialDisplaySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

trialSliderValue = get(handles.trialDisplaySlider,'Value');
set(handles.displayedTrialCounter,'String', num2str(trialSliderValue));

updateTracePlot_Callback(hObject, eventdata, handles)


% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function trialDisplaySlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trialDisplaySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function displayedTrialCounter_Callback(hObject, eventdata, handles)
% hObject    handle to displayedTrialCounter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of displayedTrialCounter as text
%        str2double(get(hObject,'String')) returns contents of displayedTrialCounter as a double


input = str2num(get(hObject,'String'));

%checks to see if input is empty. if so, default input1_editText to zero
if (isempty(input))
     set(hObject,'String','1')
end

set(handles.trialDisplaySlider,'Value',input);

updateTracePlot_Callback(hObject, eventdata, handles)



% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function displayedTrialCounter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displayedTrialCounter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in flagTrialButton.
function flagTrialButton_Callback(hObject, eventdata, handles)
% hObject    handle to flagTrialButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dataToFlag=evalin('base','scratch.loadedData');
flagString=['flagged_trials_' dataToFlag];
prevAt=evalin('base',['exist(''' flagString ''',''var'')']);

trialToFlag=str2num(get(handles.displayedTrialCounter,'String'));

if prevAt
    tFD=evalin('base',flagString);
    tFD(end+1)=trialToFlag;
    tFD=unique(tFD);
    assignin('base',flagString,tFD);
else
    assignin('base',flagString,trialToFlag);
end


% Update handles structure
guidata(hObject, handles);



function frameDimension_Callback(hObject, eventdata, handles)
% hObject    handle to frameDimension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frameDimension as text
%        str2double(get(hObject,'String')) returns contents of frameDimension as a double


% --- Executes during object creation, after setting all properties.
function frameDimension_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameDimension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function trialDimension_Callback(hObject, eventdata, handles)
% hObject    handle to trialDimension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trialDimension as text
%        str2double(get(hObject,'String')) returns contents of trialDimension as a double


% --- Executes during object creation, after setting all properties.
function trialDimension_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trialDimension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cellDimension_Callback(hObject, eventdata, handles)
% hObject    handle to cellDimension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cellDimension as text
%        str2double(get(hObject,'String')) returns contents of cellDimension as a double


% --- Executes during object creation, after setting all properties.
function cellDimension_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cellDimension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function imTime_frameIntervalEntry_Callback(hObject, eventdata, handles)
% hObject    handle to imTime_frameIntervalEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of imTime_frameIntervalEntry as text
%        str2double(get(hObject,'String')) returns contents of imTime_frameIntervalEntry as a double


% --- Executes during object creation, after setting all properties.
function imTime_frameIntervalEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imTime_frameIntervalEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stimTime_samplingRateEntry_Callback(hObject, eventdata, handles)
% hObject    handle to stimTime_samplingRateEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stimTime_samplingRateEntry as text
%        str2double(get(hObject,'String')) returns contents of stimTime_samplingRateEntry as a double


% --- Executes during object creation, after setting all properties.
function stimTime_samplingRateEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stimTime_samplingRateEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function imTime_framesPerTrialEntry_Callback(hObject, eventdata, handles)
% hObject    handle to imTime_framesPerTrialEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of imTime_framesPerTrialEntry as text
%        str2double(get(hObject,'String')) returns contents of imTime_framesPerTrialEntry as a double


% --- Executes during object creation, after setting all properties.
function imTime_framesPerTrialEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imTime_framesPerTrialEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in timingFromStruct.
function timingFromStruct_Callback(hObject, eventdata, handles)
% hObject    handle to timingFromStruct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
selectStack=selections{selectionsIndex};

timeInfo=evalin('base',selectStack);

if isfield(timeInfo,'frameInterval')
    set(handles.imTime_frameIntervalEntry,'String', num2str(timeInfo.frameIntervalSingle,'% .2g'));
else
end

if isfield(timeInfo,'framesPerTrial')
    set(handles.imTime_framesPerTrialEntry,'String', num2str(timeInfo.framesPerTrial));
else
end

if isfield(timeInfo,'sessionRate')
    set(handles.stimTime_samplingRateEntry,'String', num2str(timeInfo.sessionRate));
else
end

updateTracePlot_Callback(hObject, eventdata, handles)


% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in plotTimingToggle_Frame.
function plotTimingToggle_Frame_Callback(hObject, eventdata, handles)
% hObject    handle to plotTimingToggle_Frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plotTimingToggle_Frame

set(handles.stimTimeToggle,'Value',0);
set(handles.stimTimeToggle,'ForegroundColor',[0.5 0.5 0.5]);
set(handles.stimTimeToggle,'Enable','Inactive');
set(handles.plotTimingToggle_Time,'Value',0);

updateTracePlot_Callback(hObject, eventdata, handles)


% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in plotTimingToggle_Time.
function plotTimingToggle_Time_Callback(hObject, eventdata, handles)
% hObject    handle to plotTimingToggle_Time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plotTimingToggle_Time

set(handles.stimTimeToggle,'ForegroundColor',[0 0 0]);
set(handles.stimTimeToggle,'Enable','On');
set(handles.plotTimingToggle_Frame,'Value',0);

updateTracePlot_Callback(hObject, eventdata, handles)

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in stimTimeToggle.
function stimTimeToggle_Callback(hObject, eventdata, handles)
% hObject    handle to stimTimeToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stimTimeToggle

updateTracePlot_Callback(hObject, eventdata, handles)

% Update handles structure
guidata(hObject, handles);



function stimTime_trialCountEntry_Callback(hObject, eventdata, handles)
% hObject    handle to stimTime_trialCountEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stimTime_trialCountEntry as text
%        str2double(get(hObject,'String')) returns contents of stimTime_trialCountEntry as a double

updateTrialSlider_Callback(hObject, eventdata, handles)
updateTracePlot_Callback(hObject, eventdata, handles)



% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function stimTime_trialCountEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stimTime_trialCountEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plotAsTrialsToggle.
function plotAsTrialsToggle_Callback(hObject, eventdata, handles)
% hObject    handle to plotAsTrialsToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plotAsTrialsToggle

updateTracePlot_Callback(hObject, eventdata, handles)

% Update handles structure
guidata(hObject, handles);


% &&&&& @@@@ $$$$$$ GLOBAL CALLBACKS $$$$$$ @@@@ &&&&&

% Callback for trace plot update
function updateTracePlot_Callback(hObject, eventdata, handles)


framesPerTrialT=str2num(get(handles.imTime_framesPerTrialEntry,'String'));
frameIntervalT=str2double(get(handles.imTime_frameIntervalEntry,'String'));
frameIntervalT=.03310588;       % todo: this shouldn't be hardcoded
singleImageTrialTimeEnd=framesPerTrialT*frameIntervalT;
stimTimesT=evalin('base','scratch.stimTimes');
stimTimesT2=evalin('base','scratch.stimTimes');

trialTimesT=8*ones(size(stimTimesT));   % todo: the 8 shouldn't be hardcoded
trialTimesT(1)=0;
stimTimesT=cumsum(trialTimesT)+stimTimesT;

corStimTimesForPlot=stimTimesT;

assignin('base','corContStimTimesT',corStimTimesForPlot);
evalin('base','scratch.corContStimTimes=corContStimTimesT;,clear corContStimTimesT')

stackName=evalin('base','scratch.loadedData');
traces=evalin('base',stackName);
traceDimensions=numel(size(traces));


dimensionIntent = get(handles.flipXY_Toggle,'Value');
if dimensionIntent
    traces=traces';
else
end

tnum=str2double(get(handles.displayedROICounter,'String'));
tempTrialNum=str2double(get(handles.displayedTrialCounter,'String'));

xCount=size(traces(tnum,:),2);

if get(handles.plotTimingToggle_Time,'Value');
    tDel=str2num(get(handles.imTime_frameIntervalEntry,'String'));
    tV=(tDel/2:tDel:xCount*tDel-(tDel/2));
else
    tV=1:xCount;
end

plotAsTrialsVal=get(handles.plotAsTrialsToggle, 'Value');
sTr=get(handles.traceSmoothToggle, 'Value');

tempT=traces(tnum,:)';
if sTr
    tempT=batchSmooth(tempT);
else
end

if plotAsTrialsVal
    traceStart=1+((tempTrialNum-1)*framesPerTrialT);
    tempT=tempT(traceStart:traceStart+(framesPerTrialT-1));
    corStimTimesForPlot=stimTimesT2(tempTrialNum);
    if get(handles.plotTimingToggle_Time,'Value');
        tDel=str2num(get(handles.imTime_frameIntervalEntry,'String'));
        tV=(tDel/2:tDel:framesPerTrialT*tDel-(tDel/2));
    else
        tV=1:framesPerTrialT;
end
else
end

axes(handles.traceDisplay);
plot(tV,tempT)
if get(handles.stimTimeToggle,'value')
    hold all
    for n=1:numel(corStimTimesForPlot)
        plot([corStimTimesForPlot(n) corStimTimesForPlot(n)],[min(tempT),max(tempT)],'k:')
    end
    hold off
else
end

% Update handles structure
guidata(hObject, handles);

% Callback to update roiSlider
function updateRoiSlider_Callback(hObject, eventdata, handles)


stackName=evalin('base','scratch.loadedData');
traces=evalin('base',stackName);
traceDimensions=numel(size(traces));


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



% Update handles structure
guidata(hObject, handles);

% Callback for trace plot update
function updateTrialSlider_Callback(hObject, eventdata, handles)



tempTrialNum=str2double(get(handles.displayedTrialCounter,'String'));

trialSliderMin = 1;
trialSliderMax = str2num(get(handles.stimTime_trialCountEntry,'String')); % this is variable
if (trialSliderMax - trialSliderMin)>0
    trialSliderStep = [1, 1] / (trialSliderMax - trialSliderMin); % major and minor steps of 1
    set(handles.trialDisplaySlider, 'Enable', 'On');
else
    set(handles.trialDisplaySlider, 'Enable', 'Off');
    trialSliderStep = [1, 1];
end


set(handles.trialDisplaySlider, 'Min', trialSliderMin);
set(handles.trialDisplaySlider, 'Max', trialSliderMax);
set(handles.trialDisplaySlider, 'SliderStep', trialSliderStep);
if tempTrialNum<=trialSliderMax
    set(handles.trialDisplaySlider, 'Value', tempTrialNum); % set to beginning of sequence
    set(handles.displayedTrialCounter,'String', num2str(tempTrialNum));
else
    set(handles.trialDisplaySlider, 'Value', trialSliderMin); % set to beginning of sequence
    tempTrialNum=1;
    set(handles.displayedTrialCounter,'String', '1');
end



% Update handles structure
guidata(hObject, handles);



% Callback for trace plot update with save out
function updateTracePlotWithSave_Callback(hObject, eventdata, handles)


framesPerTrialT=str2num(get(handles.imTime_framesPerTrialEntry,'String'));
frameIntervalT=str2double(get(handles.imTime_frameIntervalEntry,'String'));
frameIntervalT=.03310588;       % todo: this shouldn't be hardcoded
singleImageTrialTimeEnd=framesPerTrialT*frameIntervalT;
stimTimesT=evalin('base','scratch.stimTimes');
stimTimesT2=evalin('base','scratch.stimTimes');

trialTimesT=8*ones(size(stimTimesT));   % todo: the 8 shouldn't be hardcoded
trialTimesT(1)=0;
stimTimesT=cumsum(trialTimesT)+stimTimesT;

corStimTimesForPlot=stimTimesT;

assignin('base','corContStimTimesT',corStimTimesForPlot);
evalin('base','scratch.corContStimTimes=corContStimTimesT;,clear corContStimTimesT')

stackName=evalin('base','scratch.loadedData');
traces=evalin('base',stackName);
traceDimensions=numel(size(traces));


dimensionIntent = get(handles.flipXY_Toggle,'Value');
if dimensionIntent
    traces=traces';
else
end

tnum=str2double(get(handles.displayedROICounter,'String'));
tempTrialNum=str2double(get(handles.displayedTrialCounter,'String'));

xCount=size(traces(tnum,:),2);

if get(handles.plotTimingToggle_Time,'Value');
    tDel=str2num(get(handles.imTime_frameIntervalEntry,'String'));
    tV=(tDel/2:tDel:xCount*tDel-(tDel/2));
else
    tV=1:xCount;
end

plotAsTrialsVal=get(handles.plotAsTrialsToggle, 'Value');
sTr=get(handles.traceSmoothToggle, 'Value');

tempT=traces(tnum,:)';
if sTr
    tempT=batchSmooth(tempT);
else
end

% save block
% if the xy toggle is on, then flip before you save.
if dimensionIntent
    tempT=tempT';
    assignin('base','tempT',tempT);
    evalin('base',[stackName '(:,' num2str(tnum) ')=tempT;,clear tempT'])
else
    assignin('base','tempT',tempT);
    evalin('base',[stackName '(' num2str(tnum) ',:)=tempT;,clear tempT'])
end


if plotAsTrialsVal
    traceStart=1+((tempTrialNum-1)*framesPerTrialT);
    tempT=tempT(traceStart:traceStart+(framesPerTrialT-1));
    corStimTimesForPlot=stimTimesT2(tempTrialNum);
    if get(handles.plotTimingToggle_Time,'Value');
        tDel=str2num(get(handles.imTime_frameIntervalEntry,'String'));
        tV=(tDel/2:tDel:framesPerTrialT*tDel-(tDel/2));
    else
        tV=1:framesPerTrialT;
end
else
end

axes(handles.traceDisplay);
plot(tV,tempT)
if get(handles.stimTimeToggle,'value')
    hold all
    for n=1:numel(corStimTimesForPlot)
        plot([corStimTimesForPlot(n) corStimTimesForPlot(n)],[min(tempT),max(tempT)],'k:')
    end
    hold off
else
end

% Update handles structure
guidata(hObject, handles);






