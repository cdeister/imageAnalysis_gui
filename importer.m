function varargout = importer(varargin)
% IMPORTER MATLAB code for importer.fig
%      IMPORTER, by itself, creates a new IMPORTER or raises the existing
%      singleton*.
%
%      H = IMPORTER returns the handle to a new IMPORTER or the handle to
%      the existing singleton*.
%
%      IMPORTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMPORTER.M with the given input arguments.
%
%      IMPORTER('Property','Value',...) creates a new IMPORTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before importer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to importer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help importer

% Last Modified by GUIDE v2.5 19-Aug-2014 16:46:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @importer_OpeningFcn, ...
                   'gui_OutputFcn',  @importer_OutputFcn, ...
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


% --- Executes just before importer is made visible.
function importer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to importer (see VARARGIN)

% Choose default command line output for importer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes importer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = importer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in importButton.
function importButton_Callback(hObject, eventdata, handles)
% hObject    handle to importButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tTS=get(handles.tiffSelectToggle, 'Value');
pTS=get(handles.pngSelectToggle, 'Value');

g=evalin('base','exist(''importPath'')');
if g==1
    imPath=evalin('base','importPath');
    firstIm=str2num(get(handles.firstImageEntry,'string'));
    endIm=str2num(get(handles.endImageEntry,'string'));
elseif g==0
    imPath=uigetdir;
%    assignin('base','importPath',imPath);
    firstIm=str2num(get(handles.firstImageEntry,'string'));
    endIm=str2num(get(handles.endImageEntry,'string'));
end
    

% if there is a string to filter on:

    filterString={get(handles.fileFilterString,'String')};
    if tTS
        imageType={'.tif'};
    elseif pTS
        imageType={'.png'};
    end
    filteredFiles = dir([imPath filesep '*' filterString{1} '*' imageType{1}]);
    filteredFiles=resortImageFileMap(filteredFiles);
    assignin('base','filteredFiles',filteredFiles)
    importCount=endIm-firstIm;
    importedImages=zeros(512,512,importCount,'uint16');
    tic
    parfor n=firstIm:endIm;
        importedImages(:,:,n)=imread([imPath filesep filteredFiles(n,1).name],'tif');
    end
    toc
    assignin('base',['importedStack_' filterString{1}],uint16(importedImages))
    vars = evalin('base','who');
    set(handles.workspaceVarBox,'String',vars)



% Update handles structure
guidata(hObject, handles);



function fileFilterString_Callback(hObject, eventdata, handles)
% hObject    handle to fileFilterString (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileFilterString as text
%        str2double(get(hObject,'String')) returns contents of fileFilterString as a double


% --- Executes during object creation, after setting all properties.
function fileFilterString_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileFilterString (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in stringFilterToggle.
function stringFilterToggle_Callback(hObject, eventdata, handles)
% hObject    handle to stringFilterToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stringFilterToggle

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in tiffSelectToggle.
function tiffSelectToggle_Callback(hObject, eventdata, handles)
% hObject    handle to tiffSelectToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tiffSelectToggle
set(handles.pngSelectToggle, 'Value', 0);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pngSelectToggle.
function pngSelectToggle_Callback(hObject, eventdata, handles)
% hObject    handle to pngSelectToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pngSelectToggle
set(handles.tiffSelectToggle, 'Value', 0);

% Update handles structure
guidata(hObject, handles);



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
% hObject    handle to endImageEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endImageEntry as text
%        str2double(get(hObject,'String')) returns contents of endImageEntry as a double


% --- Executes during object creation, after setting all properties.
function endImageEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endImageEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function skipFactorEntry_Callback(hObject, eventdata, handles)
% hObject    handle to skipFactorEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of skipFactorEntry as text
%        str2double(get(hObject,'String')) returns contents of skipFactorEntry as a double


% --- Executes during object creation, after setting all properties.
function skipFactorEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to skipFactorEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in skipFactorToggle.
function skipFactorToggle_Callback(hObject, eventdata, handles)
% hObject    handle to skipFactorToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of skipFactorToggle


% --- Executes on button press in setDirectoryButton.
function setDirectoryButton_Callback(hObject, eventdata, handles)
% hObject    handle to setDirectoryButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imPath=uigetdir;
assignin('base','importPath',imPath);

tTS=get(handles.tiffSelectToggle, 'Value');
pTS=get(handles.pngSelectToggle, 'Value');

    filterString={get(handles.fileFilterString,'String')};
    if tTS
        imageType={'.tif'};
    elseif pTS
        imageType={'.png'};
    end
    filteredFiles = dir([imPath filesep '*' filterString{1} '*' imageType{1}]);
    eNum=numel(filteredFiles);
    set(handles.endImageEntry,'string',num2str(eNum))




% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in workspaceVarBox.
function workspaceVarBox_Callback(hObject, eventdata, handles)
% hObject    handle to workspaceVarBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns workspaceVarBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from workspaceVarBox

% Update handles structure
guidata(hObject, handles);


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


% --- Executes on button press in meanProjectButton.
function meanProjectButton_Callback(hObject, eventdata, handles)
% hObject    handle to meanProjectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');

for n=1:numel(selectionsIndex)
    s=evalin('base',selections{selectionsIndex(n)});
    mP=mean(s,3);
    assignin('base',['meanProj_' selections{selectionsIndex(n)}],im2uint16(mP,'Indexed'));
end


vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)


% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in templateButton.
function templateButton_Callback(hObject, eventdata, handles)
% hObject    handle to templateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
if numel(selectionsIndex)>1
    disp('you can only set one template')
elseif numel(selectionsIndex)==0
    disp('you must select a template to use')
else
    tTemplate=evalin('base',selections{selectionsIndex});
    assignin('base','regTemplate',im2uint16(tTemplate,'Indexed'));
end

vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)
    


% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in setRegStackButton.
function setRegStackButton_Callback(hObject, eventdata, handles)
% hObject    handle to setRegStackButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
if numel(selectionsIndex)>1
    disp('you can only set one primary stack to register')
elseif numel(selectionsIndex)==0
    disp('you must select a stack to register')
else
    assignin('base','stackToRegister',selections{selectionsIndex});
end

vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)
    


% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in setSecondaryRegStacksButton.
function setSecondaryRegStacksButton_Callback(hObject, eventdata, handles)
% hObject    handle to setSecondaryRegStacksButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
if numel(selectionsIndex)>0
    for n=1
        s{n}=selections{selectionsIndex(n)};
        assignin('base','stacksCoregistered',s);
    end
else
end
vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)

    


% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in registerButton.
function registerButton_Callback(hObject, eventdata, handles)
% hObject    handle to registerButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the string for the stack you want to register; this will be a string
regStackString=evalin('base','stackToRegister');

% check to see if there are stacks to coreg (if so it will be a cell)
g=evalin('base','exist(''stacksCoregistered'')');
if g
    coregStackStrings=evalin('base','stacksCoregistered');
else
end

% todo: allow user to crop what they want


regTemp=evalin('base','regTemplate');
rStack=evalin('base',regStackString);
subpixelFactor=100;
totalImagesPossible=size(rStack,3);

% if matlabpool('size')==0
%     matlabpool open
% else
% end
registeredTransformations=zeros(4,totalImagesPossible);
if g && numel(coregStackStrings)==1
    rStack2=evalin('base',coregStackStrings{1});
    registeredImages=zeros(size(rStack,1),size(rStack,2),totalImagesPossible);
    coregisteredImages=zeros(size(rStack,1),size(rStack,2),totalImagesPossible,'uint16');
    tic
    parfor n=1:totalImagesPossible,
    [out1,out2,out3]=dftregistration(fft2(regTemp(256-75:256+75,256-75:256+75)),fft2(rStack(256-75:256+75,256-75:256+75,n)),subpixelFactor,ifft2(rStack(256-75:256+75,256-75:256+75,n)));
        % registeredImages(:,:,n)=uint16(round(abs(ifft2(out2))*65535));
        coregisteredImages(:,:,n)=uint16(round(abs(ifft2(out3))*65535));
        registeredTransformations(:,n)=out1;
        registeredImages(:,:,n)=applyRegTransforms(im2uint16(ifft2(out2),'Indexed'),out1);
     
    end
    toc
    assignin('base','registeredStack',uint16(registeredImages))
    assignin('base','coregisteredStack',uint16(coregisteredImages))
    assignin('base','registeredTransforms',registeredTransformations)
    
