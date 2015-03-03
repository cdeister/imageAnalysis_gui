function varargout = behaviorParser(varargin)
% BEHAVIORPARSER MATLAB code for behaviorParser.fig
%      BEHAVIORPARSER, by itself, creates a new BEHAVIORPARSER or raises the existing
%      singleton*.
%
%      H = BEHAVIORPARSER returns the handle to a new BEHAVIORPARSER or the handle to
%      the existing singleton*.
%
%      BEHAVIORPARSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BEHAVIORPARSER.M with the given input arguments.
%
%      BEHAVIORPARSER('Property','Value',...) creates a new BEHAVIORPARSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before behaviorParser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to behaviorParser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help behaviorParser

% Last Modified by GUIDE v2.5 16-Oct-2014 07:59:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @behaviorParser_OpeningFcn, ...
                   'gui_OutputFcn',  @behaviorParser_OutputFcn, ...
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


% --- Executes just before behaviorParser is made visible.
function behaviorParser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to behaviorParser (see VARARGIN)

% Choose default command line output for behaviorParser
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes behaviorParser wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = behaviorParser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function frameIntervalEntry_Callback(hObject, eventdata, handles)
% hObject    handle to frameIntervalEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frameIntervalEntry as text
%        str2double(get(hObject,'String')) returns contents of frameIntervalEntry as a double


% --- Executes during object creation, after setting all properties.
function frameIntervalEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameIntervalEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function framesPerTrialEntry_Callback(hObject, eventdata, handles)
% hObject    handle to framesPerTrialEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of framesPerTrialEntry as text
%        str2double(get(hObject,'String')) returns contents of framesPerTrialEntry as a double


% --- Executes during object creation, after setting all properties.
function framesPerTrialEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to framesPerTrialEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sessionLoadButton.
function sessionLoadButton_Callback(hObject, eventdata, handles)
% hObject    handle to sessionLoadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% loads the session in the workspace
[sF,sP]=uigetfile;
assignin('base','session_Path',sP);
assignin('base','session_Name',sF);
evalin('base','load([session_Path filesep session_Name])')

% mark/count the trials we actually performed
sTr=evalin('base','session.start_trial');
eTr=evalin('base','session.current_trial')+sTr;

% print the value in gui
set(handles.firstTrialEntry,'String',sTr+1); 
set(handles.endTrialEntry,'String',eTr); 
set(handles.trialCountStatic,'String',eTr-sTr); 


% Update handles structure
guidata(hObject, handles);





function endTrialEntry_Callback(hObject, eventdata, handles)
% hObject    handle to endTrialEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endTrialEntry as text
%        str2double(get(hObject,'String')) returns contents of endTrialEntry as a double

eTr=str2num(get(handles.endTrialEntry,'String'));
sTr=str2num(get(handles.firstTrialEntry,'String'));
set(handles.trialCountStatic,'String',1+(eTr-sTr)); 

% update slider
sliderMin = sTr;
sliderMax = eTr; 
sliderStep = [1, 1] / (sliderMax - sliderMin); % major and minor steps of 1

set(handles.trialSlider, 'Min', sliderMin);
set(handles.trialSlider, 'Max', sliderMax);
set(handles.trialSlider, 'SliderStep', sliderStep);
set(handles.trialSlider, 'Value', sliderMin); % set to beginning of sequence

set(handles.trialToDisplayEntry,'String',sliderMin);

% update plot
tnum=get(handles.trialToDisplayEntry,'String');
cnum1=str2double(get(handles.channelToDisplayEntry,'String'));
cnum2=str2double(get(handles.channelToDisplay2Entry,'String'));
sP=evalin('base','session_Path');

a=load([sP 'trial_' tnum]);
dt=1/evalin('base','session.Hz');
tTime=0:dt:(numel(a.data(:,1))-1)*dt;

axes(handles.dataDisplay);
plot(tTime,a.data(:,cnum1))
hold all,plot(tTime,a.data(:,cnum2)),hold off

clear('a')


% Update handles structure
guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function endTrialEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endTrialEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function firstTrialEntry_Callback(hObject, eventdata, handles)
% hObject    handle to firstTrialEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of firstTrialEntry as text
%        str2double(get(hObject,'String')) returns contents of firstTrialEntry as a double
eTr=str2num(get(handles.endTrialEntry,'String'));
sTr=str2num(get(handles.firstTrialEntry,'String'));
set(handles.trialCountStatic,'String',1+(eTr-sTr)); 

% update slider
sliderMin = sTr;
sliderMax = eTr; 
sliderStep = [1, 1] / (sliderMax - sliderMin); % major and minor steps of 1

