function varargout = eventParser(varargin)
% EVENTPARSER MATLAB code for eventParser.fig
%      EVENTPARSER, by itself, creates a new EVENTPARSER or raises the existing
%      singleton*.
%
%      H = EVENTPARSER returns the handle to a new EVENTPARSER or the handle to
%      the existing singleton*.
%
%      EVENTPARSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EVENTPARSER.M with the given input arguments.
%
%      EVENTPARSER('Property','Value',...) creates a new EVENTPARSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before eventParser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to eventParser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help eventParser

% Last Modified by GUIDE v2.5 27-Apr-2019 14:10:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @eventParser_OpeningFcn, ...
                   'gui_OutputFcn',  @eventParser_OutputFcn, ...
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


% --- Executes just before eventParser is made visible.
function eventParser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to eventParser (see VARARGIN)

% Choose default command line output for eventParser
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes eventParser wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = eventParser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function curCell_Callback(hObject, eventdata, handles)

axes(handles.axes1)
cellNum = str2num(get(handles.curCell,'String'));
plotDeconvolvedCell(cellNum)




function curCell_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
