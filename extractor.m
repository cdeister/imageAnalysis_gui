
function varargout = extractor(varargin)
% EXTRACTOR MATLAB code for extractor.fig
% extractor is a very simple (incomplete) but effective extraction tool.
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



% Last Modified by GUIDE v2.5 31-Dec-2015 16:51:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @extractor_OpeningFcn, ...
                   'gui_OutputFcn',  @extractor_OutputFcn, ...
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

% --- Executes just before extractor is made visible.
function extractor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to extractor (see VARARGIN)

% Choose default command line output for extractor
handles.output = hObject;

vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes extractor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = extractor_OutputFcn(hObject, eventdata, handles) 
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



imPath=evalin('base','importPath');
fileList=evalin('base','filteredFiles');

firstIm=str2num(get(handles.firstImageEntry,'string'));
endIm=str2num(get(handles.endImageEntry,'string'));

skipImagesToggle=get(handles.diskExtractSkipByToggle,'Value');
skipImagesToggle=get(handles.diskExtractSkipByToggle,'Value');


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


% ************ handle concatination of roi types
roiStringMap={'somaticROIs','dendriticROIs','axonalROIs','boutonROIs','neuropilROIs','vascularROIs','filledSomaROIs','redSomaticROIs'};
roiToggleTruth=[get(handles.somaExtractCheck,'Value'),get(handles.dendriteExtractCheck,'Value'),...
    get(handles.axonExtractCheck,'Value'),get(handles.boutonExtractCheck,'Value'),...
    get(handles.neuropilExtractCheck,'Value'),get(handles.vascularExtractCheck,'Value'),...
    get(handles.filledSomaExtractCheck,'Value'),get(handles.redSomaticExtractCheck,'Value')];

rois=[];   % we will map in the selected rois into this
warnBit=1;
for n=1:numel(roiToggleTruth)
    if roiToggleTruth(n)==1
        warnBit=0;      % if anything is selected flip the warning to 0.
        roisToMap=evalin('base', roiStringMap{n});
        rois=[rois roisToMap];
    else
    end
end

if warnBit==1;
    disp('no rois')
end
% ************ end handle concatination of roi types

% ************  handle image list prep
numImages=(endIm-firstIm)+1;
sED=zeros(numel(rois),numImages);
regFlag=get(handles.diskRegFlag,'Value');

% ************  end handle image list prep


% ************  extract without registration 
if regFlag==0
disp(['about to extract, this should take ~ ' num2str((numel(rois)*.0004*numImages)./60) ' minutes'])
cc=clock;
disp(['started at ' num2str(cc(4)) ':'  num2str(cc(5))])
tic
disp('extracting')
diskLuminance=zeros(1,numImages);
for n=firstIm:endIm
    impImage=imread([imPath filesep fileList(n).name]);
    diskLuminance(:,(n-firstIm)+1)=mean2(impImage);
    for q=1:numel(rois)
        sED(q,(n-firstIm)+1)=mean(impImage(rois{q}(:,:)));
    end
    if (rem((n-firstIm)+1,100)==0)
        fprintf('%d/%d (%d%%)\n',(n-firstIm)+1,numImages,round(100*((n-firstIm)+1)./numImages));
    end
end
eT=toc;
assignin('base','diskLuminance',diskLuminance);
disp(['done extracting, this took ' num2str(eT./60) ' minutes'])

% ************  extract with registration 
elseif regFlag==1

disp(['about to extract, this should take ~ ' num2str((numel(rois)*.0008*numImages)./60) ' minutes'])
cc=clock;
disp(['started at ' num2str(cc(4)) ':'  num2str(cc(5))])
tic
template=evalin('base','regTemplate');
disp('extracting')
registeredTransformations=zeros(4,numImages);
diskLuminance=zeros(1,numImages);

for n=firstIm:endIm
    impImage=imread([imPath filesep fileList(n).name]);
    [out1,out2]=dftregistration(fft2(template),fft2(impImage),100);
    registeredTransformations(:,(n-firstIm)+1)=out1;
    diskLuminance(:,(n-firstIm)+1)=mean2(impImage);
    regImage=abs(ifft2(out2));
    for q=1:numel(rois)
        sED(q,(n-firstIm)+1)=mean(regImage(rois{q}(:,:)));
    end
    if (rem((n-firstIm)+1,100)==0)
        fprintf('%d/%d (%d%%)\n',(n-firstIm)+1,numImages,round(100*((n-firstIm)+1)./numImages));
    end
end

assignin('base','registeredTransformations',registeredTransformations);
assignin('base','diskLuminance',diskLuminance);

eT=toc;

disp(['done extracting, this took ' num2str(eT./60) ' minutes'])

end

% ************  now we need to map the extracted values to the original roi types
for n=1:numel(roiToggleTruth)
    if roiToggleTruth(n)==1
        roisToMapCount=evalin('base', ['numel(' roiStringMap{n} ')']);
        assignin('base',[roiStringMap{n}(1:end-4) 'F'],sED(1:roisToMapCount,:));
        sED(1:roisToMapCount,:)=[];
    else
    end