set(handles.trialSlider, 'Min', sliderMin);
set(handles.trialSlider, 'Max', sliderMax);
set(handles.trialSlider, 'SliderStep', sliderStep);
set(handles.trialSlider, 'Value', sliderMin); % set to beginning of sequence

set(handles.trialToDisplayEntry,'String',sliderMin);

% update plot
tnum=get(handles.trialToDisplayEntry,'String');
cnum1=str2double(get(handles.channelToDisplayEntry,'String'));
cnum2=str2double(get(handles.channelToDisplay2Entry,'String'));
sP=evalin('base','session_Path');

a=load([sP 'trial_' tnum]);
dt=1/evalin('base','session.Hz');
tTime=0:dt:(numel(a.data(:,1))-1)*dt;

axes(handles.dataDisplay);
plot(tTime,a.data(:,cnum1))
hold all,plot(tTime,a.data(:,cnum2)),hold off

clear('a')




% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function firstTrialEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to firstTrialEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function trialSlider_Callback(hObject, eventdata, handles)
% hObject    handle to trialSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% set(handles.stackSlider, 'Value', sliderMin); % set to beginning of sequence

sliderValue = get(handles.trialSlider,'Value');
set(handles.trialToDisplayEntry,'String', num2str(sliderValue));

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function trialSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trialSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function trialToDisplayEntry_Callback(hObject, eventdata, handles)
% hObject    handle to trialToDisplayEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trialToDisplayEntry as text
%        str2double(get(hObject,'String')) returns contents of trialToDisplayEntry as a double


tnum=get(handles.trialToDisplayEntry,'String');
cnum1=str2double(get(handles.channelToDisplayEntry,'String'));
cnum2=str2double(get(handles.channelToDisplay2Entry,'String'));
sP=evalin('base','session_Path');

a=load([sP 'trial_' tnum]);
dt=1/evalin('base','session.Hz');
tTime=0:dt:(numel(a.data(:,1))-1)*dt;

axes(handles.dataDisplay);
plot(tTime,a.data(:,cnum1))
hold all,plot(tTime,a.data(:,cnum2)),hold off

clear('a')

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function trialToDisplayEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trialToDisplayEntry (see GCBO)
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



function channelToDisplayEntry_Callback(hObject, eventdata, handles)
% hObject    handle to channelToDisplayEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channelToDisplayEntry as text
%        str2double(get(hObject,'String')) returns contents of channelToDisplayEntry as a double

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function channelToDisplayEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelToDisplayEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function channelToDisplay2Entry_Callback(hObject, eventdata, handles)
% hObject    handle to channelToDisplay2Entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channelToDisplay2Entry as text
%        str2double(get(hObject,'String')) returns contents of channelToDisplay2Entry as a double


% --- Executes during object creation, after setting all properties.
function channelToDisplay2Entry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelToDisplay2Entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sessionAppendMetaButton.
function sessionAppendMetaButton_Callback(hObject, eventdata, handles)
% hObject    handle to sessionAppendMetaButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fIntVal=str2num(get(handles.frameIntervalEntry,'String'));
fTriVal=str2num(get(handles.framesPerTrialEntry,'String'));
ballDiamVal=str2num(get(handles.ballDiameterEntry,'String'));

if fIntVal>0
    assignin('base','fIntVal',fIntVal);
    evalin('base','session.frameInterval=fIntVal;');
    evalin('base','clear(''fIntVal'')');
else
end

if fTriVal>0
    assignin('base','fTriVal',fTriVal);
    evalin('base','session.framesPerTrial=fTriVal;');
    evalin('base','clear(''fTriVal'')');
else
end

if ballDiamVal>0
    assignin('base','ballDiamVal',ballDiamVal);
    evalin('base','session.ballDiameter=ballDiamVal;');
    evalin('base','clear(''ballDiamVal'')');
else
end



% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in countFramesButton.
function countFramesButton_Callback(hObject, eventdata, handles)
% hObject    handle to countFramesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sP=evalin('base','session_Path');

fChanNum=str2double(get(handles.frameChannelEntry,'String'));

eTr=str2num(get(handles.endTrialEntry,'String'));
sTr=str2num(get(handles.firstTrialEntry,'String'));

for tnum=sTr:eTr;
    a=load([sP 'trial_' num2str(tnum)]);
    fCnt(:,(tnum-sTr)+1)=numel(find(diff(a.data(:,fChanNum))>2));
end

% use a threhsold of less than a 1/4 of the mean?
suspectTrials=find(fCnt<mean(fCnt)/4);
disp(suspectTrials+(sTr-1))

if numel(suspectTrials)>1
    set(handles.framelessTrialWarningStatic,'ForegroundColor',[1,0.1,0])
    set(handles.framelessTrialWarningStatic,'String',[num2str(numel(suspectTrials)) ' Frameless Trials Found!'])
