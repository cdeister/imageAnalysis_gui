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



% Last Modified by GUIDE v2.5 04-Dec-2014 13:14:05

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


% ** Generic Path Stuff

%filterToggle=get(handles.filterDiskProjectToggle,'Value');
imPath=uigetdir();


% if there is a string to filter on:
% filterString={get(handles.fileFilterString,'String')};
imageType={'.tif'};
% if filterToggle
%     filteredFiles = dir([imPath filesep '*' filterString{1} '*' imageType{1}]);
% else
    filteredFiles = dir([imPath filesep '*' imageType{1}]);
    archFilteredFiles=filteredFiles;
    filteredFiles=resortImageFileMap(filteredFiles);
% end

assignin('base','archFilteredFiles',archFilteredFiles)
assignin('base','filteredFiles',filteredFiles)

%set(handles.endImageEntry,'string',numel(filteredFiles))

firstIm=str2num(get(handles.firstImageEntry,'string'));
endIm=str2num(get(handles.endImageEntry,'string'));
imageCount=(endIm-firstIm)+1;
% 
if matlabpool('size')==0
    matlabpool open
else
end

%  Extraction

if get(handles.dendriteExtractCheck, 'Value')==1;
    tic
    g=evalin('base','exist(''dendriticF'')');
    if g==1
        alreadyExtractedROIs=evalin('base','size(dendriticF,2)');
        sRois=evalin('base','dendriticROIs');
        sRois=sRois(alreadyExtractedROIs+1:end);
    elseif g==0
        sRois=evalin('base','dendriticROIs');
    end

    parfor (k = firstIm:endIm)    
        aIm=imread([imPath filesep filteredFiles(k,1).name],'tif');
        dendriticF(k,:)=getMeansFromMasks(aIm,sRois);
    end
    if g==0
        assignin('base','dendriticF',dendriticF)
        disp('dendrites extracted')
        toc
    elseif g==1
        previousF=evalin('base','dendriticF');
        dendriticF=horzcat(previousF,dendriticF);
        assignin('base','dendriticF',dendriticF)
        disp('dendrites extracted')
        toc
    end
end

if get(handles.somaExtractCheck, 'Value')==1;
    tic
    g=evalin('base','exist(''somaticF'')');
    if g==1
        alreadyExtractedROIs=evalin('base','size(somaticF,2)');
        sRois=evalin('base','somaticROIs');
        sRois=sRois(alreadyExtractedROIs+1:end);
    elseif g==0
        sRois=evalin('base','somaticROIs');
    end

    parfor (k = firstIm:endIm)
        aIm=imread([imPath filesep filteredFiles(k,1).name],'tif');
        somaticF(k,:)=getMeansFromMasks(aIm,sRois);
    end
    if g==0
        assignin('base','somaticF',somaticF)
        disp('somas extracted')
        toc
    elseif g==1
        previousF=evalin('base','somaticF');
        somaticF=horzcat(previousF,somaticF);
        assignin('base','somaticF',somaticF)
        disp('somas extracted')
        toc
    end
end

if get(handles.neuropilExtractCheck, 'Value')==1;
    tic
    g=evalin('base','exist(''neuropilF'')');
    if g==1
        alreadyExtractedROIs=evalin('base','size(neuropilF,2)');
        sRois=evalin('base','neuropilROIs');
        sRois=sRois(alreadyExtractedROIs+1:end);
    elseif g==0
        sRois=evalin('base','neuropilROIs');
    end

    parfor (k = firstIm:endIm)    
        aIm=imread([imPath filesep filteredFiles(k,1).name],'tif');
        neuropilF(k,:)=getMeansFromMasks(aIm,sRois);
    end
    if g==0
        assignin('base','neuropilF',neuropilF)
        disp('neuropil extracted')
        toc
    elseif g==1
        previousF=evalin('base','neuropilF');
        somaticF=horzcat(previousF,neuropilF);
        assignin('base','neuropilF',neuropilF)
        disp('neuropil extracted')
        toc
    end
end







% --- Executes on button press in parallelExtractButton.
function parallelExtractButton_Callback(hObject, eventdata, handles)
% hObject    handle to parallelExtractButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 if matlabpool('size')==0
    matlabpool open
 else
 end
 set(handles.extractButton,'string','running','ForegroundColor','red','enable','off');
 
