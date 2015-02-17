
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



% Last Modified by GUIDE v2.5 01-Feb-2015 08:58:17

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


% --- Executes on button press in somaExtractCheck.
function somaExtractCheck_Callback(hObject, eventdata, handles)
% hObject    handle to somaExtractCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of somaExtractCheck


% --- Executes on button press in dendriteExtractCheck.
function dendriteExtractCheck_Callback(hObject, eventdata, handles)
% hObject    handle to dendriteExtractCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dendriteExtractCheck


% --- Executes on button press in axonExtractCheck.
function axonExtractCheck_Callback(hObject, eventdata, handles)
% hObject    handle to axonExtractCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of axonExtractCheck


% --- Executes on button press in boutonExtractCheck.
function boutonExtractCheck_Callback(hObject, eventdata, handles)
% hObject    handle to boutonExtractCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of boutonExtractCheck

% --- Executes on button press in diskExtractButton.
function diskExtractButton_Callback(hObject, eventdata, handles)
% hObject    handle to diskExtractButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% currently 60 ms per image for ~150 typical ROIs from a USB3 drive.
% ~ .0004 per roi per image
imPath=evalin('base','importPath');
fileList=evalin('base','filteredFiles');
skipImagesToggle=get(handles.diskExtractSkipByToggle,'Value');

if skipImagesToggle
    st=str2num(get(handles.diskExtractSkipByStartEntry,'String'));
    by=str2num(get(handles.diskExtractSkipByEntry,'String'));
    a=st;
    if st>by
        a=rem(st,by);
    else
    end
    en=numel(fileList)-(by-a);
    fileList=fileList(st:by:en);
else
end
disp(['after skiping you will extract from ' num2str(numel(fileList)) ' images'])


if get(handles.somaExtractCheck,'Value')==1;
   % rois=[evalin('base','somaticROIs')];
    rois=[evalin('base','somaticROIs') evalin('base','dendriticROIs')];
else
    disp('no rois')
end


numImages=numel(fileList);  %todo: this is a place holder to fix the entry.
sED=zeros(numel(rois),numImages);
regFlag=get(handles.diskRegFlag,'Value');

if regFlag==0
disp(['about to extract, this should take ~ ' num2str((numel(rois)*.0004*numImages)./60) ' minutes'])
cc=clock;
disp(['started at ' num2str(cc(4)) ':'  num2str(cc(5))])
tic
disp('extracting')
diskLuminance=zeros(1,numImages);
for n=1:numImages
    impImage=imread([imPath filesep fileList(n).name]);
    diskLuminance(:,n)=mean2(impImage);
    for q=1:numel(rois)
        sED(q,n)=mean(impImage(rois{q}(:,:)));
    end
    if (rem(n,100)==0)
        fprintf('%d/%d (%d%%)\n',n,numImages,round(100*(n./numImages)));
    end
end
eT=toc;
assignin('base','diskLuminance',diskLuminance);
disp(['done extracting, this took ' num2str(eT./60) ' minutes'])

elseif regFlag==1
disp(['about to extract, this should take ~ ' num2str((numel(rois)*.0008*numImages)./60) ' minutes'])
cc=clock;
disp(['started at ' num2str(cc(4)) ':'  num2str(cc(5))])
tic
template=evalin('base','regTemplate');
disp('extracting')
registeredTransformations=zeros(4,numImages);
diskLuminance=zeros(1,numImages);
for n=1:numImages
    impImage=imread([imPath filesep fileList(n).name]);
    [out1,out2]=dftregistration(fft2(template),fft2(impImage),100);
    registeredTransformations(:,n)=out1;
    diskLuminance(:,n)=mean2(impImage);
    regImage=abs(ifft2(out2));
    for q=1:numel(rois)
        sED(q,n)=mean(regImage(rois{q}(:,:)));
    end
    if (rem(n,100)==0)
        fprintf('%d/%d (%d%%)\n',n,numImages,round(100*(n./numImages)));
    end
end
assignin('base','registeredTransformations',registeredTransformations);
assignin('base','diskLuminance',diskLuminance);
eT=toc;
disp(['done extracting, this took ' num2str(eT./60) ' minutes'])

end


assignin('base','somaticF',sED)

% Update handles structure
guidata(hObject, handles);