else
        set(handles.framelessTrialWarningStatic,'ForegroundColor',[0,0.6,0])
        set(handles.framelessTrialWarningStatic,'String','All Good!')

end

assignin('base','frameCount',fCnt);
assignin('base','suspectTrials',suspectTrials);
evalin('base','session.frameCount=frameCount;');
evalin('base','session.suspectTrials=suspectTrials;');
evalin('base','clear(''frameCount'')');
evalin('base','clear(''suspectTrials'')');



% Update handles structure
guidata(hObject, handles);



function frameChannelEntry_Callback(hObject, eventdata, handles)
% hObject    handle to frameChannelEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frameChannelEntry as text
%        str2double(get(hObject,'String')) returns contents of frameChannelEntry as a double


% --- Executes during object creation, after setting all properties.
function frameChannelEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameChannelEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in getVelocityButton.
function getVelocityButton_Callback(hObject, eventdata, handles)
% hObject    handle to getVelocityButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sP=evalin('base','session_Path');

rChanNum=str2double(get(handles.runningChannelEntry,'String'));
bDiam=str2double(get(handles.ballDiameterEntry,'String'));
sR=evalin('base','session.Hz');

eTr=str2num(get(handles.endTrialEntry,'String'));
sTr=str2num(get(handles.firstTrialEntry,'String'));

disp('... parsing running data')


for tnum=sTr:eTr;
    a=load([sP 'trial_' num2str(tnum)]);
    [steps(:,(tnum-sTr)+1),interStepIntervals(:,(tnum-sTr)+1),acceleration(:,(tnum-sTr)+1),velocity(:,(tnum-sTr)+1)]=...
        getSpeeds2(a.data(:,rChanNum),bDiam,sR,1024);
    % todo: 1024 is quad range, make this user selectable
    % samp rate (sR) should be user modifiable too
    % (:,(tnum-sTr)+1)
end

disp('... running parsed')

assignin('base','steps',steps);
assignin('base','interStepIntervals',interStepIntervals);
assignin('base','acceleration',acceleration);
assignin('base','velocity',velocity);
evalin('base','session.steps=steps;');
evalin('base','session.interStepIntervals=interStepIntervals;');
evalin('base','session.acceleration=acceleration;');
evalin('base','session.velocity=velocity;');
evalin('base','clear(''velocity'')');
evalin('base','clear(''acceleration'')');
evalin('base','clear(''interStepIntervals'')');
evalin('base','clear(''steps'')');

% Update handles structure
guidata(hObject, handles);





function runningChannelEntry_Callback(hObject, eventdata, handles)
% hObject    handle to runningChannelEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of runningChannelEntry as text
%        str2double(get(hObject,'String')) returns contents of runningChannelEntry as a double


% --- Executes during object creation, after setting all properties.
function runningChannelEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to runningChannelEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in refreshSesInfoButton.
function refreshSesInfoButton_Callback(hObject, eventdata, handles)
% hObject    handle to refreshSesInfoButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% mark/count the trials we actually performed
sTr=evalin('base','session.start_trial');
eTr=evalin('base','session.current_trial')+sTr;
fIntVal=evalin('base','session.frameInterval');
fTriVal=evalin('base','session.framesPerTrial');
ballDiamVal=evalin('base','session.ballDiameter');



% print the value in gui
set(handles.firstTrialEntry,'String',sTr+1); 
set(handles.endTrialEntry,'String',eTr); 
set(handles.trialCountStatic,'String',eTr-sTr); 
set(handles.frameIntervalEntry,'String',fIntVal); 
set(handles.framesPerTrialEntry,'String',fTriVal); 
set(handles.ballDiameterEntry,'String',ballDiamVal); 




function ballDiameterEntry_Callback(hObject, eventdata, handles)
% hObject    handle to ballDiameterEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ballDiameterEntry as text
%        str2double(get(hObject,'String')) returns contents of ballDiameterEntry as a double


% --- Executes during object creation, after setting all properties.
function ballDiameterEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ballDiameterEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in makeTimeVectorsButton.
function makeTimeVectorsButton_Callback(hObject, eventdata, handles)
% hObject    handle to makeTimeVectorsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fT=str2num(get(handles.firstTrialEntry,'String')); 
lT=str2num(get(handles.endTrialEntry,'String')); 
trialCount= lT-fT;
fI=get(handles.frameIntervalEntry,'String'); 
fPT=get(handles.framesPerTrialEntry,'String'); 
sesR=eval('base','session.Hz');
sesD=eval('base','session.Hz');

twoPTrialTime=0:fI:(fPT-1)*fI;
% sessionTrialTime=0:1/sesRate:
