function varargout = importer(varargin)

% IMPORTER is a simple gui for importing image files into matlab and
% performing some basic pre-processing.
%
% v1.2 -- HDF Support; Scales text up on a Mac.
%
% cdeister@brown.edu with any questions
% last modified: CAD 2/10/2018


% matlab gui init stuff
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


function sendFeedback(hObject,eventdata,handles,uString)
    set(handles.feedbackString,'String',uString)
    pause(0.000000001)
    guidata(hObject, handles);
function importButton_Callback(hObject, eventdata, handles)
    
    mPF=get(handles.multiPageFlag, 'Value');
    hdfF=get(handles.importFromHDF, 'Value');
    pImport=get(handles.parallelizeRegistrationToggle,'Value');

    try
        evalin('base','metaData.importPath;');
        disp('importing images ...')
        pathExists=1;
    catch
        pathExists=0;
    end
    
    % User has set a path, but doesn't want multi-page tif.
    if pathExists==1 && mPF==0 && hdfF==0
        imPath=evalin('base','metaData.importPath');
        firstIm=str2num(get(handles.firstImageEntry,'string'));
        endIm=str2num(get(handles.endImageEntry,'string'));
    
    % User has not set a path, and doesn't want multi-page tif.    
    elseif pathExists==0 && mPF==0 && hdfF==0
        imPath=uigetdir;
        firstIm=str2num(get(handles.firstImageEntry,'string'));
        endIm=str2num(get(handles.endImageEntry,'string'));
    
    % User has set a path, but wants multi-page tif.    
    elseif pathExists==1 && mPF==1 && hdfF==0
        imPath=evalin('base','metaData.importPath');
        tifFile=evalin('base','metaData.tifFile');
        mpTifInfo=evalin('base','metaData.mpTifInfo');
         firstIm=str2num(get(handles.firstImageEntry,'string'));
         endIm=str2num(get(handles.endImageEntry,'string'));
    
    % User has set not path, and wants multi-page tif.    
    elseif pathExists==0 && mPF==1 && hdfF==0
        [tifFile,imPath]=uigetfile('*.*','Select your tif file');
        mpTifInfo=imfinfo([imPath tifFile]);
        imageCount=length(mpTifInfo);
        firstIm=str2num(get(handles.firstImageEntry,'string'));
        endIm=str2num(get(handles.endImageEntry,'string'));
        assignin('base','mpTifInfo',mpTifInfo);
        assignin('base','tifFile',tifFile);
        assignin('base','imPath',imPath);
        evalin('base','metaData.mpTifInfo=mpTifInfo;,clear ans ''mpTifInfo''')
        evalin('base','metaData.importPath=importPath;,clear ans ''importPath''')
        evalin('base','metaData.tifFile=tifFile;,clear ans ''tifFile''')
    
    % User has set not path, and wants an HDF. 
    elseif pathExists==0 && hdfF==1
        [hdfFile,imPath]=uigetfile('*.*','Select your hdf file');
        tI=h5info([imPath hdfFile]);
        dSetNames={tI.Datasets.Name};
        clear tI;
        set(handles.hdfPopSelector,'String',dSetNames);
        assignin('base','importPath',imPath);
        assignin('base','hdfFile',hdfFile);
        evalin('base','metaData.importPath=importPath;,clear ans ''importPath''')
        evalin('base','metaData.hdfFile=hdfFile;,clear ans ''hdfFile''')
        handles.hdfPopSelector_Callback(hObject, eventdata, handles);
        
    % User has set a path, and wants an HDF.
    elseif pathExists==1 && hdfF==1
        selectVal=get(handles.hdfPopSelector,'Value');
        tDS=get(handles.hdfPopSelector,'String');
        tDS_select=tDS{selectVal};
        tP=evalin('base','metaData.importPath');
        tH=evalin('base','metaData.hdfFile');
        

        tSInfo=h5info([tP tH],['/' tDS_select]);
        dsSize=tSInfo.Dataspace.Size;
        assignin('base','hdfSize',dsSize);
        evalin('base','metaData.hdfSize=hdfSize;,clear hdfSize');
    end
    
    % always see if the user wants sequential (skipBy=1)        
    skipBy=fix(str2double(get(handles.skipFactorEntry,'String')));

    % The code above sets up the kind of import you want.
    % Below is the import routines for each. context.
    % This loads a file list that has characters that match the filter string.
    % It should detect the bit depth and dimensions.
    importType=evalin('base','metaData.importType;');
    if mPF==0 && hdfF==0
        set(handles.importButton,'Enable','off')
        pause(0.00000000000000001)
        guidata(hObject, handles);

        try
            filterString={get(handles.fileFilterString,'String')};
            filteredFiles = dir([imPath filesep '*' filterString{1} '*']);
            
            % kill files that have no data in them.
            filteredFiles(find([filteredFiles.bytes]==0))=[];
            filteredFiles=resortImageFileMap(filteredFiles);
            assignin('base','filteredFiles',filteredFiles)
            assignin('base','imPath',imPath)
            
            importCount=fix(((endIm-firstIm)+1)/skipBy);

            % I try to preserve bitdepth.
            canaryImport=imread([imPath filesep filteredFiles(1,1).name]);
            [imType,imSize]=checkStackBitDepth(canaryImport);

            assignin('base','bitDepth',imType);
            evalin('base','metaData.bitDepth=bitDepth;clear bitDepth');
            assignin('base','imSize',imSize);
            evalin('base','metaData.imSize=imSize;clear imSize');
            

            % tempFilt is just the files in firstIM:skip:end,
            tempFiltFiles=filteredFiles(firstIm:skipBy:endIm,1);
            assignin('base','tempFiltFiles',tempFiltFiles);
            evalin('base',['importedImages=zeros(' num2str(imSize(1)) ',' ...
                num2str(imSize(2)) ',numel(tempFiltFiles),''' imType ''');']);
            evalin('base','metaData.lastImported=tempFiltFiles;')
            
            tic
            if pImport==1
                set(handles.feedbackString,'String','Parallel Import Ongoing ...')
                pause(0.00000000000000001)
                guidata(hObject, handles);
                evalin('base',['parfor n=1:numel(tempFiltFiles),importedImages(:,:,n)=imread([imPath filesep tempFiltFiles(n,1).name]);,end'])
            
            % the main difference (beyond the parfor loop) is we update the gui's feedback
            % differently as we don't know the specific item we've imported.
            elseif pImport==0
                set(handles.feedbackString,'String',['Importing ...'])
                pause(0.00000000000000001)
                guidata(hObject, handles);
                for n=1:numel(tempFiltFiles)
                    evalin('base',['importedImages(:,:,' num2str(n) ')=imread([imPath filesep tempFiltFiles(' num2str(n) ',1).name]);'])
                    if mod(n,500)==0
                        set(handles.importButton,'String',[num2str(n) '/' num2str(numel(tempFiltFiles))])
                        pause(0.00000000000000001)
                        guidata(hObject, handles);
                    else
                    end
            
                end
            end
            iT=toc;

            set(handles.importButton,'String','WS Import')
            set(handles.importButton,'Enable','on')
            set(handles.feedbackString,'String',['Imported ' num2str(numel(tempFiltFiles)) ' Images'])
            evalin('base','clear imPath ans filteredFiles tempFiltFiles')
            pause(0.00000000000000001)
            guidata(hObject, handles);
            iT=toc;
        catch
            set(handles.importButton,'Enable','on')
            pause(0.00000000000000001)
            guidata(hObject, handles);
            iT=toc;
        end
        
    elseif importType==1  % The user wants multi-page tif. This import is a bit different.
        disp('yo')
        set(handles.importButton,'Enable','off')
        pause(0.00000000000000001)
        guidata(hObject, handles);
        try
            
            % This gets metadata needed. 
            bitD=mpTifInfo(1).BitDepth;
            mImage=mpTifInfo(1).Width;
            nImage=mpTifInfo(1).Height;
            
            % now figure out what images to import.
            maxImages=length(mpTifInfo);
            numImages=numel(firstIm:endIm);
            
            if numImages>maxImages
                disp('your image range is invalid will do 1:all')
                firstIm=1;
                endIm=maxImages-1;
            else
            end
            imRange=firstIm:skipBy:endIm;
            
            if bitD==8 || bitD==16 || bitD==32
                eval(['imType=''uint' num2str(bitD) '''' ';'])
            else
                imType='Double';
            end
            
            importedStack=zeros(nImage,mImage,numel(imRange),imType);
            
            tic
            if pImport==1
                set(handles.feedbackString,'String',['Parallel Import Ongoing ...'])
                pause(0.00000000000000001)
                guidata(hObject, handles);
                parfor i=1:numel(imRange)
                    pImRange=imRange;
                    importedStack(:,:,i)=imread([imPath tifFile],'Index',pImRange(i));
                end
            elseif pImport==0
                set(handles.feedbackString,'String',['Importing ...'])
                guidata(hObject, handles);        
                for i=1:numel(imRange)
                    if mod(i,500)==0
                        set(handles.importButton,'String',[num2str(i) '/' ...
                         num2str(numel(imRange))])
                        pause(0.00000000000000001)
                        guidata(hObject, handles);
                    else
                    end
                    importedStack(:,:,i)=imread([imPath tifFile],'Index',imRange(i));
                end
            end
            
            assignin('base','importedStack',importedStack)
            disp('yo2')
            set(handles.importButton,'String','WS Import')
            set(handles.importButton,'Enable','on')
            set(handles.feedbackString,'String',['Imported ' num2str(dispSize) ' Images'])
            pause(0.00000000000000001)
            guidata(hObject, handles);
            iT=toc;
        catch
            set(handles.importButton,'String','WS Import')
            set(handles.importButton,'Enable','on')
            pause(0.00000000000000001)
            guidata(hObject, handles);
            iT=toc;
        end

        
    
    
    elseif importType==2
        set(handles.importButton,'Enable','off')
        pause(0.00000000000000001)
        guidata(hObject, handles);
        
        try
            selectVal=get(handles.hdfPopSelector,'Value');
            tDS=get(handles.hdfPopSelector,'String');
            tDS_select=tDS{selectVal};
            tP=evalin('base','metaData.importPath');
            tH=evalin('base','metaData.hdfFile');
            evalin('base','clear ans')
            

            tSInfo=h5info([tP tH],['/' tDS_select]);
            dsSize=tSInfo.Dataspace.Size;
            zOne=get(handles.zDimFlip,'Value');
            assignin('base','hdfZDim',zOne);
            evalin('base','metaData.hdfZDim=hdfZDim;,clear hdfZDim');
            
            tic
            if zOne==1 && numel(dsSize)==3
                
                firstIm=str2num(get(handles.firstImageEntry,'string'));
                endIm=str2num(get(handles.endImageEntry,'string'));
                skipBy=fix(str2double(get(handles.skipFactorEntry,'String')));
                cStride=(endIm-firstIm)+1;
                tData=h5read([tP tH],['/' tDS_select],[firstIm 1 1],[cStride dsSize(2) dsSize(3)]);
                tData=permute(tData,[3,2,1]);
                dispSize=size(tData,3);
            
            
            elseif zOne==0 && numel(dsSize)==3
                
                firstIm=str2num(get(handles.firstImageEntry,'string'));
                endIm=str2num(get(handles.endImageEntry,'string'));

                cStride=(endIm-firstIm)+1;
                tData=h5read([tP tH],['/' tDS_select],[1 1 firstIm],[dsSize(1) dsSize(2) cStride]);
                dispSize=size(tData,3);
            
            
            elseif numel(dsSize)~=3
                
                tData=h5read([tP tH],['/' tDS_select]);
                dispSize=numel(tData);
            end
            
            assignin('base','tDS_select',tDS_select);
            evalin('base','metaData.tDS_select=tDS_select;,clear tDS_select');

            tdSplit=strsplit(tDS_select, '-');
            tdUse='';
            if numel(tdSplit)>1
                for n=1:numel(tdSplit)
                    if n==1
                        tdUse=[tdUse tdSplit{n}];
                    else
                        tdUse=[tdUse '_' tdSplit{n}];
                    end
                end
            else
                tdUse=tDS_select;
            end
                        
            assignin('base',tdUse,tData);
            clear tData
            set(handles.importButton,'String','WS Import')
            set(handles.importButton,'Enable','on')
            set(handles.feedbackString,'String',['Imported ' num2str(dispSize) ...
                ' Images'])
            pause(0.00000000000000001)
            guidata(hObject, handles);
            iT=toc;
        catch
            set(handles.importButton,'String','WS Import')
            set(handles.importButton,'Enable','on')
            pause(0.00000000000000001)
            guidata(hObject, handles);
            iT=toc;
        end

    end
    disp(['*** done with import, which took ' num2str(iT) ' seconds'])
    refreshVarListButton_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
function setDirectoryButton_Callback(hObject, eventdata, handles)
    try
        mPF=get(handles.multiPageFlag, 'Value');
        hdfF=get(handles.importFromHDF, 'Value');

        try
            lastPath=evalin('base','metaData.importPath');
        catch
            lastPath=[filesep];
        end

        if mPF==0 && hdfF==0
           
            imPath=uigetdir(lastPath);
            
            if imPath~=0
                assignin('base','importPath',imPath);
                filterString={get(handles.fileFilterString,'String')};
                filteredFiles = dir([imPath filesep '*' filterString{1} '*']); 
                assignin('base','filteredFiles',filteredFiles);
                eNum=numel(filteredFiles);
                set(handles.endImageEntry,'string',num2str(eNum))
                evalin('base','metaData.filteredFiles=filteredFiles;')
                evalin('base','metaData.importPath=importPath;,clear ans importPath filteredFiles')
                canaryImport=imread([imPath filesep filteredFiles(1,1).name]);
                [imType,imSize]=checkStackBitDepth(canaryImport);
                assignin('base','bitDepth',imType);
                evalin('base','metaData.bitDepth=bitDepth;clear bitDepth');
                assignin('base','imSize',imSize);
                evalin('base','metaData.imSize=imSize;clear imSize');
                

                fileNameGuess=strsplit(filteredFiles(1).folder,filesep);
                set(handles.saveEntryText,'string',[fileNameGuess{end-1} ',' fileNameGuess{end}])
                evalin('base','importType=0;');
                evalin('base','metaData.importType=importType;,clear importType');
            else
            end
            
            
        elseif mPF==1
            [tifFile,imPath]=uigetfile('*.*','Select your tif file');
            if imPath~=0
                mpTifInfo=imfinfo([imPath tifFile]);
                imageCount=length(mpTifInfo);
                set(handles.endImageEntry,'string',num2str(imageCount));
                assignin('base','mpTifInfo',mpTifInfo);
                assignin('base','importPath',imPath);
                assignin('base','tifFile',tifFile);
                evalin('base','metaData.mpTifInfo=mpTifInfo;,clear ans mpTifInfo')
                evalin('base','metaData.importPath=importPath;,clear ans importPath')
                evalin('base','metaData.tifFile=tifFile;,clear ans tifFile')
                fileNameGuess=strsplit(imPath,filesep);
                set(handles.saveEntryText,'string',[filesep fileNameGuess{end-1} filesep tifFile])
                evalin('base','importType=1;');
                evalin('base','metaData.importType=importType;,clear importType');
            else
            end
            
            
        elseif hdfF==1
            [hdfFile,imPath]=uigetfile('*.*','Select your hdf file');
            if imPath~=0
                
                tI=h5info([imPath hdfFile]);
                dSetNames={tI.Datasets.Name};
                clear tI;
                set(handles.hdfPopSelector,'String',dSetNames);
                
                assignin('base','importPath',imPath);
                assignin('base','hdfFile',hdfFile);
                
                evalin('base','metaData.importPath=importPath;,clear ans ''importPath''')
                evalin('base','metaData.hdfFile=hdfFile;,clear ans ''hdfFile''')
                evalin('base','importType=2;');
                evalin('base','metaData.importType=importType;,clear importType');

            else
            end
        end
    catch
    end



    refreshVarListButton_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
function workspaceVarBox_Callback(hObject, eventdata, handles)

    refreshVarListButton_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
function meanProjectButton_Callback(hObject, eventdata, handles)
    set(handles.meanProjectButton,'Enable','off')
    try
    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');

    for n=1:numel(selectionsIndex)
        s=evalin('base',selections{selectionsIndex(n)});
        mP=mean(s,3);
        if strcmp(class(s),'uint16')
            assignin('base',['meanProj_' selections{selectionsIndex(n)}],...
                im2uint16(mP,'Indexed'));
        else
            assignin('base',['meanProj_' selections{selectionsIndex(n)}],double(mP));
        end
    end

    axes(handles.imageAxis)
    imagesc(uint16(mP))
    set(handles.meanProjectButton,'Enable','on')
    refreshVarListButton_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
    catch
        set(handles.meanProjectButton,'Enable','on')
    end
function templateButton_Callback(hObject, eventdata, handles)

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
    refreshVarListButton_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
function setRegStackButton_Callback(hObject, eventdata, handles)

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
    refreshVarListButton_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
function registerButton_Callback(hObject, eventdata, handles)
    set(handles.registerButton,'Enable','off')
    try
    regStackString=evalin('base','stackToRegister');
    regTemp=evalin('base','regTemplate');
    tCl=whos('regTemp');
    % todo use imType to deal with non uint16
    imType=tCl.class;
    stackSize=evalin('base',['size(' regStackString ');']);
    subpixelFactor=50;
    try
        totalImagesPossible=stackSize(3);
    catch
        totalImagesPossible=1;
    end

    evalin('base',['registeredTransformations=zeros(4,' num2str(totalImagesPossible) ');']);
    pImport=get(handles.parallelizeRegistrationToggle,'Value');

    tic
    if pImport
        regTempC=regTemp;
        set(handles.feedbackString,'String',' par registration started ...')
        pause(0.0000000000001);
        guidata(hObject, handles);
        parfor n=1:totalImagesPossible
            imReg=evalin('base',[regStackString '(:,:,' num2str(n) ');']);
            [out1,out2]=dftregistration(fft2(regTempC),fft2(imReg),subpixelFactor);
            assignin('base',['registeredTransformations(:,' num2str(n) ')'],out1);
            assignin('base',[regStackString '(:,:,' num2str(n) ')'],uint16(abs(ifft2(out2))));

        end
        clear regTempC
    else
        set(handles.feedbackString,'String','registration started ...')
        pause(0.0000000000001);
        guidata(hObject, handles);
        for n=1:totalImagesPossible
            imReg=evalin('base',[regStackString '(:,:,' num2str(n) ');']);
            [out1,out2]=dftregistration(fft2(regTemp),fft2(imReg),subpixelFactor);
            
            assignin('base','out1',out1);
            evalin('base',['registeredTransformations(:,' num2str(n) ')=out1;,clear out1'])

            assignin('base','out2',uint16(abs(ifft2(out2))));
            evalin('base',[regStackString '(:,:,' num2str(n) ')=out2;,clear out2'])

            if mod(n,200)==0
                set(handles.registerButton,'String',[num2str(n) ...
                 '/' num2str(totalImagesPossible)])
                pause(0.0000000000001);
                guidata(hObject, handles);
            else
            end
        end
    end
        
    t=toc;
    set(handles.registerButton,'String','Register Stacks')
    set(handles.feedbackString,'String','finished registration')
    set(handles.registerButton,'Enable','on')
    pause(0.0000000000001);
    guidata(hObject, handles);
    disp(['done with registration. it took ' num2str(t) ' seconds'])
    refreshVarListButton_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
    catch
        set(handles.registerButton,'Enable','on')
    end
function refreshVarListButton_Callback(hObject, eventdata, handles)

    vars = evalin('base','who');
    set(handles.workspaceVarBox,'String',vars)
    guidata(hObject, handles);
function saveStackButton_Callback(hObject, eventdata, handles)


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
        evalin('base',['parfor n=(' num2str(firstIm) '+1):' num2str(endIm) ',imwrite(importedStack_Ch3(:,:,n-' firstIm ... 
            '), [stackObject_meta.stackName{1} ''.tif''], ''writemode'', ''append'');,end']);
        toc
    end

    evalin('base','clear ''stackObject_meta''')

    % import the read/write stack object (this could be cleaned up a tad).
    evalin('base',['stackObject=matfile([stackObject_meta.objectPath filesep stackObject_meta.objectName ''.mat''],''Writable'',true);']);


    set(handles.feedbackString,'String','done saving stack');
    guidata(hObject, handles);
    evalin('base','clear ans ''stackObject''')


    refreshVarListButton_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
function saveDirectoryButton_Callback(hObject, eventdata, handles)

    savDir=uigetdir;
    assignin('base','savePath_stacks',savDir);

    refreshVarListButton_Callback(hObject, eventdata, handles)
    % Update handles structure
    guidata(hObject, handles);
function stackObjectNameEntry_Callback(hObject, eventdata, handles)


function diskRegisterButton_Callback(hObject, eventdata, handles)

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
    assignin('base','importedFileList',filteredFiles)
    evalin('base','metaData.filteredFiles=filteredFiles;,clear filteredFiles')


    % we need to pad from 1 to the image you care about, because par loops
    % won't let you correct for the shift.
    totalImagesPossible=(firstIm-1)+imageCount;
    registeredTransformations=zeros(4,totalImagesPossible);
    subpixelFactor=100;

    regTemp=evalin('base','regTemplate');

    saveTiffFlag=get(handles.saveRegTiffsToggle,'Value'); % im changing the behavior of this to be save to workspace

    tic
    if saveTiffFlag==0
        parfor n=firstIm:endIm
            [out1,~]=dftregistration(fft2(regTemp),fft2(imread([imPath filesep filteredFiles(n,1).name],'tif')),subpixelFactor);
            registeredTransformations(:,n)=out1;
        end
        % shave the pad and write out
        assignin('base','registeredTransforms',registeredTransformations(:,firstIm:endIm))

    elseif saveTiffFlag==1
        % pre-alloc the stack
        registeredImages=zeros(size(regTemp,1),size(regTemp,2),totalImagesPossible,'uint16');
        parfor n=firstIm:endIm
            [out1,out2]=dftregistration(fft2(regTemp),fft2(imread([imPath filesep filteredFiles(n,1).name],'tif')),subpixelFactor);
            registeredTransformations(:,n)=out1;
            registeredImages(:,:,n)=abs(ifft2(out2));
        end
        % shave the pad and write out
        assignin('base','registeredTransforms',registeredTransformations(:,firstIm:endIm))
        assignin('base',['registeredStack_' filterString],uint16(registeredImages(:,:,firstIm:endIm)))
    end

    toc
    refreshVarListButton_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
function saveRegTiffsToggle_Callback(hObject, eventdata, handles)
function selectDiskMeanProjectButton_Callback(hObject, eventdata, handles)


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
        

    refreshVarListButton_Callback(hObject, eventdata, handles)
    % Update handles structure
    guidata(hObject, handles);
function filterDiskProjectToggle_Callback(hObject, eventdata, handles)
function multiPageFlag_Callback(hObject, eventdata, handles)
    set(handles.importFromHDF, 'Value',0);
function stackSplit_textAppend_Callback(hObject, eventdata, handles)
function stackSplit_everyOtherToggle_Callback(hObject, eventdata, handles)


    set(handles.stackSplit_serialToggle,'Value',0);
    set(handles.stackSplit_everyOtherToggle,'Value',1);

    refreshVarListButton_Callback(hObject, eventdata, handles)
    % Update handles structure
    guidata(hObject, handles);
function stackSplit_serialToggle_Callback(hObject, eventdata, handles)

    set(handles.stackSplit_serialToggle,'Value',1);
    set(handles.stackSplit_everyOtherToggle,'Value',0);

    refreshVarListButton_Callback(hObject, eventdata, handles)
    % Update handles structure
    guidata(hObject, handles);
function splitStackCountEntry_Callback(hObject, eventdata, handles)
function splitStackButton_Callback(hObject, eventdata, handles)

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
    if numel(stackStrings) ~= splitCount
        appendIt=1;
    else
        appendIt=0;
    end

    if splitType==1
        for n=1:splitCount
            if appendIt==1
                tStr=['St_' num2str(n)];
            else
               tStr=stackStrings{n};
            end
            evalin('base',[tStr '=' selectStack '(:,:,' num2str(n) ':' ...
                num2str(splitCount) ':' num2str(ogStackSize-(splitCount-n)) ');'])
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
        for n=1:splitCount
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

    refreshVarListButton_Callback(hObject, eventdata, handles)    
    guidata(hObject, handles);
function deleteOGStack_toggle_Callback(hObject, eventdata, handles)
function applyTransformsButton_Callback(hObject, eventdata, handles)

    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    selectStack=selections{selectionsIndex};

    set(handles.feedbackString,'String','applying transforms ...')
    pause(0.000000001)
    guidata(hObject, handles);
    evalin('base',[selectStack '=applyTransformsToStack(' selectStack ',registeredTransforms);'])
    set(handles.feedbackString,'String','done applying transforms')

    refreshVarListButton_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
function inspectImageButton_Callback(hObject, eventdata, handles)

    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    imageToPlot=selections{selectionsIndex};

    tI=evalin('base',[imageToPlot '(:,:,1)']);
    axes(handles.imageAxis)
    imagesc(tI),colormap jet

    refreshVarListButton_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
function inspectStackButton_Callback(hObject, eventdata, handles)

    try 
        pS=evalin('base','metaData.iPS;');
        pS=1-pS;
        assignin('base','iPS',pS);
        evalin('base','metaData.iPS=iPS;,clear ''iPS''');
    catch
        pS=1;
        assignin('base','iPS',pS);
        evalin('base','metaData.iPS=iPS;,clear ''iPS''');
    end
    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    stackToPlot=selections{selectionsIndex};
    sPC=evalin('base',[stackToPlot '(:,:,1)']);
    tM=max(max(sPC));
    sP=evalin('base',stackToPlot);
    handles.imageAxis;

    rate=50;
    mPlt=tM+(tM*0.9);
    mfactor=.4;
    ii=1;
    i=1;
    set(handles.inspectStackButton,'String','Stop Stack')
    pause(0.0000000000001)
    guidata(hObject, handles);
    while pS==1 && i<=size(sP,3)
        axis square
        ii=(ii.*(1-mfactor))+sP(:,:,i).*mfactor;
        h=imagesc(ii,[0 mPlt]);
        axis square
        colormap('jet')
        daspect([1 1 1])
        drawnow;
        pS=evalin('base','metaData.iPS;');
        pause(rate^-1);
        guidata(hObject, handles);
        delete(h);
        i=i+1;
    end
    clear i

    assignin('base','iPS',0)
    evalin('base','metaData.iPS=iPS;,clear ''iPS''')

    set(handles.inspectStackButton,'String','Play Stack')
    pause(0.0000000000001)
    guidata(hObject, handles);

    refreshVarListButton_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
function parallelizeImportToggle_Callback(hObject, eventdata, handles)
function importWorkerEntry_Callback(hObject, eventdata, handles)

function parallelizeRegistrationToggle_Callback(hObject, eventdata, handles)
function registrationWorkerEntry_Callback(hObject, eventdata, handles)

function inferRunningButton_Callback(hObject, eventdata, handles)


    evalin('base','inferedRunningData=inferRunFromRegistration(registeredTransformations(3,:));')
    evalin('base','figure,plot(inferedRunningData),title(''normalized running data infered from reg data'')')

    refreshVarListButton_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
function getLuminanceButton_Callback(hObject, eventdata, handles)

    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    stackToPlot=selections{selectionsIndex};

    evalin('base',['for n=1:size(' stackToPlot ',3),' stackToPlot '_meanLuminance(:,n)=mean2(' stackToPlot '(:,:,n));,end'])
    evalin('base','clear n')
    mlP=evalin('base',[stackToPlot '_meanLuminance;']);
    handles.imageAxis;
    plotVectors(hObject, eventdata,handles,mlP)

    xlabel('frame')
    ylabel('mean luminance')


    refreshVarListButton_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);

function plotVectors(hObject, eventdata,handles,uvector)
    try 
        plot(uvector,'k-')
        a=gca;
        a.TickDir='out';
        a.Box='off';
        a.LineWidth=1;
        axis square
        guidata(hObject, handles);
    catch
        g=1;
    end
function constrainedMeanEntry_Callback(hObject, eventdata, handles)

function contrainedMeanProjectButton_Callback(hObject, eventdata, handles)

    ab=get(handles.constrainedMeanEntry,'String');
    constrainedFrames=strsplit(ab,',');

    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    selectStack=selections{selectionsIndex};

    s=evalin('base',[selectStack '(:,:,' constrainedFrames{1} ':' constrainedFrames{2} ');']);
    mP=mean(s,3);
    assignin('base',['consMeanProj_' selectStack],uint16(mP));

    axes(handles.imageAxis)
    imagesc(uint16(mP))

    refreshVarListButton_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
function outlierThresholdEntry_Callback(hObject, eventdata, handles)

function tossOutlierButton_Callback(hObject, eventdata, handles)

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

    refreshVarListButton_Callback(hObject, eventdata, handles)
    % Update handles structure
    guidata(hObject, handles);
function diskLumValButton_Callback(hObject, eventdata, handles)
    % hObject    handle to diskLumValButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    guiFeedback=1;
    feedbackBlockSize=2000;
    sImageImRate=0.002;

    imPath=evalin('base','Path');
    fileList=evalin('base','metaData.filteredFiles');
    firstIm=str2num(get(handles.firstImageEntry,'string'));
    disp(['first image= ' num2str(firstIm)])  % **** debug
    endIm=str2num(get(handles.endImageEntry,'string'));

    numImages=endIm-firstIm;

    % enforce feedback by default if there are a bunch of images
    if numImages>25000
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

    for n=firstIm:endIm
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

    refreshVarListButton_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
function roiMakerButton_Callback(hObject, eventdata, handles)

    evalin('base','roiMaker')
function extractorButton_Callback(hObject, eventdata, handles)

    evalin('base','extractor')

% --------------------------------------------------------------------
function graph_Callback(hObject, eventdata, handles)
function selectedObject=getWSVar(hObject, eventdata, handles)
    
    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    selectedItem=selections{selectionsIndex};
    selectedObject=evalin('base',selectedItem);

% --------------------------------------------------------------------

function plotVectorButton_Callback(hObject, eventdata, handles)

    vP=getWSVar(hObject, eventdata, handles);
    plotVectors(hObject, eventdata,handles,vP)

    refreshVarListButton_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
function deleteSelectionBtn_Callback(hObject, eventdata, handles)

    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    selectedItem=selections{selectionsIndex};
    evalin('base',['clear ' selectedItem]);

    if selectionsIndex~=1
        set(handles.workspaceVarBox,'Value',selectionsIndex-1);
    else
        set(handles.workspaceVarBox,'Value',1);
    end
    refreshVarListButton_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
function saveWorkspaceBtn_Callback(hObject, eventdata, handles)
    set(handles.feedbackString,'String','saving...')
    pause(0.0000000001);
    guidata(hObject, handles);
    try
        savePath=evalin('base','metaData.importPath');
    catch
        savePath=[pwd filesep];
    end
    try 
        try
            tStr=evalin('base','metaData.tifFile');
        catch
            tStr=evalin('base','metaData.hdfFile');
        end
        tSplt=strsplit(tStr,'.');
        aStr=tSplt{1};
    catch
        aStr='1';
    end
   
    evalin('base',['save(' '''' savePath 'mat_' aStr ''',''-v7.3'')'])
    pause(0.0000000001);
    set(handles.feedbackString,'String','')
    guidata(hObject, handles);


% ----------------------- junkyard
%
function firstImageEntry_Callback(hObject, eventdata, handles)
function firstImageEntry_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function endImageEntry_Callback(hObject, eventdata, handles)
function endImageEntry_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function fileFilterString_Callback(hObject, eventdata, handles)
function fileFilterString_CreateFcn(hObject, eventdata, handles)
    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function stringFilterToggle_Callback(hObject, eventdata, handles)
function skipFactorEntry_Callback(hObject, eventdata, handles)
function skipFactorEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function workspaceVarBox_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function appendProjTextEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function stackObjectNameEntry_CreateFcn(hObject, eventdata, handles)
    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function stackSplit_textAppend_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function splitStackCountEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function importWorkerEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function constrainedMeanEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function outlierThresholdEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function registrationWorkerEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in binPixels.
function binPixels_Callback(hObject, eventdata, handles)
    set(handles.binPixels,'Enable','off');
    try
        binPix=str2num(get(handles.binPixelsEntry,'String'));

        selections = get(handles.workspaceVarBox,'String');
            selectionsIndex = get(handles.workspaceVarBox,'Value');
        s=evalin('base',['size(' selections{selectionsIndex} ');']);
        if numel(s)>=2

            set(handles.feedbackString,'String',['Binning Stack ...'])
            pause(0.00000000000000001);
            guidata(hObject, handles);
            evalin('base',[selections{selectionsIndex} '=uint16(binImages(' selections{selectionsIndex} ',' num2str(binPix) '));'])
            set(handles.feedbackString,'String',['finished stack binning ...'])
            pause(0.00000000000000001)
            guidata(hObject, handles);

        else
        end

        clear s testBin
    catch
        set(handles.binPixels,'Enable','on');
    end
    set(handles.binPixels,'Enable','on');
    refreshVarListButton_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
function binPixelsEntry_Callback(hObject, eventdata, handles)
function binPixelsEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function averageStackBy_Callback(hObject, eventdata, handles)

    muBy=str2num(get(handles.averageStackByEntry,'String'));
    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    ogSize=evalin('base',['size(' selections{selectionsIndex} ');']);
    if numel(ogSize)==3
        newSize=fix(ogSize(3)/muBy)
        clipSize=newSize*muBy;
        sendFeedback(hObject,eventdata,handles,'working on averaging ...')
        evalin('base',[selections{selectionsIndex} '=' selections{selectionsIndex} '(:,:,1:' num2str(clipSize) ');']);
        evalin('base',[selections{selectionsIndex} '=uint16(squeeze(mean(reshape(' selections{selectionsIndex} ',size(' selections{selectionsIndex} ',1),size(' selections{selectionsIndex} ',2),' num2str(muBy) ',size(' selections{selectionsIndex} ',3)/' num2str(muBy) '),3)));']);
        sendFeedback(hObject,eventdata,handles,'done averaging')
    else
        sendFeedback(hObject,eventdata,handles,'something wrong with stack dimensions')
    end

    refreshVarListButton_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
function averageStackByEntry_Callback(hObject, eventdata, handles)

    averageStackBy_Callback(hObject, eventdata, handles)

function averageStackByEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function importFromHDF_Callback(hObject, eventdata, handles)

    set(handles.multiPageFlag, 'Value',0);
function memoryMapToggle_Callback(hObject, eventdata, handles)

    if get(handles.memoryMapToggle, 'Value')==1
        set(handles.multiPageFlag, 'Value',0);
        set(handles.importFromHDF, 'Value',1);
    else
    end
function hdfPopSelector_Callback(hObject, eventdata, handles)

    try
        selectVal=get(handles.hdfPopSelector,'Value');
        tDS=get(handles.hdfPopSelector,'String');
        tDS_select=tDS{selectVal};
        tP=evalin('base','metaData.importPath');
        tH=evalin('base','metaData.hdfFile');

        tSInfo=h5info([tP tH],['/' tDS_select]);
        dsSize=tSInfo.Dataspace.Size;

        zOne=get(handles.zDimFlip,'Value');
            if numel(dsSize)==3
                if zOne
                    imDim=dsSize(1);
                else
                    imDim=dsSize(3);
                end
            elseif numel(dsSize)~=3
                [~,imDim]=dsSize(max(dsSize));
            end
            
            set(handles.firstImageEntry,'String',num2str(1));
            set(handles.endImageEntry,'String',num2str(imDim));
    catch
        a=1;
    end
function hdfPopSelector_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% ****** Generic Startup Functions
function importer_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    vars = evalin('base','who');
    set(handles.workspaceVarBox,'String',vars)
    
    try
        totalImages=evalin('base','numel(metaData.filteredFiles);');
        set(handles.endImageEntry,'String',num2str(totalImages));
    catch
    end
    
    try
        totalImages=evalin('base','size(metaData.hdfSize);');
        set(handles.endImageEntry,'String',num2str(totalImages(3)));
    catch
    end
    

    if strcmp(computer,'MACI64') || strcmp(computer,'GLNXA64')
        macHeaderSize=12;
        macFontSize=11;
        macUIDecSize=10;

    elseif strcmp(computer,'PCWIN64') 
        macHeaderSize=8;
        macFontSize=7;
        macUIDecSize=6;
    else
    end


    uiElements={'zDimFlip','importButton','hdfPopSelector','memoryMapToggle',...
        'importFromHDF','averageStackByEntry','averageStackBy',...
        'binPixelsEntry','binPixels','registrationWorkerEntry',...
        'outlierThresholdEntry','constrainedMeanEntry',...
        'importWorkerEntry','splitStackCountEntry','stackSplit_textAppend',...
        'stackObjectNameEntry','appendProjTextEntry','workspaceVarBox',...
        'skipFactorEntry','stringFilterToggle','stringFilterToggle',...
        'fileFilterString','endImageEntry','firstImageEntry',...
        'saveWorkspaceBtn','deleteSelectionBtn','plotVectorButton',...
        'extractorButton','roiMakerButton','diskLumValButton',...
        'tossOutlierButton','outlierThresholdEntry','contrainedMeanProjectButton',...
        'constrainedMeanEntry','getLuminanceButton','inferRunningButton',...
        'registrationWorkerEntry','parallelizeRegistrationToggle','importWorkerEntry',...
        'parallelizeImportToggle','inspectStackButton','inspectImageButton',...
        'applyTransformsButton','deleteOGStack_toggle','splitStackButton',...
        'splitStackCountEntry','stackSplit_serialToggle','stackSplit_everyOtherToggle',...
        'stackSplit_textAppend','multiPageFlag','filterDiskProjectToggle',...
        'selectDiskMeanProjectButton','saveRegTiffsToggle','diskRegisterButton',...
        'compressStackToggle','diskMeanProjectButton','stackObjectNameEntry',...
        'saveDirectoryButton','saveStackButton','refreshVarListButton',...
        'registerButton','setRegStackButton','templateButton','meanProjectButton',...
        'workspaceVarBox','setDirectoryButton','importButton','stackResizeButton',...
        'resizeStackXEntry','resizeStackYEntry','resizeStackZEntry','renameStringEntry',...
        'saveEntryText','exportHDF','exportMPTiff'};
    
    for n=1:numel(uiElements)
        eval(['handles.' uiElements{n} '.FontSize=macFontSize;'])
    end
        
    decUIElements={'imageContainString','pickFrameString','startNumTxt',...
        'startToText','endFText','text5','text11','text13','text12','imageAxis',...
        'text35','text36','text37'};
    for n=1:numel(decUIElements)
        eval(['handles.' decUIElements{n} '.FontSize=macUIDecSize;'])
    end
    
    titleUIElements={'uipanel9','importPanel','uipanel7','uipanel8','uipanel10','uipanel3'};
    for n=1:numel(titleUIElements)
        eval(['handles.' titleUIElements{n} '.FontSize=macHeaderSize;'])
    end
    guidata(hObject, handles);
function varargout = importer_OutputFcn(hObject, eventdata, handles) 
    
    varargout{1} = handles.output;
function resizeStackXEntry_Callback(hObject, eventdata, handles)
function resizeStackXEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function resizeStackYEntry_Callback(hObject, eventdata, handles)
function resizeStackYEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function resizeStackZEntry_Callback(hObject, eventdata, handles)
function resizeStackZEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function stackResizeButton_Callback(hObject, eventdata, handles)

    zDim=get(handles.resizeStackZEntry,'String');
    yDim=get(handles.resizeStackYEntry,'String');
    xDim=get(handles.resizeStackXEntry,'String');


    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    selectStack=selections{selectionsIndex};

    evalin('base',[selectStack '=' selectStack '(' yDim ',' xDim ',' zDim ');']);
function zDimFlip_Callback(hObject, eventdata, handles)
function renameStringEntry_Callback(hObject, eventdata, handles)
function renameStringEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function exportHDF_Callback(hObject, eventdata, handles)
    mPF=evalin('base','metaData.importType;');
    fPath=evalin('base','metaData.importPath;');
    tsPath=strsplit(fPath,filesep);
    sPath=tsPath{1};
    for n=2:numel(tsPath)-1
        sPath=[sPath filesep tsPath{n}];
    end
    sPath=[sPath filesep];
    assignin('base','sPath',sPath);

    if strcmp(fPath(end),filesep)==0
        fPath=[fPath filesep];
    else
    end 
    
    if mPF==0
        filteredFiles=evalin('base','metaData.filteredFiles;');
        dTypeStr=evalin('base','metaData.bitDepth;');
        yDim=evalin('base','metaData.imSize(1);');
        xDim=evalin('base','metaData.imSize(2);');
    else
    end

    if mPF==1
        tifFile=evalin('base','metaData.tifFile;');
        bDepth=evalin('base','metaData.mpTifInfo(1).BitDepth;');
        if bDepth==8
            dTypeStr='uint8';
        elseif bDepth==32
            dTypeStr='uint32';
        else
            dTypeStr='uint16';
        end
        yDim=evalin('base','metaData.mpTifInfo(1).Height;');
        xDim=evalin('base','metaData.mpTifInfo(1).Width;');
    else
    end

    % create hdf set

        
    imF=str2num(get(handles.firstImageEntry,'String'));
    imS=str2num(get(handles.skipFactorEntry,'String'));
    imL=str2num(get(handles.endImageEntry,'String'));

    imRange=imF:imS:imL;
    imageCount=numel(imRange);

    
    
    
    hdfSaveInfo=get(handles.saveEntryText,'string');
    tStr=strsplit(hdfSaveInfo,',');


    hdfDSet=['/' tStr{2}];
    hdfName=[sPath tStr{1} '.hdf'];


    disp(hdfName)
    disp(tStr)
    h5create(hdfName,hdfDSet,[yDim xDim imageCount],'Datatype',dTypeStr,'ChunkSize',[yDim xDim 1]);
    set(handles.feedbackString,'String',['exporting to hdf ...'])
    pause(0.00000000000000001)
    guidata(hObject, handles);
    tic     
    for g=1:imageCount
        if mod(g,250)==0
            set(handles.exportHDF,'String',[num2str(g) '/' num2str(imageCount)])
            pause(0.00000000000000001)
            guidata(hObject, handles);
        else
        end
        if mPF==1
            tempImported=imread([fPath tifFile],'Index',imRange(g));
        else
            tempImported=imread([filteredFiles(imRange(g)).folder filesep filteredFiles(imRange(g)).name]);
        end
        h5write(hdfName,hdfDSet,tempImported,[1 1 g],[yDim xDim 1]);
    end
    hdfExpTime=toc;
    disp(['it took ' num2str(hdfExpTime) ' seconds to export'])

        
    clear tIm
    set(handles.exportHDF,'String','To HDF')
    set(handles.feedbackString,'String',['Exported ' num2str(numel(imRange)) ' Images'])
    pause(0.00000000000000001)
    guidata(hObject, handles);
function saveEntryText_Callback(hObject, eventdata, handles)
function saveEntryText_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function renameSelectionEntry_Callback(hObject, eventdata, handles)
function renameSelectionEntry_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function renameSelection_Callback(hObject, eventdata, handles)
    renameString=get(handles.renameSelectionEntry,'String');
    selections = get(handles.workspaceVarBox,'String');
    selectionsIndex = get(handles.workspaceVarBox,'Value');
    selectedItem=selections{selectionsIndex};
    evalin('base',[renameString '=' selectedItem ';, clear ' selectedItem]);

    refreshVarListButton_Callback(hObject, eventdata, handles)
    selections = get(handles.workspaceVarBox,'String');
    for n=1:numel(selections)
        if strcmp(renameString,selections{n})==1
            shiftSelection=n;
            break
        else
            shiftSelection=1;
        end
    end
        set(handles.workspaceVarBox,'Value',shiftSelection);
    
    guidata(hObject, handles);


function exportMPTiff_Callback(hObject, eventdata, handles)

    mPF=evalin('base','metaData.importType;');
    fPath=evalin('base','metaData.importPath;');
    tsPath=strsplit(fPath,filesep);
    sPath=tsPath{1};
    for n=2:numel(tsPath)-1
        sPath=[sPath filesep tsPath{n}];
    end
    sPath=[sPath filesep];
    assignin('base','sPath',sPath);

    if strcmp(fPath(end),filesep)==0
        fPath=[fPath filesep];
    else
    end 
    
    if mPF==0
        filteredFiles=evalin('base','metaData.filteredFiles;');
        dTypeStr=evalin('base','metaData.bitDepth;');
        yDim=evalin('base','metaData.imSize(1);');
        xDim=evalin('base','metaData.imSize(2);');
    else
    end

    if mPF==1
        tifFile=evalin('base','metaData.tifFile;');
        bDepth=evalin('base','metaData.mpTifInfo(1).BitDepth;');
        if bDepth==8
            dTypeStr='uint8';
        elseif bDepth==32
            dTypeStr='uint32';
        else
            dTypeStr='uint16';
        end
        yDim=evalin('base','metaData.mpTifInfo(1).Height;');
        xDim=evalin('base','metaData.mpTifInfo(1).Width;');
    else
    end

    % create mp tiff

        
    imF=str2num(get(handles.firstImageEntry,'String'));
    imS=str2num(get(handles.skipFactorEntry,'String'));
    imL=str2num(get(handles.endImageEntry,'String'));

    imRange=imF:imS:imL;
    imageCount=numel(imRange);

    
    
    
    hdfSaveInfo=get(handles.saveEntryText,'string');
    tStr=strsplit(hdfSaveInfo,',');


    hdfName=[sPath tStr{1} '_' tStr{2} '.tif'];


    disp(hdfName)
    disp(tStr)
    
    

    
    set(handles.feedbackString,'String',['exporting to mp tiff ...'])
    pause(0.00000000000000001)
    guidata(hObject, handles);
    tic

    for g=1:imageCount
        if mod(g,250)==0
            set(handles.exportMPTiff,'String',[num2str(g) '/' num2str(imageCount)])
            pause(0.00000000000000001)
            guidata(hObject, handles);
        else
        end
        if mPF==1
            tempImported=imread([fPath tifFile],'Index',imRange(g));
        else
            tempImported=imread([filteredFiles(imRange(g)).folder filesep filteredFiles(imRange(g)).name]);
        end
        if g==1
            imwrite(tempImported,hdfName);
        else
            imwrite(tempImported,hdfName,'WriteMode','append');
        end
    end
    hdfExpTime=toc;
    disp(['it took ' num2str(hdfExpTime) ' seconds to export'])

        
    clear tIm
    set(handles.exportMPTiff,'String','To MP Tif')
    set(handles.feedbackString,'String',['Exported ' num2str(numel(imRange)) ' Images'])
    pause(0.00000000000000001)
    guidata(hObject, handles);