end

% Update handles structure
guidata(hObject, handles);




% --- Executes on button press in extractButton.
function extractButton_Callback(hObject, eventdata, handles)
% hObject    handle to extractButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.extractButton,'string','running','ForegroundColor','red','enable','off');

% ************ handle concatination of roi types
roiStringMap={'somaticROIs','dendriticROIs','axonalROIs','boutonROIs','neuropilROIs','vascularROIs','filledSomaROIs','redSomaticROIs'};
roiToggleTruth=[get(handles.somaExtractCheck,'Value'),get(handles.dendriteExtractCheck,'Value'),...
    get(handles.axonExtractCheck,'Value'),get(handles.boutonExtractCheck,'Value'),...
    get(handles.neuropilExtractCheck,'Value'),get(handles.vascularExtractCheck,'Value'),...
    get(handles.filledSomaExtractCheck,'Value'),get(handles.redSomaticExtractCheck,'Value')];

rois=[];   % we will map in the selected rois into this
warnBit=1;
for n=1:numel(roiToggleTruth)
    if roiToggleTruth(n)==1
        warnBit=0;      % if anything is selected flip the warning to 0.
        roisToMap=evalin('base', roiStringMap{n});
        rois=[rois roisToMap];
    else
    end
end

if warnBit==1;
    disp('no rois')
end
% ************ end handle concatination of roi types

%--- extract
selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
selectStack=selections{selectionsIndex};


dStackSize=evalin('base',['size(' selectStack ');']);

sED=zeros(numel(rois),dStackSize(3));
tic
for n=1:dStackSize(3)
    for q=1:numel(rois)
        aIm=double(evalin('base',[selectStack '(:,:,' num2str(n) ')']));
        sED(q,n)=mean(aIm(rois{q}(:,:)));
    end
end
aa=toc
disp(num2str(aa))

%--- end extract

% ************  now we need to map the extracted values to the original roi types
for n=1:numel(roiToggleTruth)
    if roiToggleTruth(n)==1
        roisToMapCount=evalin('base', ['numel(' roiStringMap{n} ')']);
        assignin('base',[roiStringMap{n}(1:end-4) 'F'],sED(1:roisToMapCount,:));
        sED(1:roisToMapCount,:)=[];
    else
    end
end


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

% Hints: 
%(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sTr=get(handles.somaRoisDisplayToggle, 'Value');
nTr=get(handles.neuropilRoisDisplayToggle, 'Value');
bTr=get(handles.boutonRoisDisplayToggle, 'Value');
dTr=get(handles.dendriteRoisDisplayToggle, 'Value');
npTr=get(handles.dfDisplayToggle,'Value');
cnpTr=get(handles.npCorDfDispToggle,'Value');
rsTr=get(handles.redSomaticRoisDisplayToggle, 'Value');


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
elseif rsTr
    traces=evalin('base','redSomaticF');
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
set(handles.redSomaticRoisDisplayToggle, 'Value', 0);
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
set(handles.redSomaticRoisDisplayToggle, 'Value', 0);
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
set(handles.redSomaticRoisDisplayToggle, 'Value', 0);
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
set(handles.redSomaticRoisDisplayToggle, 'Value', 0);
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
set(handles.redSomaticRoisDisplayToggle, 'Value', 0);
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
set(handles.redSomaticRoisDisplayToggle, 'Value', 0);
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


% --- Executes on button press in redSomaticRoisDisplayToggle.
function redSomaticRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to redSomaticRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of redSomaticRoisDisplayToggle

set(handles.neuropilRoisDisplayToggle, 'Value', 0);
set(handles.filledSomaRoisDisplayToggle, 'Value', 0);
set(handles.vascularRoisDisplayToggle, 'Value', 0);
set(handles.boutonRoisDisplayToggle, 'Value', 0);
set(handles.axonRoisDisplayToggle, 'Value', 0);
set(handles.dendriteRoisDisplayToggle, 'Value', 0);
set(handles.somaRoisDisplayToggle, 'Value', 0);
set(handles.redSomaticRoisDisplayToggle, 'Value', 1);
set(handles.dfDisplayToggle, 'Value', 0);
set(handles.npCorDfDispToggle,'Value',0);

traces=evalin('base','redSomaticF');
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
set(handles.redSomaticRoisDisplayToggle, 'Value', 1);
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


% --- Executes on button press in redSomaticExtractCheck.
function redSomaticExtractCheck_Callback(hObject, eventdata, handles)
% hObject    handle to redSomaticExtractCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of redSomaticExtractCheck


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
set(handles.redSomaticRoisDisplayToggle, 'Value', 0);
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
set(handles.redSomaticRoisDisplayToggle, 'Value', 0);
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
fnpS=get(handles.redSomaticRoisDisplayToggle, 'Value');
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


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox15.
function checkbox15_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox15


% --- Executes on button press in dataAppendToggle.
function dataAppendToggle_Callback(hObject, eventdata, handles)
% hObject    handle to dataAppendToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dataAppendToggle
