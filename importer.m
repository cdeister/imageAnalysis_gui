function varargout = importer(varargin)
% IMPORTER MATLAB code for importer.fig

% IMPORTER is a simple gui for importing image files into matlab and
% performing some basic pre-processing.
% 
%
% cdeister@brown.edu with any questions
% last modified: CAD 1/25/2015
%
%
%
% Last Modified by GUIDE v2.5 26-Jan-2015 08:32:54
%
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

vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)

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

mPF=get(handles.multiPageFlag, 'Value');
pImport=get(handles.parallelizeImportToggle,'Value');

% Check to see if the user imported something already and/or wants to
% import a multi-page Tif. 
g=evalin('base','exist(''importPath'')');
disp('importing images ...')

% User has set a path, but doesn't want multi-page tif.
if g==1 && mPF==0
    imPath=evalin('base','importPath');
    firstIm=str2num(get(handles.firstImageEntry,'string'));
    endIm=str2num(get(handles.endImageEntry,'string'));
    
% User has not set a path, and doesn't want multi-page tif.    
elseif g==0 && mPF==0
    imPath=uigetdir;
    firstIm=str2num(get(handles.firstImageEntry,'string'));
    endIm=str2num(get(handles.endImageEntry,'string'));
    
% User has set a path, but wants multi-page tif.    
elseif g==1 && mPF==1
    imPath=evalin('base','importPath');
    tifFile=evalin('base','tifFile');
    mpTifInfo=evalin('base','mpTifInfo');
    firstIm=str2num(get(handles.firstImageEntry,'string'));
    endIm=str2num(get(handles.endImageEntry,'string'));
    
% User has set not path, and does want multi-page tif.    
elseif g==0 && mPF==1
    [tifFile,imPath]=uigetfile('*.*','Select your tif file');
    mpTifInfo=imfinfo([imPath tifFile]);
    imageCount=length(mpTifInfo);
    firstIm=str2num(get(handles.firstImageEntry,'string'));
    endIm=str2num(get(handles.endImageEntry,'string'));
    assignin('base','mpTifInfo',mpTifInfo);
    assignin('base','tifFile',tifFile);
    assignin('base','imPath',imPath);
end

% This loads a file list that has characters that match the filter string.
% It should detect the bit depth and dimensions.
if mPF==0
    filterString={get(handles.fileFilterString,'String')};
    filteredFiles = dir([imPath filesep '*' filterString{1} '*']);
    filteredFiles=resortImageFileMap(filteredFiles);
    assignin('base','filteredFiles',filteredFiles)
    importCount=(endIm-firstIm)+1;
    disp(imPath)
    disp(filteredFiles(1,1).name)
    canaryImport=imread([imPath filesep filteredFiles(1,1).name]);
    imageSize=size(canaryImport);
    canaryInfo=whos('canaryImport');
    bitD=canaryInfo.class;
    assignin('base','bitDebug',bitD); % debug 
    importedImages=zeros(imageSize(1),imageSize(2),importCount,bitD);
    if strcmp(bitD,'uint16')==1
        imType='uint16';
    elseif strcmp(bitD,'uint32')==1
        imType='uint32';
    elseif strcmp(bitD,'uint8')==1
        imType='uint8';
    else
        imType='Double';
    end
    disp(imType)
 
    
    tic
    if pImport==1
        tempFiltFiles=filteredFiles(firstIm:endIm,1);
        parfor n=1:importCount;
            importedImages(:,:,n)=imread([imPath filesep tempFiltFiles(n,1).name]);
        end
    elseif pImport==0
        for n=firstIm:endIm;
            importedImages(:,:,(firstIm+1)-n)=imread([imPath filesep filteredFiles(n,1).name]);
        end
    end
    iT=toc;
    
    if bitD==16
        assignin('base',['importedStack_' filterString{1}],uint16(importedImages));
    elseif bitD==8
        assignin('base',['importedStack_' filterString{1}],uint8(importedImages));
    elseif bitD==32
        assignin('base',['importedStack_' filterString{1}],uint32(importedImages));
    else
        assignin('base',['importedStack_' filterString{1}],double(importedImages));
    end
    vars = evalin('base','who');
    set(handles.workspaceVarBox,'String',vars)
    