else
    registeredImages=zeros(size(rStack,1),size(rStack,2),totalImagesPossible,'uint16');
    tic
    regTempC=regTemp;
    parfor n=1:totalImagesPossible,
        imReg=rStack(:,:,n);
        [out1,out2]=dftregistration(ifft2(regTempC),ifft2(imReg),subpixelFactor);
        registeredTransformations(:,n)=out1;
        registeredImages(:,:,n)=uint16(round(abs(ifft2(out2))*65535));
        %registeredImages(:,:,n)=uint16(round(abs(ifft2(out2))*65535));
        %registeredImages(:,:,n)=uint16(round(applyRegTransforms(imReg,out1)*65535));
    end
    toc
    mean2(registeredImages(:,:,1))

    assignin('base','registeredStack',uint16(registeredImages))
    assignin('base','registeredTransforms',registeredTransformations)
end

vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)

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


% --- Executes on button press in saveStackButton.
function saveStackButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveStackButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selection = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');

objectName = get(handles.stackObjectNameEntry,'String');
objectPath=uigetdir;

% messy metadata capture
assignin('base','stackName',selection(selectionsIndex));
assignin('base','objectName',objectName);
assignin('base','objectPath',objectPath);
evalin('base','stackObject_meta.stackName=stackName;,clear(''stackName'')');
evalin('base','stackObject_meta.objectName=objectName;,clear(''objectName'')');
evalin('base','stackObject_meta.objectPath=objectPath;,clear(''objectPath'')');


firstIm=str2num(get(handles.firstImageEntry,'string'));
endIm=str2num(get(handles.endImageEntry,'string'));
imageCount=endIm-firstIm;

assignin('base','firstIM',firstIm);
assignin('base','endIM',endIm);
assignin('base','imageCount',imageCount);
evalin('base','stackObject_meta.firstImage=firstIM;,clear(''firstIM'')');
evalin('base','stackObject_meta.endImage=endIM;,clear(''endIM'')');
evalin('base','stackObject_meta.imageCount=imageCount;,clear(''imageCount'')');



disp('saving stack ... ');
compressFlag=get(handles.compressStackToggle,'Value');

% the stack is big so don't move it across spaces ... evalin base
if compressFlag
    tic
    evalin('base','save([stackObject_meta.objectPath filesep stackObject_meta.objectName ''.mat''],stackObject_meta.stackName{1})');
    toc
else
    firstIm=str2num(get(handles.firstImageEntry,'string'));
    endIm=str2num(get(handles.endImageEntry,'string'));
    imageCount=endIm-firstIm;

    if matlabpool('size')==0
        matlabpool open
    else
    end

    tic
    evalin('base',['parfor n=(' num2str(firstIm) '+1):' num2str(endIm) ',imwrite(importedStack_Ch3(:,:,n-' firstIm '), [stackObject_meta.stackName{1} ''.tif''], ''writemode'', ''append'');,end']);
    toc
end

% delete the original stack from the workspace (FREE TONS OF MEMORY!!!)
evalin('base','clear(stackObject_meta.stackName{1})')

% import the read/write stack object (this could be cleaned up a tad).
evalin('base','stackObject=matfile([stackObject_meta.objectPath filesep stackObject_meta.objectName ''.mat''],''Writable'',true);');


disp('done saving stack');


vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in saveDirectoryButton.
function saveDirectoryButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveDirectoryButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
savDir=uigetdir;
assignin('base','savePath_stacks',savDir);

% Update handles structure
guidata(hObject, handles);



function stackObjectNameEntry_Callback(hObject, eventdata, handles)
% hObject    handle to stackObjectNameEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stackObjectNameEntry as text
%        str2double(get(hObject,'String')) returns contents of stackObjectNameEntry as a double


% --- Executes during object creation, after setting all properties.
function stackObjectNameEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stackObjectNameEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in diskMeanProjectButton.
function diskMeanProjectButton_Callback(hObject, eventdata, handles)
% hObject    handle to diskMeanProjectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


firstIm=str2num(get(handles.firstImageEntry,'string'));
endIm=str2num(get(handles.endImageEntry,'string'));
imageCount=(endIm-firstIm)+1;
imPath=evalin('base','importPath');

% if there is a string to filter on:
filterString={get(handles.fileFilterString,'String')};
imageType={'.tif'};
filteredFiles = dir([imPath filesep '*' filterString{1} '*' imageType{1}]);

if matlabpool('size')==0
    matlabpool open
else
end



disp('projecting ...')