% --- Executes on button press in extractButton.
function extractButton_Callback(hObject, eventdata, handles)
% hObject    handle to extractButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.extractButton,'string','running','ForegroundColor','red','enable','off');

disp('*** extracting now, wait a bit ...')

selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
selectStack=selections{selectionsIndex};

if get(handles.somaExtractCheck, 'Value')==1;
    tic
    sRois=evalin('base','somaticROIs');
    dStack=double(evalin('base',selectStack));
    sED=zeros(numel(sRois),size(dStack,3));
    for n=1:size(dStack,3)
        for q=1:numel(sRois)
            aIm=dStack(:,:,n);
            sED(q,n)=mean(aIm(sRois{q}(:,:)));
        end
    end
    assignin('base','somaticF',sED)
    disp('somas extracted')
    toc 
end

if get(handles.neuropilExtractCheck, 'Value')==1;
    tic
    sRois=evalin('base','neuropilROIs');
    dStack=double(evalin('base',selectStack));
    sED=zeros(numel(sRois),size(dStack,3));
    for n=1:size(dStack,3)
        for q=1:numel(sRois)
            aIm=dStack(:,:,n);
            sED(q,n)=mean(aIm(sRois{q}(:,:)));
        end
    end
    assignin('base','neuropilF',sED)
    disp('neuropil extracted')
    toc   
end

if get(handles.boutonExtractCheck, 'Value')==1;
    tic
    sRois=evalin('base','boutonROIs');
    dStack=double(evalin('base',selectStack));
    sED=zeros(numel(sRois),size(dStack,3));
    for n=1:size(dStack,3)
        for q=1:numel(sRois)
            aIm=dStack(:,:,n);
            sED(q,n)=mean(aIm(sRois{q}(:,:)));
        end
    end
    assignin('base','boutonF',sED)
    disp('boutons extracted')
    toc 
end

if get(handles.dendriteExtractCheck, 'Value')==1;
    tic
    sRois=evalin('base','dendriticROIs');
    dStack=double(evalin('base',selectStack));
    sED=zeros(numel(sRois),size(dStack,3));
    for n=1:size(dStack,3)
        for q=1:numel(sRois)
            aIm=dStack(:,:,n);
            sED(q,n)=mean(aIm(sRois{q}(:,:)));
        end
    end
    assignin('base','dendriticF',sED)
    disp('dendrites extracted')
    toc    
end

disp('*** done extracting now, go have fun')

set(handles.extractButton,'string','Extract','ForegroundColor','black','enable','on');

% Update handles structure

set(handles.extractButton,'string','Extract','ForegroundColor','black','enable','on');
% Update handles structure
guidata(hObject, handles);

% --- Executes on slider movement.
function roiDisplaySlider_Callback(hObject, eventdata, handles)
% hObject    handle to roiDisplaySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sTr=get(handles.somaRoisDisplayToggle, 'Value');
nTr=get(handles.neuropilRoisDisplayToggle, 'Value');
bTr=get(handles.boutonRoisDisplayToggle, 'Value');
dTr=get(handles.dendriteRoisDisplayToggle, 'Value');
npTr=get(handles.dfDisplayToggle,'Value');
cnpTr=get(handles.npCorDfDispToggle,'Value');

sliderValue = get(handles.roiDisplaySlider,'Value');
set(handles.displayedROICounter,'String', num2str(sliderValue));

if sTr
    traces=evalin('base','somaticF');
elseif nTr
    traces=evalin('base','neuropilF');
elseif bTr
    traces=evalin('base','boutonF');
elseif dTr
    traces=evalin('base','dendriticF');
elseif npTr
    traces=evalin('base','traces.dfs');
elseif cnpTr
    traces=evalin('base','traces.dfs_npc');
end
tnum=str2double(get(handles.displayedROICounter,'String'));
axes(handles.traceDisplay);
plot(traces(tnum,:));
if npTr || cnpTr 
    ylim([-0.5 6.5])
else
    ylim([0 9000])
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


% --- Executes on button press in somaRoisDisplayToggle.
function somaRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to somaRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of somaRoisDisplayToggle