else  % The user wants multi-page tif. This import is a bit different.
    bitD=mpTifInfo(1).BitDepth;
    mImage=mpTifInfo(1).Width;
    nImage=mpTifInfo(1).Height;
    NumberImages=length(mpTifInfo);
    if bitD==16
        imType='uint16';
    elseif bitD==32
        imType='uint32';
        % why are you using 32 bit images? I'm curious shoot me an email please.
    elseif bitD==8
        imType='uint8';
    else
        imType='Double';
    end
 
    importedStack=zeros(nImage,mImage,NumberImages,imType);
    tic
    if pImport==1
        parfor i=1:NumberImages
            importedStack(:,:,i)=imread([imPath tifFile],'Index',i);
        end
    elseif pImport==0
        for i=1:NumberImages
            importedStack(:,:,i)=imread([imPath tifFile],'Index',i);
        end
    end
    assignin('base','importedStack',importedStack)
    assignin('base','importedBitDepth',bitD)
    iT=toc;
    
    % update var box
    vars = evalin('base','who');
    set(handles.workspaceVarBox,'String',vars)
end

disp(['*** done with import, which took ' num2str(iT) ' seconds'])
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

mPF=get(handles.multiPageFlag, 'Value');

if mPF==0
    imPath=uigetdir;
    assignin('base','importPath',imPath);
    filterString={get(handles.fileFilterString,'String')};
    filteredFiles = dir([imPath filesep '*' filterString{1} '*']); % '*.' imageType{1}
    assignin('base','filteredFiles',filteredFiles);
    eNum=numel(filteredFiles);
    set(handles.endImageEntry,'string',num2str(eNum))
elseif mPF==1
    % todo: all files flag
    [tifFile,imPath]=uigetfile('*.*','Select your tif file');
    mpTifInfo=imfinfo([imPath tifFile]);
    imageCount=length(mpTifInfo);
    set(handles.endImageEntry,'string',num2str(imageCount));
    assignin('base','mpTifInfo',mpTifInfo);
    assignin('base','importPath',imPath);
    assignin('base','tifFile',tifFile);
end



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





% --- Executes on button press in registerButton.
function registerButton_Callback(hObject, eventdata, handles)
% hObject    handle to registerButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the string for the stack you want to register; this will be a string
regStackString=evalin('base','stackToRegister');

% todo: allow user to crop what they want
% the way I do the registration rotates the image, here I offset that


regTemp=evalin('base','regTemplate');
rStack=evalin('base',regStackString);
subpixelFactor=100;
totalImagesPossible=size(rStack,3);

% pre-allocate, because ... matlab ...

registeredImages=zeros(size(rStack,1),size(rStack,2),totalImagesPossible,'uint16');
registeredTransformations=zeros(4,totalImagesPossible);

disp('registration started ...')

tic
regTempC=regTemp;
    parfor n=1:totalImagesPossible,
        imReg=rStack(:,:,n);
        [out1,out2]=dftregistration(fft2(regTempC),fft2(imReg),subpixelFactor);
        registeredTransformations(:,n)=out1;
        registeredImages(:,:,n)=abs(ifft2(out2));
        %registeredImages(:,:,n)=imrotate(abs(ifft2(out2)),180);
    end
t=toc;
disp(['done with registration. it took ' num2str(t) ' seconds'])
assignin('base',[regStackString '_registered'],uint16(registeredImages))
assignin('base','registeredTransforms',registeredTransformations)


% update var box
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
totalImagesPossible=(firstIm-1)+imageCount;
registeredTransformations=zeros(4,totalImagesPossible);
subpixelFactor=100;

regTemp=evalin('base','regTemplate');

saveTiffFlag=get(handles.saveRegTiffsToggle,'Value'); % im changing the behavior of this to be save to workspace

