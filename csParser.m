% csParser (alpha)

function varargout = csParser(varargin)

  gui_Singleton = 1;
  gui_State = struct('gui_Name',       mfilename, ...
                     'gui_Singleton',  gui_Singleton, ...
                     'gui_OpeningFcn', @csParser_OpeningFcn, ...
                     'gui_OutputFcn',  @csParser_OutputFcn, ...
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
function csParser_OpeningFcn(hObject, eventdata, handles, varargin)

  handles.output = hObject;
  
  guidata(hObject, handles);
function varargout = csParser_OutputFcn(hObject, eventdata, handles) 
  
  varargout{1} = handles.output;



function hdfDataPopup_Callback(hObject, eventdata, handles)
function hdfDataPopup_CreateFcn(hObject, eventdata, handles)

  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
  end
function loadHDFButton_Callback(hObject, eventdata, handles)
  [hdfName,hdfPath]=uigetfile('*','what what?');
  try
      behavHDFPath=[hdfPath hdfName];
      behavHDFInfo=h5info(behavHDFPath);
      curDatasetPath=['/' behavHDFInfo.Datasets.Name];
      curBData=h5read(behavHDFPath,curDatasetPath);
      % attributes have int32 encoding and need to be converted.
      curOrientations=double(h5readatt(behavHDFPath,curDatasetPath,'orientations')).*10;
      curContrasts=double(h5readatt(behavHDFPath,curDatasetPath,'contrasts'))/10;
      % The way csVisual is set now, we end up with an extra trial's metadata.
      % So, I trim here.
      curOrientations=curOrientations(1:end-1);
      curContrasts=curContrasts(1:end-1);
      assignin('base','curOrientations',curOrientations);
      evalin('base',['bData.curOrientations=curOrientations;,clear curOrientations ans'])
      assignin('base','curContrasts',curContrasts);
      evalin('base',['bData.curContrasts=curContrasts;,clear curContrasts ans'])
      assignin('base','interrupts',curBData(1,:));
      evalin('base',['bData.interrupts=interrupts;,clear interrupts ans'])
      assignin('base','sessionTime',curBData(2,:)./1000);
      evalin('base',['bData.sessionTime=sessionTime;,clear sessionTime ans'])
      assignin('base','stateTime',curBData(3,:)./1000);
      evalin('base',['bData.stateTime=stateTime;,clear stateTime ans'])
      assignin('base','states',curBData(4,:));
      evalin('base',['bData.states=states;,clear states ans'])
      assignin('base','pyStates',curBData(5,:));
      evalin('base',['bData.pyStates=pyStates;,clear pyStates ans'])
      assignin('base','tLick0',curBData(6,:));
      evalin('base',['bData.tLick0=tLick0;,clear tLick0 ans'])
      assignin('base','tLick1',curBData(7,:));
      evalin('base',['bData.tLick1=tLick1;,clear tLick1 ans'])
      assignin('base','thrLicks',curBData(8,:));
      evalin('base',['bData.thrLicks=thrLicks;,clear thrLicks ans'])
      assignin('base','motion',curBData(9,:));
      evalin('base',['bData.motion=motion;,clear motion ans'])
      position=decodeShaftEncoder(curBData(9,:),4);
      velocity=nPointDeriv(position,curBData(2,:),1000);
      velocity(find(isnan(velocity)==1))=0;
      assignin('base','position',position);
      evalin('base',['bData.position=position;,clear position ans'])
      assignin('base','velocity',velocity);
      evalin('base',['bData.velocity=velocity;,clear velocity ans'])



      assignin('base','motion',curBData(9,:));
      evalin('base',['bData.motion=motion;,clear motion ans'])
  
  catch
  end



% --- Executes on button press in sendToWSButton.
function sendToWSButton_Callback(hObject, eventdata, handles)
% hObject    handle to sendToWSButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