% seed the stack in the wspace
pS=uint32(imread([imPath filesep filteredFiles(1,1).name],'tif'));
% iterate the stack in the wspace
tic
parfor n=(firstIm+1):endIm
    pS=imadd(pS,uint32(imread([imPath filesep filteredFiles(n,1).name],'tif')));
end
toc
pS=uint16(imdivide(pS,imageCount));
assignin('base','meanProjection',pS);
disp('done!')


vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)
    


% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in compressStackToggle.
function compressStackToggle_Callback(hObject, eventdata, handles)
% hObject    handle to compressStackToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of compressStackToggle


% --- Executes on button press in diskRegisterButton.
function diskRegisterButton_Callback(hObject, eventdata, handles)
% hObject    handle to diskRegisterButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Let's save to a mat file ... the stack object should be fine, there could
% be a speed bump in having read write across disks, but maybe impractical,
% so no need to make a new object. 

if matlabpool('size')==0
    matlabpool open
else
end

firstIm=str2num(get(handles.firstImageEntry,'string'));
endIm=str2num(get(handles.endImageEntry,'string'));
imageCount=(endIm-firstIm)+1;
imPath=evalin('base','importPath');

% if there is a string to filter on:
filterString={get(handles.fileFilterString,'String')};
imageType={'.tif'};
filteredFiles = dir([imPath filesep '*' filterString{1} '*' imageType{1}]);
filteredFiles=resortImageFileMap(filteredFiles);
assignin('base','filteredFiles',filteredFiles)

% we need to pad from 1 to the image you care about, because par loops
% won't let you correct for the shift.
registeredTransformations=zeros(4,(firstIm-1)+imageCount);
subpixelFactor=100;

regTemp=evalin('base','regTemplate');

saveTiffFlag=get(handles.saveRegTiffsToggle,'Value');

if saveTiffFlag==0
tic
parfor n=firstIm:endIm,
        [out1,~]=dftregistration(ifft2(regTemp),ifft2(imread([imPath filesep filteredFiles(n,1).name],'tif')),subpixelFactor);
        registeredTransformations(:,n)=out1;     
end
toc

elseif saveTiffFlag==1
regSavePath=uigetdir();    
tic

parfor n=firstIm:endIm,
        [out1,out2]=dftregistration(ifft2(regTemp),ifft2(imread([imPath filesep filteredFiles(n,1).name],'tif')),subpixelFactor);
        imwrite(uint16(round(abs(ifft2(out2))*65535)),[regSavePath filesep 'registered_' int2str(n) '.tif'],'TIF');
        registeredTransformations(:,n)=out1;     
end
end
toc
assignin('base','registeredImagesPath',regSavePath);

% we shave any images from 1 to the image you care about.
registeredTransformations=registeredTransformations(:,firstIm:endIm);
assignin('base','registeredTransformations',registeredTransformations);


vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in saveRegTiffsToggle.
function saveRegTiffsToggle_Callback(hObject, eventdata, handles)
% hObject    handle to saveRegTiffsToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of saveRegTiffsToggle
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in selectDiskMeanProjectButton.
function selectDiskMeanProjectButton_Callback(hObject, eventdata, handles)
% hObject    handle to selectDiskMeanProjectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

firstIm=str2num(get(handles.firstImageEntry,'string'));
endIm=str2num(get(handles.endImageEntry,'string'));
imageCount=(endIm-firstIm)+1;


imPath=uigetdir();

% if there is a string to filter on:

imageType={'.tif'};

    filteredFiles = dir([imPath filesep '*' imageType{1}]);

if matlabpool('size')==0
    matlabpool open
else
end



disp('projecting ...')

% seed the stack in the wspace
pS=uint32(imread([imPath filesep filteredFiles(1,1).name],'tif'));
% iterate the stack in the wspace
tic
parfor n=(firstIm+1):endIm
    pS=imadd(pS,uint32(imread([imPath filesep filteredFiles(n,1).name],'tif')));
end
toc
pS=uint16(imdivide(pS,imageCount));
assignin('base','meanProjection_registered',pS);
disp('done!')


vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)
    


% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in filterDiskProjectToggle.
function filterDiskProjectToggle_Callback(hObject, eventdata, handles)
% hObject    handle to filterDiskProjectToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of filterDiskProjectToggle

% --- Executes during object creation, after setting all properties.
function appendProjTextEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stackObjectNameEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