tic
if saveTiffFlag==0
    parfor n=firstIm:endIm,
        [out1,~]=dftregistration(fft2(regTemp),fft2(imread([imPath filesep filteredFiles(n,1).name],'tif')),subpixelFactor);
        registeredTransformations(:,n)=out1;
    end
    % shave the pad and write out
    assignin('base','registeredTransforms',registeredTransformations(:,firstIm:endIm))

elseif saveTiffFlag==1
    % pre-alloc the stack
    registeredImages=zeros(size(regTemp,1),size(regTemp,2),totalImagesPossible,'uint16');
    parfor n=firstIm:endIm,
        [out1,out2]=dftregistration(fft2(regTemp),fft2(imread([imPath filesep filteredFiles(n,1).name],'tif')),subpixelFactor);
        registeredTransformations(:,n)=out1;
        registeredImages(:,:,n)=abs(ifft2(out2));
    end
    % shave the pad and write out
    assignin('base','registeredTransforms',registeredTransformations(:,firstIm:endIm))
    assignin('base',['registeredStack_' filterString],uint16(registeredImages(:,:,firstIm:endIm)))
end

toc



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


% --- Executes on button press in multiPageFlag.
function multiPageFlag_Callback(hObject, eventdata, handles)
% hObject    handle to multiPageFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of multiPageFlag



function stackSplit_textAppend_Callback(hObject, eventdata, handles)
% hObject    handle to stackSplit_textAppend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stackSplit_textAppend as text
%        str2double(get(hObject,'String')) returns contents of stackSplit_textAppend as a double


% --- Executes during object creation, after setting all properties.
function stackSplit_textAppend_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stackSplit_textAppend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in stackSplit_everyOtherToggle.
function stackSplit_everyOtherToggle_Callback(hObject, eventdata, handles)
% hObject    handle to stackSplit_everyOtherToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stackSplit_everyOtherToggle

set(handles.stackSplit_serialToggle,'Value',0);
set(handles.stackSplit_everyOtherToggle,'Value',1);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in stackSplit_serialToggle.
function stackSplit_serialToggle_Callback(hObject, eventdata, handles)
% hObject    handle to stackSplit_serialToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stackSplit_serialToggle

set(handles.stackSplit_serialToggle,'Value',1);
set(handles.stackSplit_everyOtherToggle,'Value',0);

% Update handles structure
guidata(hObject, handles);



function splitStackCountEntry_Callback(hObject, eventdata, handles)
% hObject    handle to splitStackCountEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of splitStackCountEntry as text
%        str2double(get(hObject,'String')) returns contents of splitStackCountEntry as a double


% --- Executes during object creation, after setting all properties.
function splitStackCountEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to splitStackCountEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in splitStackButton.
function splitStackButton_Callback(hObject, eventdata, handles)
% hObject    handle to splitStackButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% First determine where to split and by how much.
splitCount=str2num(get(handles.splitStackCountEntry,'String'));

if get(handles.stackSplit_serialToggle,'Value')==1
    splitType=0;
elseif get(handles.stackSplit_everyOtherToggle,'Value')==1
    splitType=1;
end

deleteOG=get(handles.deleteOGStack_toggle,'Value');


% Now apply to the selected stack (keep in workspace).
selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
selectStack=selections{selectionsIndex};

ogStackSize=evalin('base',['size(' selectStack ',3)']);
ab=get(handles.stackSplit_textAppend,'String');
stackStrings=strsplit(ab,',');

if splitType==1
    for n=1:splitCount;
        evalin('base',[stackStrings{n} '=' selectStack '(:,:,' num2str(n) ':' num2str(splitCount) ':' num2str(ogStackSize-(splitCount-n)) ');'])
    end
    if deleteOG==1
        evalin('base',['clear ' selectStack])
        vars = evalin('base','who');
        set(handles.workspaceVarBox,'String',vars)
    else
        vars = evalin('base','who');
        set(handles.workspaceVarBox,'String',vars)
    end
