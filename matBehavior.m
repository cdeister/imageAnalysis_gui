function varargout = matBehavior(varargin)
% MATBEHAVIOR MATLAB code for matBehavior.fig
%      MATBEHAVIOR, by itself, creates a new MATBEHAVIOR or raises the existing
%      singleton*.
%
%      H = MATBEHAVIOR returns the handle to a new MATBEHAVIOR or the handle to
%      the existing singleton*.
%
%      MATBEHAVIOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MATBEHAVIOR.M with the given input arguments.
%
%      MATBEHAVIOR('Property','Value',...) creates a new MATBEHAVIOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before matBehavior_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to matBehavior_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help matBehavior

% Last Modified by GUIDE v2.5 08-Feb-2019 07:01:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @matBehavior_OpeningFcn, ...
                   'gui_OutputFcn',  @matBehavior_OutputFcn, ...
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


% --- Executes just before matBehavior is made visible.
function matBehavior_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to matBehavior (see VARARGIN)

% Choose default command line output for matBehavior
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes matBehavior wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = matBehavior_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




function btn_loadSession_Callback(hObject, eventdata, handles)

    
    [aa,bb]=uigetfile('*.mat');
    load([bb aa] ,'session')
    assignin('base','session',session);
    evalin('base','getBehavioralStuff')
%     evalin('base',load([bb aa],'session'))
%     set(handles.nameEntry,'String',bdFileNames)
    guidata(hObject, handles);


function nameEntry_Callback(hObject, eventdata, handles)


function nameEntry_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function btn_loadTrialData_Callback(hObject, eventdata, handles)


function btn_filterTrials_Callback(hObject, eventdata, handles)


function edit5_Callback(hObject, eventdata, handles)


function edit5_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit6_Callback(hObject, eventdata, handles)


function edit6_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function preStimLickTimeEntry_Callback(hObject, eventdata, handles)


function preStimLickTimeEntry_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
