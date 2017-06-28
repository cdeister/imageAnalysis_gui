function varargout = annotater(varargin)
% ANNOTATER MATLAB code for annotater.fig
%      ANNOTATER, by itself, creates a new ANNOTATER or raises the existing
%      singleton*.
%
%      H = ANNOTATER returns the handle to a new ANNOTATER or the handle to
%      the existing singleton*.
%
%      ANNOTATER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANNOTATER.M with the given input arguments.
%
%      ANNOTATER('Property','Value',...) creates a new ANNOTATER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before annotater_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to annotater_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help annotater

% Last Modified by GUIDE v2.5 04-Jun-2015 12:12:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @annotater_OpeningFcn, ...
                   'gui_OutputFcn',  @annotater_OutputFcn, ...
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


% --- Executes just before annotater is made visible.
function annotater_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to annotater (see VARARGIN)

% Choose default command line output for annotater
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes annotater wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = annotater_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function imageToggle_Callback(hObject, eventdata, handles)
% hObject    handle to imageToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function imageToggle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imageToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in f1_button.
function f1_button_Callback(hObject, eventdata, handles)
% hObject    handle to f1_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[tx,ty] = ginput();
imageToDisplay=str2num(get(handles.imageCountEntry,'String'));

assignin('base','tempX1',tx(end));
assignin('base','tempY1',ty(end));
evalin('base',['x1_positions(' num2str(imageToDisplay) ',:)=tempX1;'])
evalin('base',['y1_positions(' num2str(imageToDisplay) ',:)=tempY1;'])


axes(handles.imageWindow);
hold all,plot(tx,ty,'bo')
daspect([1 1 1])

% Update handles structure
guidata(hObject, handles);




% --- Executes on button press in f2_button.
function f2_button_Callback(hObject, eventdata, handles)
% hObject    handle to f2_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[tx,ty] = ginput();
imageToDisplay=str2num(get(handles.imageCountEntry,'String'));

assignin('base','tempX2',tx(end));
assignin('base','tempY2',ty(end));
evalin('base',['x2_positions(' num2str(imageToDisplay) ',:)=tempX2;'])
evalin('base',['y2_positions(' num2str(imageToDisplay) ',:)=tempY2;'])

axes(handles.imageWindow);
hold all,plot(tx,ty,'ro')
daspect([1 1 1])

set(handles.imageCountEntry,'String',num2str(imageToDisplay+1))
imageCountEntry_Callback(hObject, eventdata, handles)


% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in f3_button.
function f3_button_Callback(hObject, eventdata, handles)
% hObject    handle to f3_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[tx,ty] = ginput();
imageToDisplay=str2num(get(handles.imageCountEntry,'String'));

assignin('base','tempX3',tx(end));
assignin('base','tempY3',ty(end));
evalin('base',['x3_positions(' num2str(imageToDisplay) ',:)=tempX3;'])
evalin('base',['y3_positions(' num2str(imageToDisplay) ',:)=tempY3;'])

axes(handles.imageWindow);
hold all,plot(tx,ty,'mo')
daspect([1 1 1])

% Update handles structure
guidata(hObject, handles);



function imageCountEntry_Callback(hObject, eventdata, handles)
% hObject    handle to imageCountEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of imageCountEntry as text
%        str2double(get(hObject,'String')) returns contents of imageCountEntry as a double
selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
importStack=evalin('base',selections{selectionsIndex});
numImages=size(importStack,3);

imageToDisplay=str2num(get(handles.imageCountEntry,'String'));

axes(handles.imageWindow);
imagesc(importStack(:,:,imageToDisplay)')
colormap gray
daspect([1 1 1])

plotF1Dots=evalin('base','exist(''tempX1'')');
plotF2Dots=evalin('base','exist(''tempX2'')');
plotF3Dots=evalin('base','exist(''tempX3'')');

if plotF1Dots
    xDot1=evalin('base','tempX1');
    yDot1=evalin('base','tempY1');
    hold all,plot(xDot1,yDot1,'bo');
end
if plotF2Dots
    xDot2=evalin('base','tempX2');
    yDot2=evalin('base','tempY2');
    hold all,plot(xDot2,yDot2,'ro');
end
if plotF3Dots
    xDot3=evalin('base','tempX3');
    yDot3=evalin('base','tempY3');
    hold all,plot(xDot3,yDot3,'mo');
end



% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function imageCountEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imageCountEntry (see GCBO)
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


% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
importStack=evalin('base',selections{selectionsIndex});
numImages=size(importStack,3);

imageToDisplay=str2num(get(handles.imageCountEntry,'String'));

axes(handles.imageWindow);
imagesc(importStack(:,:,imageToDisplay)')
colormap gray
daspect([1 1 1])


% Update handles structure
guidata(hObject, handles);


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


% --- Executes on button press in dittoButton.
function dittoButton_Callback(hObject, eventdata, handles)
% hObject    handle to dittoButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


plotF1Dots=evalin('base','exist(''tempX1'')');
plotF2Dots=evalin('base','exist(''tempX2'')');
plotF3Dots=evalin('base','exist(''tempX3'')');

imageToDisplay=str2num(get(handles.imageCountEntry,'String'));

if plotF1Dots
    evalin('base',['x1_positions(' num2str(imageToDisplay) ',:)=tempX1;'])
    evalin('base',['y1_positions(' num2str(imageToDisplay) ',:)=tempY1;'])
end
if plotF2Dots
    evalin('base',['x2_positions(' num2str(imageToDisplay) ',:)=tempX2;'])
    evalin('base',['y2_positions(' num2str(imageToDisplay) ',:)=tempY2;'])
end
if plotF3Dots
    evalin('base',['x3_positions(' num2str(imageToDisplay) ',:)=tempX3;'])
    evalin('base',['y3_positions(' num2str(imageToDisplay) ',:)=tempY3;'])
end

set(handles.imageCountEntry,'String',num2str(imageToDisplay+1))
imageCountEntry_Callback(hObject, eventdata, handles)

% Update handles structure
guidata(hObject, handles);