elseif splitType==0
    chunkSize=fix(ogStackSize/splitCount);
    for n=1:splitCount;
        evalin('base',[stackStrings{n} '=' selectStack '(:,:,1+' num2str((n-1)*chunkSize) ':' num2str((n)*chunkSize) ');'])
    end
    if deleteOG==1
        evalin('base',['clear ' selectStack])
        vars = evalin('base','who');
        set(handles.workspaceVarBox,'String',vars)
    else
        vars = evalin('base','who');
        set(handles.workspaceVarBox,'String',vars)
    end
end



    
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in deleteOGStack_toggle.
function deleteOGStack_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to deleteOGStack_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of deleteOGStack_toggle


% --- Executes on button press in applyTransformsButton.
function applyTransformsButton_Callback(hObject, eventdata, handles)
% hObject    handle to applyTransformsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
selectStack=selections{selectionsIndex};

disp('applying transforms ...')
evalin('base',[selectStack '_registered=applyTransformsToStack(' selectStack ',registeredTransforms);'])
disp('*** done applying transforms')

% update var box
vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in inspectImageButton.
function inspectImageButton_Callback(hObject, eventdata, handles)
% hObject    handle to inspectImageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
imageToPlot=selections{selectionsIndex};

evalin('base',['figure,imagesc(' imageToPlot '),axis square,colormap(''jet''),title ' imageToPlot])

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in inspectStackButton.
function inspectStackButton_Callback(hObject, eventdata, handles)
% hObject    handle to inspectStackButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
stackToPlot=selections{selectionsIndex};

evalin('base',['figure,playMov(' stackToPlot ')'])

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in parallelizeImportToggle.
function parallelizeImportToggle_Callback(hObject, eventdata, handles)
% hObject    handle to parallelizeImportToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of parallelizeImportToggle



function importWorkerEntry_Callback(hObject, eventdata, handles)
% hObject    handle to importWorkerEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of importWorkerEntry as text
%        str2double(get(hObject,'String')) returns contents of importWorkerEntry as a double


% --- Executes during object creation, after setting all properties.
function importWorkerEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to importWorkerEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in parallelizeRegistrationToggle.
function parallelizeRegistrationToggle_Callback(hObject, eventdata, handles)
% hObject    handle to parallelizeRegistrationToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of parallelizeRegistrationToggle



function registrationWorkerEntry_Callback(hObject, eventdata, handles)
% hObject    handle to registrationWorkerEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of registrationWorkerEntry as text
%        str2double(get(hObject,'String')) returns contents of registrationWorkerEntry as a double


% --- Executes during object creation, after setting all properties.
function registrationWorkerEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to registrationWorkerEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in inferRunningButton.
function inferRunningButton_Callback(hObject, eventdata, handles)
% hObject    handle to inferRunningButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

evalin('base','inferedRunningData=inferRunFromRegistration(registeredTransforms(3,:));')
evalin('base','figure,plot(inferedRunningData),title(''normalized running data infered from reg data'')')

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in getLuminanceButton.
function getLuminanceButton_Callback(hObject, eventdata, handles)
% hObject    handle to getLuminanceButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
stackToPlot=selections{selectionsIndex};

evalin('base',['for n=1:size(' stackToPlot ',3),' stackToPlot '_meanLuminance(:,n)=mean2(' stackToPlot '(:,:,n));,end'])

evalin('base',['figure,plot(' stackToPlot '_meanLuminance),title ' stackToPlot ''': mean lum.'''])

% Update handles structure
guidata(hObject, handles);



function constrainedMeanEntry_Callback(hObject, eventdata, handles)
% hObject    handle to constrainedMeanEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of constrainedMeanEntry as text
%        str2double(get(hObject,'String')) returns contents of constrainedMeanEntry as a double


% --- Executes during object creation, after setting all properties.
function constrainedMeanEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to constrainedMeanEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in contrainedMeanProjectButton.
function contrainedMeanProjectButton_Callback(hObject, eventdata, handles)
% hObject    handle to contrainedMeanProjectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ab=get(handles.constrainedMeanEntry,'String');
constrainedFrames=strsplit(ab,',');

selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
selectStack=selections{selectionsIndex};

