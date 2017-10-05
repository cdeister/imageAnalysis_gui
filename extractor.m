
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



% Last Modified by GUIDE v2.5 04-Oct-2017 12:43:06

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


set(handles.extractFeedbackString,'String','Extracting ...')
pause(0.001);
guidata(hObject, handles);

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
roiStringMap={'somaticROI','dendriticROI','axonalROI','boutonROI','neuropilROI','vascularROI','filledSomaticROI','redSomaticROI'};
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

set(handles.extractFeedbackString,'String','')
guidata(hObject, handles);




% --- Executes on button press in extractButton.
function extractButton_Callback(hObject, eventdata, handles)
% hObject    handle to extractButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.extractButton,'string','running','ForegroundColor','red','enable','off');

set(handles.extractFeedbackString,'String','Extracting ...')
pause(0.001);
guidata(hObject, handles);

% ************ handle concatination of roi types
roiStringMap={'somaticROIs','dendriticROIs','axonalROIs','boutonROIs','neuropilROIs','vascularROIs','filledSomaticROIs','redSomaticROI'};
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
aa=toc;
% disp(num2str(aa))

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

set(handles.extractFeedbackString,'String','')
set(handles.extractButton,'string','Extract','ForegroundColor','black','enable','on');

% Update handles structure
refreshWSVarsBtn_Callback(hObject, eventdata, handles)
guidata(hObject, handles);



% --- Executes on slider movement.
function roiDisplaySlider_Callback(hObject, eventdata, handles)
% main roi load
sTr=get(handles.somaRoisDisplayToggle, 'Value');
nTr=get(handles.neuropilRoisDisplayToggle, 'Value');
bTr=get(handles.boutonRoisDisplayToggle, 'Value');
dTr=get(handles.dendriteRoisDisplayToggle, 'Value');
npTr=get(handles.dfDisplayToggle,'Value');
cnpTr=get(handles.npCorDfDispToggle,'Value');
rsTr=get(handles.redSomaticRoisDisplayToggle, 'Value');

plotRelated=get(handles.showCorrelatedToggle,'Value');
relatedOffset=str2double(get(handles.montageOffsetEntry,'String'));
relatedThreshold=str2double(get(handles.corThresholdEntry,'String'));

sliderValue = fix(get(handles.roiDisplaySlider,'Value'));
set(handles.displayedROICounter,'String', num2str(sliderValue));
tnum=str2double(get(handles.displayedROICounter,'String'));

if sTr
    traces=evalin('base','somaticF');

    class(tnum)

    mask=evalin('base',['somaticROIs{' num2str(tnum) '}']);
    maskStr='somaticROIs';
    centroidStr='somaticROICenters';

elseif nTr
    traces=evalin('base','neuropilF');
    mask=evalin('base',['somaticROIs{' num2str(tnum) '}']);
    maskStr='neuropilROIs';
    centroidStr='neuropilROICenters';

elseif bTr
    traces=evalin('base','boutonF');
    mask=evalin('base',['somaticROIs{' num2str(tnum) '}']);
    maskStr='boutonROIs';
    centroidStr='boutonROICenters';

elseif dTr
    traces=evalin('base','dendriticF');
    mask=evalin('base',['somaticROIs{' num2str(tnum) '}']);
    maskStr='dendriticROIs';
    centroidStr='dendriticROICenters';

elseif npTr
    traces=evalin('base','traces.dfs');
    mask=evalin('base',['somaticROIs{' num2str(tnum) '}']);
    maskStr='somaticROIs';
    centroidStr='somaticROICenters';

elseif cnpTr
    traces=evalin('base','traces.dfs_npc');
    mask=evalin('base',['somaticROIs{' num2str(tnum) '}']);
    maskStr='somaticROIs';
    centroidStr='somaticROICenters';

elseif rsTr
    traces=evalin('base','redSomaticF');
    mask=evalin('base',['somaticROIs{' num2str(tnum) '}']);
    maskStr='redSomaticROIs';
    centroidStr='redSomaticROICenters';