set(handles.neuropilRoisDisplayToggle, 'Value', 0);
set(handles.filledSomaRoisDisplayToggle, 'Value', 0);
set(handles.vascularRoisDisplayToggle, 'Value', 0);
set(handles.boutonRoisDisplayToggle, 'Value', 0);
set(handles.axonRoisDisplayToggle, 'Value', 0);
set(handles.dendriteRoisDisplayToggle, 'Value', 0);
set(handles.somaRoisDisplayToggle, 'Value', 1);
set(handles.filledNeuropilRoisDisplayToggle, 'Value', 0);
set(handles.dfDisplayToggle, 'Value', 0);
set(handles.npCorDfDispToggle,'Value',0);


traces=evalin('base','somaticF');
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
ylim([0 9000])

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in dendriteRoisDisplayToggle.
function dendriteRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to dendriteRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dendriteRoisDisplayToggle

set(handles.neuropilRoisDisplayToggle, 'Value', 0);
set(handles.filledSomaRoisDisplayToggle, 'Value', 0);
set(handles.vascularRoisDisplayToggle, 'Value', 0);
set(handles.boutonRoisDisplayToggle, 'Value', 0);
set(handles.axonRoisDisplayToggle, 'Value', 0);
set(handles.dendriteRoisDisplayToggle, 'Value', 1);
set(handles.somaRoisDisplayToggle, 'Value', 0);
set(handles.filledNeuropilRoisDisplayToggle, 'Value', 0);
set(handles.dfDisplayToggle, 'Value', 0);
set(handles.npCorDfDispToggle,'Value',0);

traces=evalin('base','dendriticF');

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
ylim([0 9000])



% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in axonRoisDisplayToggle.
function axonRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to axonRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of axonRoisDisplayToggle
set(handles.neuropilRoisDisplayToggle, 'Value', 0);
set(handles.filledSomaRoisDisplayToggle, 'Value', 0);
set(handles.vascularRoisDisplayToggle, 'Value', 0);
set(handles.boutonRoisDisplayToggle, 'Value', 0);
set(handles.axonRoisDisplayToggle, 'Value', 1);
set(handles.dendriteRoisDisplayToggle, 'Value', 0);
set(handles.somaRoisDisplayToggle, 'Value', 0);
set(handles.filledNeuropilRoisDisplayToggle, 'Value', 0);
set(handles.dfDisplayToggle, 'Value', 0);
set(handles.npCorDfDispToggle,'Value',0);

traces=evalin('base','axonalF');
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
ylim([0 9000])

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in boutonRoisDisplayToggle.
function boutonRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to boutonRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of boutonRoisDisplayToggle
set(handles.neuropilRoisDisplayToggle, 'Value', 0);
set(handles.filledSomaRoisDisplayToggle, 'Value', 0);
set(handles.vascularRoisDisplayToggle, 'Value', 0);
set(handles.boutonRoisDisplayToggle, 'Value', 1);
set(handles.axonRoisDisplayToggle, 'Value', 0);
set(handles.dendriteRoisDisplayToggle, 'Value', 0);
set(handles.somaRoisDisplayToggle, 'Value', 0);
set(handles.filledNeuropilRoisDisplayToggle, 'Value', 0);
set(handles.dfDisplayToggle, 'Value', 0);
set(handles.npCorDfDispToggle,'Value',0);

traces=evalin('base','boutonF');
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
ylim([0 9000])


% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in vascularRoisDisplayToggle.
function vascularRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to vascularRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vascularRoisDisplayToggle
set(handles.neuropilRoisDisplayToggle, 'Value', 0);
set(handles.filledSomaRoisDisplayToggle, 'Value', 0);
set(handles.vascularRoisDisplayToggle, 'Value', 1);
set(handles.boutonRoisDisplayToggle, 'Value', 0);
set(handles.axonRoisDisplayToggle, 'Value', 0);
set(handles.dendriteRoisDisplayToggle, 'Value', 0);
set(handles.somaRoisDisplayToggle, 'Value', 0);
set(handles.filledNeuropilRoisDisplayToggle, 'Value', 0);
set(handles.dfDisplayToggle, 'Value', 0);
set(handles.npCorDfDispToggle,'Value',0);

traces=evalin('base','vascularF');
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
ylim([0 9000])

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in filledSomaRoisDisplayToggle.
function filledSomaRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to filledSomaRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of filledSomaRoisDisplayToggle