s=evalin('base',[selectStack '(:,:,' constrainedFrames{1} ':' constrainedFrames{2} ');']);
mP=mean(s,3);
assignin('base',['consMeanProj_' selectStack],uint16(mP));



vars = evalin('base','who');
set(handles.workspaceVarBox,'String',vars)



% Update handles structure
guidata(hObject, handles);



function outlierThresholdEntry_Callback(hObject, eventdata, handles)
% hObject    handle to outlierThresholdEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outlierThresholdEntry as text
%        str2double(get(hObject,'String')) returns contents of outlierThresholdEntry as a double


% --- Executes during object creation, after setting all properties.
function outlierThresholdEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outlierThresholdEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in tossOutlierButton.
function tossOutlierButton_Callback(hObject, eventdata, handles)
% hObject    handle to tossOutlierButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ab=get(handles.outlierThresholdEntry,'String');
lumThresholds=strsplit(ab,',');

% The logic will be to select the stack then it will reconcile the lum
% values. This will break if someone doesn't select the stack, or have no
% lum values. todo: gray button out until the lum values are calculated
selections = get(handles.workspaceVarBox,'String');
selectionsIndex = get(handles.workspaceVarBox,'Value');
selectStack=selections{selectionsIndex};

ogFrames=evalin('base',['size(' selectStack ',3);']);
lumValues=evalin('base',[selectStack '_meanLuminance']);

for n=1:numel(lumThresholds)
    badFrames{n}=eval(['find(lumValues' lumThresholds{n} ');']);
end
badFrames=cell2mat(badFrames);
assignin('base','badFrames',badFrames)
evalin('base',[selectStack '=' selectStack '(:,:,setdiff(1:' num2str(ogFrames) ',badFrames));']);


% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in diskLumValButton.
function diskLumValButton_Callback(hObject, eventdata, handles)
% hObject    handle to diskLumValButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guiFeedback=1;
feedbackBlockSize=2000;
sImageImRate=0.002;

imPath=evalin('base','importPath');
fileList=evalin('base','filteredFiles');
firstIm=str2num(get(handles.firstImageEntry,'string'));
disp(['first image= ' num2str(firstIm)])  % **** debug
endIm=str2num(get(handles.endImageEntry,'string'));

numImages=endIm-firstIm;

% enforce feedback by default if there are a bunch of images
if numImages>25000;
    disp('*** you have a lot of images, I am going to give progress updates ***')
    guiFeedback=1;
else
    disp('you do not have too many images so I will opt to not give feedback about progress, unless you asked earlier')
end



% took a parloop 20.9 min for 124800 images (10 ms/image; slower than
% usual) 17.8339 with a for loop.

disp(['about to extract, this should take ~ ' num2str((sImageImRate*numImages)./60) ' minutes'])
cc=clock;
disp(['started at ' num2str(cc(4)) ':'  num2str(cc(5))])
eT=0;  % elapsed time container
tic
disp('extracting')
diskLuminance=zeros(1,numImages);

for n=firstIm:endIm;
    funcN=(n-firstIm)+1;
    diskLuminance(:,funcN)=mean2(imread([imPath filesep fileList(n).name]));
    if (mod(funcN,feedbackBlockSize)==0 && guiFeedback==1)
        eT=eT+toc;
        tic
        fEst=eT/funcN;
        disp(['... extracted ' num2str(feedbackBlockSize) ' more images in ' num2str(eT) '; just ' num2str(numImages-funcN) ' to go ...'])
        disp(['**** import/extraction rate = ' num2str(fEst)])
        disp(['*** new finish time estimate =' num2str((fEst*(numImages-funcN))) ' seconds'])
        disp(' ')
    else
    end
end
% there is a very tiny performance hit to do the funcN assignment outside
% the loop assignment, but when I add the feedback it cancels out.

assignin('base','diskLuminance',diskLuminance);
disp(['done luminance extraction, this took ' num2str(eT./60) ' minutes'])
cc=clock;
disp(['finished disk luminance at ' num2str(cc(4)) ':'  num2str(cc(5))])