end

yLow=str2num(get(handles.yLowTrace,'String'));
xLow=str2num(get(handles.yHighTrace,'String'));

selTrace=traces(tnum,:);
nonSelTraces=traces(1:size(traces,1),:);
selTrace=repmat(selTrace,size(nonSelTraces,1),1);

% elseif plotRelated==1
axes(handles.corAxis)
curCorr=corr(selTrace',nonSelTraces');
[csV,csI]=sort(curCorr');
csV=csV(:,1);
csI=csI(:,1);
plot(curCorr','ko','linewidth',1)
hold on
plot([1 size(curCorr,1)],[relatedThreshold relatedThreshold],'r:','linewidth',1)
hold off
ylim([-1 1])


% related cells by index
relatedROIs=csI(find(csV>=relatedThreshold));
relCString=strjoin(arrayfun(@(x) num2str(x),relatedROIs,'UniformOutput',false),',');
set(handles.relatedCellsReturn,'String',relCString)

% relation score (correlation etc.)
relatedVals=csV(find(csV>=relatedThreshold));
relVString=strjoin(arrayfun(@(x) num2str(x),relatedVals,'UniformOutput',false),',');
set(handles.relatedValuesReturn,'String',relVString)

% related pairwise distance (Euclidean)
for n=1:numel(relatedROIs)
    b=evalin('base',[centroidStr '{' num2str(tnum) '}.Centroid;']);
    a=evalin('base',[centroidStr '{' num2str(relatedROIs(n)) '}.Centroid;']);
    relatedDists(:,n)=sqrt((b(1)-a(1))^2+((b(2)-a(2))^2));
end
relDString=strjoin(arrayfun(@(x) num2str(x),relatedDists,'UniformOutput',false),',');
set(handles.relatedDistReturn,'String',relDString);


if numel(relatedDists)>=2
    axes(handles.featureHist)
    nhist(relatedDists,'box');
    xlim([0 200])
    
    axes(handles.featurePlot)
    plot(relatedROIs,relatedDists,'ko')
    hold on
    plot([1 size(curCorr,1)],[20 20],'r:','linewidth',1)
    hold off
    ylim([0 200])
else
end


axes(handles.traceDisplay)

if numel(relatedROIs)>1
    aa=colormap(jet(numel(relatedROIs)*3));
    aa=aa(1:3:end,:);
else
    col=[1,1,1];
end

hold off
for n=1:numel(relatedROIs)
    if relatedROIs(n)==tnum
        col=[1,1,1];
    else
        col=aa(n,:);
    end
    h(n)=plot(traces(relatedROIs(n),:)','Color',col,'LineWidth',1.2);
    hold all
end
hold off

a=gca;
a.Color=[0.3,0.3,0.3];


ylim([yLow xLow])

for n=1:numel(relatedROIs)
    cumuMasks(:,:,n)=evalin('base',[maskStr '{' num2str(relatedROIs(n)) '}'])*relatedVals(n);
end
sumMasks=sum(cumuMasks,3);
clear cumuMasks

axes(handles.roiMaskAxis)
imagesc(sumMasks,[relatedOffset 1]),colormap jet
a=gca;
a.YTick=[];
a.XTick=[];






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

roiDisplaySlider_Callback(hObject, eventdata, handles)
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
assignin('base','dispROIString','somaticROI');
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

% axes(handles.traceDisplay);
% plot(traces(tnum,:));
% ylim([0 65535])
roiDisplaySlider_Callback(hObject, eventdata, handles)
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in dendriteRoisDisplayToggle.
function dendriteRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to dendriteRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dendriteRoisDisplayToggle
assignin('base','dispROIString','dendriticROI');
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
ylim([0 65535])



% Update handles structure
refreshWSVarsBtn_Callback(hObject, eventdata, handles)
guidata(hObject, handles);



% --- Executes on button press in axonRoisDisplayToggle.
function axonRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to axonRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of axonRoisDisplayToggle
assignin('base','dispROIString','axonalROI');
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
ylim([0 65535])

% Update handles structure
refreshWSVarsBtn_Callback(hObject, eventdata, handles)
guidata(hObject, handles);


% --- Executes on button press in boutonRoisDisplayToggle.
function boutonRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to boutonRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of boutonRoisDisplayToggle
assignin('base','dispROIString','boutonROI');
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
ylim([0 65535])


% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in vascularRoisDisplayToggle.
function vascularRoisDisplayToggle_Callback(hObject, eventdata, handles)
assignin('base','dispROIString','vascularROI');
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
ylim([0 65535])

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in filledSomaRoisDisplayToggle.
function filledSomaRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to filledSomaRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of filledSomaRoisDisplayToggle
assignin('base','dispROIString','filledSomaticROIs');
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
ylim([0 65535])

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in redSomaticRoisDisplayToggle.
function redSomaticRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to redSomaticRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of redSomaticRoisDisplayToggle
assignin('base','dispROIString','redSomaticROI');
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
ylim([0 65535])

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in neuropilRoisDisplayToggle.
function neuropilRoisDisplayToggle_Callback(hObject, eventdata, handles)
% hObject    handle to neuropilRoisDisplayToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of neuropilRoisDisplayToggle
assignin('base','dispROIString','neuropilROI');
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
ylim([0 65535])

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
ylim([-0.5 10])



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
traces=batchDeltaF(nPointMean(somaF'-(0.7*neuropilF'),3),0.2);
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
ylim([-0.5 10])

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in flagROIButton.
function flagROIButton_Callback(hObject, eventdata, handles)
% hObject    handle to flagROIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sROI=str2num(get(handles.displayedROICounter,'String'));
bE=evalin('base','exist(''dispROIString'');');
if bE==1
    dispString=evalin('base','dispROIString;');
    tStr=['flagged_' dispString];
    fE=evalin('base',['exist([''' tStr '''])']);
    
    if fE
        curFlagged=evalin('base',['flagged_' dispString]);
        curFlagged=[curFlagged; sROI];
        assignin('base',['flagged_' dispString],curFlagged)
    else
        curFlagged=sROI;
        assignin('base',['flagged_' dispString],curFlagged)
    end
else
end

rN=fix(str2double(get(handles.displayedROICounter,'String')))+1;
set(handles.roiDisplaySlider,'Value',rN)
guidata(hObject, handles);
roiDisplaySlider_Callback(hObject, eventdata, handles)



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


% --- Executes on button press in refreshWSVarsBtn.
function refreshWSVarsBtn_Callback(hObject, eventdata, handles)
% hObject    handle to refreshWSVarsBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)

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


% --- Executes on button press in showCorrelatedToggle.
function showCorrelatedToggle_Callback(hObject, eventdata, handles)
% hObject    handle to showCorrelatedToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showCorrelatedToggle
roiDisplaySlider_Callback(hObject, eventdata, handles)



function corThresholdEntry_Callback(hObject, eventdata, handles)
% hObject    handle to corThresholdEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of corThresholdEntry as text
%        str2double(get(hObject,'String')) returns contents of corThresholdEntry as a double
roiDisplaySlider_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function corThresholdEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to corThresholdEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function montageOffsetEntry_Callback(hObject, eventdata, handles)
% hObject    handle to montageOffsetEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of montageOffsetEntry as text
%        str2double(get(hObject,'String')) returns contents of montageOffsetEntry as a double
roiDisplaySlider_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function montageOffsetEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to montageOffsetEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in movingAvgBtn.
function movingAvgBtn_Callback(hObject, eventdata, handles)
% hObject    handle to movingAvgBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mvWin=fix(str2double(get(handles.smoothWindowEntry,'String')));
selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
selectStack=selections{selectionsIndex};

aa=evalin('base',selectStack);
bb=nPointMean(aa',mvWin);
clear aa
assignin('base',selectStack,bb');



function smoothWindowEntry_Callback(hObject, eventdata, handles)
% hObject    handle to smoothWindowEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smoothWindowEntry as text
%        str2double(get(hObject,'String')) returns contents of smoothWindowEntry as a double


% --- Executes during object creation, after setting all properties.
function smoothWindowEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smoothWindowEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xLowTrace_Callback(hObject, eventdata, handles)
% hObject    handle to xLowTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xLowTrace as text
%        str2double(get(hObject,'String')) returns contents of xLowTrace as a double


% --- Executes during object creation, after setting all properties.
function xLowTrace_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xLowTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xHighTrace_Callback(hObject, eventdata, handles)
% hObject    handle to xHighTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xHighTrace as text
%        str2double(get(hObject,'String')) returns contents of xHighTrace as a double


% --- Executes during object creation, after setting all properties.
function xHighTrace_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xHighTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yLowTrace_Callback(hObject, eventdata, handles)
% hObject    handle to yLowTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yLowTrace as text
%        str2double(get(hObject,'String')) returns contents of yLowTrace as a double
roiDisplaySlider_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function yLowTrace_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yLowTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function yHighTrace_Callback(hObject, eventdata, handles)
% hObject    handle to yHighTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yHighTrace as text
%        str2double(get(hObject,'String')) returns contents of yHighTrace as a double
roiDisplaySlider_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function yHighTrace_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yHighTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function relatedCellsReturn_Callback(hObject, eventdata, handles)
% hObject    handle to relatedCellsReturn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of relatedCellsReturn as text
%        str2double(get(hObject,'String')) returns contents of relatedCellsReturn as a double


% --- Executes during object creation, after setting all properties.
function relatedCellsReturn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to relatedCellsReturn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in groupMarkerBtn.
function groupMarkerBtn_Callback(hObject, eventdata, handles)
% hObject    handle to groupMarkerBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% g=evalin('base','exist(''tgROIs'')');
% if g==0
%     evalin('base','tgROIs=cell(0);');
%     evalin('base','tgScores=cell(0);');
% else
% end
    
gNum=fix(str2num(get(handles.groupCounter,'String')))+1;
gIs=str2num(get(handles.relatedCellsReturn,'String'));
gVs=str2num(get(handles.relatedValuesReturn,'String'));
gDs=str2num(get(handles.relatedDistReturn,'String'));
if numel(gIs)>1
    assignin('base','tIs',gIs);
    assignin('base','tVs',gVs);
    assignin('base','tDs',gDs);
    evalin('base',['tgROIs{' num2str(gNum) ',1}=tIs;,clear tIs']);
    evalin('base',['tgScores{' num2str(gNum) ',1}=tVs;,clear tVs']);
    evalin('base',['tgDists{' num2str(gNum) ',1}=tDs;,clear tDs']);
    set(handles.groupCounter,'String',num2str(gNum))
    refreshWSVarsBtn_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
else
end


rN=fix(str2double(get(handles.displayedROICounter,'String')))+1;
set(handles.roiDisplaySlider,'Value',rN)
guidata(hObject, handles);
roiDisplaySlider_Callback(hObject, eventdata, handles)









function groupCounter_Callback(hObject, eventdata, handles)
% hObject    handle to groupCounter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of groupCounter as text
%        str2double(get(hObject,'String')) returns contents of groupCounter as a double


% --- Executes during object creation, after setting all properties.
function groupCounter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to groupCounter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function relatedValuesReturn_Callback(hObject, eventdata, handles)
% hObject    handle to relatedValuesReturn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of relatedValuesReturn as text
%        str2double(get(hObject,'String')) returns contents of relatedValuesReturn as a double


% --- Executes during object creation, after setting all properties.
function relatedValuesReturn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to relatedValuesReturn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rcBtn_soma.
function rcBtn_soma_Callback(hObject, eventdata, handles)
% hObject    handle to rcBtn_soma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curROIType=evalin('base','dispROIString');

if strcmp(curROIType,'somaticROI')
    disp('It is already a soma.')
else
    curNum=fix(str2double(get(handles.displayedROICounter,'String')));
    g=evalin('base','exist(''somaticRoiCounter'')');
    
end

refreshWSVarsBtn_Callback(hObject, eventdata, handles)
guidata(hObject, handles);



% --- Executes on button press in rcBtn_dend.
function rcBtn_dend_Callback(hObject, eventdata, handles)
% hObject    handle to rcBtn_dend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
refreshWSVarsBtn_Callback(hObject, eventdata, handles)
guidata(hObject, handles);


% --- Executes on button press in rcBtn_axon.
function rcBtn_axon_Callback(hObject, eventdata, handles)
% hObject    handle to rcBtn_axon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
refreshWSVarsBtn_Callback(hObject, eventdata, handles)
guidata(hObject, handles);


% --- Executes on button press in deleteFlagged.
function deleteFlagged_Callback(hObject, eventdata, handles)
% hObject    handle to deleteFlagged (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% curROIType=evalin('base','dispROIString');
% 
% evalin('base',[curROIType ]);


refreshWSVarsBtn_Callback(hObject, eventdata, handles)
guidata(hObject, handles);
somaRoisDisplayToggle_Callback(hObject, eventdata, handles)



function relatedDistReturn_Callback(hObject, eventdata, handles)
% hObject    handle to relatedDistReturn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of relatedDistReturn as text
%        str2double(get(hObject,'String')) returns contents of relatedDistReturn as a double


% --- Executes during object creation, after setting all properties.
function relatedDistReturn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to relatedDistReturn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in keepFirstBtn.
function keepFirstBtn_Callback(hObject, eventdata, handles)
% hObject    handle to keepFirstBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
related=str2num(get(handles.relatedCellsReturn,'String'));
kill=related(2:end);
killNum=numel(kill);
if killNum>=1
tKS=strjoin(arrayfun(@(x) num2str(x),kill,'UniformOutput',false),',');
killString=['[' tKS ']'];
disp(killString)

evalin('base',['somaticF(' killString ',:)=[];']);
evalin('base','somaticRoiCounter=size(somaticF,1);');
evalin('base',['somaticROI_PixelLists(' killString ')=[];']);
evalin('base',['somaticROIBoundaries(' killString ')=[];']);
evalin('base',['somaticROICenters(' killString ')=[];']);
evalin('base',['somaticROIs(' killString ')=[];']);

refreshWSVarsBtn_Callback(hObject, eventdata, handles)
guidata(hObject, handles);
% somaRoisDisplayToggle_Callback(hObject, eventdata, handles)
advance=0;
else
    advance=1;
end
rN=fix(str2double(get(handles.displayedROICounter,'String')))+advance;
set(handles.roiDisplaySlider,'Value',rN)
guidata(hObject, handles);
roiDisplaySlider_Callback(hObject, eventdata, handles)
somaRoisDisplayToggle_Callback(hObject, eventdata, handles)


% --- Executes on button press in killSelectedBtn.
function killSelectedBtn_Callback(hObject, eventdata, handles)
% hObject    handle to killSelectedBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 
tnum=str2double(get(handles.displayedROICounter,'String'));
killString=num2str(tnum);

evalin('base',['somaticF(' killString ',:)=[];']);
evalin('base','somaticRoiCounter=size(somaticF,1);');
evalin('base',['somaticROI_PixelLists(' killString ')=[];']);
evalin('base',['somaticROIBoundaries(' killString ')=[];']);
evalin('base',['somaticROICenters(' killString ')=[];']);
evalin('base',['somaticROIs(' killString ')=[];']);

refreshWSVarsBtn_Callback(hObject, eventdata, handles)
guidata(hObject, handles);
advance=0;

rN=fix(str2double(get(handles.displayedROICounter,'String')))+advance;
set(handles.roiDisplaySlider,'Value',rN)
guidata(hObject, handles);
roiDisplaySlider_Callback(hObject, eventdata, handles)
somaRoisDisplayToggle_Callback(hObject, eventdata, handles)