if get(handles.somaExtractCheck, 'Value')==1;
    tic
    sRois=evalin('base','somaticROIs');
    dStack=double(evalin('base','dsRegisteredStack_2'));
    
    % initialize containers
    mStacks=zeros(size(dStack));
    flatMStack=zeros(size(dStack,1)*size(dStack,2),size(dStack,3));
    sED=zeros(numel(sRois),size(dStack,3));
    
    parfor n=1:numel(sRois)
        tSRoi=double(sRois{1,n});
        tSRoi(tSRoi==0)=NaN;
        roiStack=repmat(tSRoi,[1,1,size(dStack,3)]);
        mStacks=dStack.*roiStack;   % <---- This could be optimized with a mex function.
        flatMStack=reshape(mStacks,size(roiStack,1)*size(roiStack,2),size(roiStack,3));
        sED(n,:)=nanmean(flatMStack);  % <--- A bit slow, maybe I should just take the memory hit and keep init. containers?
    end
    assignin('base','somaticF',sED)
    disp('somas extracted')
    toc
end
if get(handles.neuropilExtractCheck, 'Value')==1;
    tic
    sRois=evalin('base','neuropilROIs');
    dStack=double(evalin('base','convertedStack'));
    
    % initialize containers
    mStacks=zeros(size(dStack));
    flatMStack=zeros(size(dStack,1)*size(dStack,2),size(dStack,3));
    sED=zeros(numel(sRois),size(dStack,3));
    
    parfor n=1:numel(sRois)
        tSRoi=double(sRois{1,n});
        tSRoi(tSRoi==0)=NaN;
        roiStack=repmat(tSRoi,[1,1,size(dStack,3)]);
        mStacks=dStack.*roiStack;   % <---- This could be optimized with a mex function.
        flatMStack=reshape(mStacks,size(roiStack,1)*size(roiStack,2),size(roiStack,3));
        sED(n,:)=nanmean(flatMStack);  % <--- A bit slow, maybe I should just take the memory hit and keep init. containers?
    end
    assignin('base','neuropilF',sED)
    disp('neuropil extracted')
    toc
    
end

if get(handles.boutonExtractCheck, 'Value')==1;
    tic
    sRois=evalin('base','boutonROIs');
    dStack=double(evalin('base','convertedStack'));
    
    % initialize containers
    mStacks=zeros(size(dStack));
    flatMStack=zeros(size(dStack,1)*size(dStack,2),size(dStack,3));
    sED=zeros(numel(sRois),size(dStack,3));
    
    parfor n=1:numel(sRois)
        tSRoi=double(sRois{1,n});
        tSRoi(tSRoi==0)=NaN;
        roiStack=repmat(tSRoi,[1,1,size(dStack,3)]);
        mStacks=dStack.*roiStack;   % <---- This could be optimized with a mex function.
        flatMStack=reshape(mStacks,size(roiStack,1)*size(roiStack,2),size(roiStack,3));
        sED(n,:)=nanmean(flatMStack);  % <--- A bit slow, maybe I should just take the memory hit and keep init. containers?
    end
    assignin('base','boutonF',sED)
    disp('boutons extracted')
    toc
end

if get(handles.dendriteExtractCheck, 'Value')==1;
    tic
    sRois=evalin('base','dendriticROIs');
    dStack=double(evalin('base','convertedStack'));
    
    % initialize containers
    mStacks=zeros(size(dStack));
    flatMStack=zeros(size(dStack,1)*size(dStack,2),size(dStack,3));
    sED=zeros(numel(sRois),size(dStack,3));
    
    parfor n=1:numel(sRois)
        tSRoi=double(sRois{1,n});
        tSRoi(tSRoi==0)=NaN;
        roiStack=repmat(tSRoi,[1,1,size(dStack,3)]);
        mStacks=dStack.*roiStack;   % <---- This could be optimized with a mex function.
        flatMStack=reshape(mStacks,size(roiStack,1)*size(roiStack,2),size(roiStack,3));
        sED(n,:)=nanmean(flatMStack);  % <--- A bit slow, maybe I should just take the memory hit and keep init. containers?
    end
    assignin('base','dendriticF',sED)
    disp('dendrites extracted')
    toc    
end

set(handles.extractButton,'string','Extract','ForegroundColor','black','enable','on');

 if matlabpool('size')>0
    matlabpool close
 else
 end

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