set(handles.neuropilRoisDisplayToggle, 'Value', 0);
set(handles.filledSomaRoisDisplayToggle, 'Value', 1);
set(handles.vascularRoisDisplayToggle, 'Value', 0);
set(handles.boutonRoisDisplayToggle, 'Value', 0);
set(handles.axonRoisDisplayToggle, 'Value', 0);
set(handles.dendriteRoisDisplayToggle, 'Value', 0);
set(handles.somaRoisDisplayToggle, 'Value', 0);
set(handles.filledNeuropilRoisDisplayToggle, 'Value', 0);
set(handles.dfDisplayToggle, 'Value', 0);
set(handles.npCorDfDispToggle,'Value',0);

traces=evalin('base','filledSomaticF');
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
ylim([0 9000])

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in filledNeuropilRoisDisplayToggle.
function filledNeuropilRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to filledNeuropilRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of filledNeuropilRoisDisplayToggle

set(handles.neuropilRoisDisplayToggle, 'Value', 0);
set(handles.filledSomaRoisDisplayToggle, 'Value', 0);
set(handles.vascularRoisDisplayToggle, 'Value', 0);
set(handles.boutonRoisDisplayToggle, 'Value', 0);
set(handles.axonRoisDisplayToggle, 'Value', 0);
set(handles.dendriteRoisDisplayToggle, 'Value', 0);
set(handles.somaRoisDisplayToggle, 'Value', 0);
set(handles.filledNeuropilRoisDisplayToggle, 'Value', 1);
set(handles.dfDisplayToggle, 'Value', 0);
set(handles.npCorDfDispToggle,'Value',0);

traces=evalin('base','filledNeuropilF');
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
ylim([0 9000])

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in neuropilRoisDisplayToggle.
function neuropilRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to neuropilRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of neuropilRoisDisplayToggle

set(handles.neuropilRoisDisplayToggle, 'Value', 1);
set(handles.filledSomaRoisDisplayToggle, 'Value', 0);
set(handles.vascularRoisDisplayToggle, 'Value', 0);
set(handles.boutonRoisDisplayToggle, 'Value', 0);
set(handles.axonRoisDisplayToggle, 'Value', 0);
set(handles.dendriteRoisDisplayToggle, 'Value', 0);
set(handles.somaRoisDisplayToggle, 'Value', 0);
set(handles.filledNeuropilRoisDisplayToggle, 'Value', 1);
set(handles.dfDisplayToggle, 'Value', 0);
set(handles.npCorDfDispToggle,'Value',0);


traces=evalin('base','neuropilF');
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
ylim([0 9000])

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in filledSomaExtractCheck.
function filledSomaExtractCheck_Callback(hObject, eventdata, handles)
% hObject    handle to filledSomaExtractCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of filledSomaExtractCheck


% --- Executes on button press in filledNeuropilExtractCheck.
function filledNeuropilExtractCheck_Callback(hObject, eventdata, handles)
% hObject    handle to filledNeuropilExtractCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of filledNeuropilExtractCheck


% --- Executes on button press in neuropilExtractCheck.
function neuropilExtractCheck_Callback(hObject, eventdata, handles)
% hObject    handle to neuropilExtractCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of neuropilExtractCheck


% --- Executes on button press in vascularExtractCheck.
function vascularExtractCheck_Callback(hObject, eventdata, handles)
% hObject    handle to vascularExtractCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vascularExtractCheck



function firstImageEntry_Callback(hObject, eventdata, handles)
% hObject    handle to firstImageEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of firstImageEntry as text
%        str2double(get(hObject,'String')) returns contents of firstImageEntry as a double


% --- Executes during object creation, after setting all properties.
function firstImageEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to firstImageEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function endImageEntry_Callback(hObject, eventdata, handles)
% hObject    handle to dasd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dasd as text
%        str2double(get(hObject,'String')) returns contents of dasd as a double

% --- Executes during object creation, after setting all properties.
function endImageEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to firstImageEntry (see GCBO)
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


% --- Executes on button press in dfDisplayToggle.
function dfDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to dfDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dfDisplayToggle
set(handles.neuropilRoisDisplayToggle, 'Value', 0);
set(handles.filledSomaRoisDisplayToggle, 'Value', 0);
set(handles.vascularRoisDisplayToggle, 'Value', 0);
set(handles.boutonRoisDisplayToggle, 'Value', 0);
set(handles.axonRoisDisplayToggle, 'Value', 0);
set(handles.dendriteRoisDisplayToggle, 'Value', 0);
set(handles.somaRoisDisplayToggle, 'Value', 0);
set(handles.filledNeuropilRoisDisplayToggle, 'Value', 0);
set(handles.dfDisplayToggle, 'Value', 1);
set(handles.npCorDfDispToggle,'Value',0);

traces=evalin('base','somaticF');
traces=batchDeltaF(batchSmooth(traces'),0.2);
traces=traces';
assignin('base','dfs_fp',traces);
evalin('base','traces.dfs=dfs_fp;,clear dfs_fp')
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
ylim([-0.5 6.5])



% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in npCorDfDispToggle.
function npCorDfDispToggle_Callback(hObject, eventdata, handles)
% hObject    handle to npCorDfDispToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of npCorDfDispToggle
set(handles.neuropilRoisDisplayToggle, 'Value', 0);
set(handles.filledSomaRoisDisplayToggle, 'Value', 0);
set(handles.vascularRoisDisplayToggle, 'Value', 0);
set(handles.boutonRoisDisplayToggle, 'Value', 0);
set(handles.axonRoisDisplayToggle, 'Value', 0);
set(handles.dendriteRoisDisplayToggle, 'Value', 0);
set(handles.somaRoisDisplayToggle, 'Value', 0);
set(handles.filledNeuropilRoisDisplayToggle, 'Value', 0);
set(handles.dfDisplayToggle, 'Value', 0);
set(handles.npCorDfDispToggle,'Value',1);

somaF=evalin('base','somaticF');
neuropilF=evalin('base','neuropilF');
traces=batchDeltaF(batchSmooth(somaF'-(0.7*neuropilF')),0.2);
traces=traces';
assignin('base','npdfs_fp',traces);
evalin('base','traces.dfs_npc=npdfs_fp;,clear npdfs_fp')
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
ylim([-0.5 6.5])

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in flagROIButton.
function flagROIButton_Callback(hObject, eventdata, handles)
% hObject    handle to flagROIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

npS=get(handles.neuropilRoisDisplayToggle, 'Value');
fsS=get(handles.filledSomaRoisDisplayToggle, 'Value');
vS=get(handles.vascularRoisDisplayToggle, 'Value');
bS=get(handles.boutonRoisDisplayToggle, 'Value');
aS=get(handles.axonRoisDisplayToggle, 'Value');
dS=get(handles.dendriteRoisDisplayToggle, 'Value');
sS=get(handles.somaRoisDisplayToggle, 'Value');
fnpS=get(handles.filledNeuropilRoisDisplayToggle, 'Value');
dfS=get(handles.dfDisplayToggle, 'Value');
sS=get(handles.npCorDfDispToggle,'Value');

if dfS || sS
    sROI=str2num(get(handles.displayedROICounter,'String'));
    lP=1;
    disp('lP')
    if lP==1
        somaticROIS_flagged=evalin('base','somaticROIS_flagged');
        somaticROIS_flagged=[somaticROIS_flagged sROI];
        assignin('base','somaticROIS_flagged',somaticROIS_flagged);
        disp('1')
    else
        somaticROIS_flagged=sROI;
        assignin('base','somaticROIS_flagged',somaticROIS_flagged);
        disp('0')
    end
else
end


% --- Executes on button press in diskRegFlag.
function diskRegFlag_Callback(hObject, eventdata, handles)
% hObject    handle to diskRegFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of diskRegFlag



function diskExtractSkipByEntry_Callback(hObject, eventdata, handles)
% hObject    handle to diskExtractSkipByEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of diskExtractSkipByEntry as text
%        str2double(get(hObject,'String')) returns contents of diskExtractSkipByEntry as a double


% --- Executes during object creation, after setting all properties.
function diskExtractSkipByEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to diskExtractSkipByEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in diskExtractSkipByToggle.
function diskExtractSkipByToggle_Callback(hObject, eventdata, handles)
% hObject    handle to diskExtractSkipByToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of diskExtractSkipByToggle



function diskExtractSkipByStartEntry_Callback(hObject, eventdata, handles)
% hObject    handle to diskExtractSkipByStartEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of diskExtractSkipByStartEntry as text
%        str2double(get(hObject,'String')) returns contents of diskExtractSkipByStartEntry as a double


% --- Executes during object creation, after setting all properties.
function diskExtractSkipByStartEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to diskExtractSkipByStartEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
