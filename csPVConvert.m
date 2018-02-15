% csPVConvert (v0.2)
% Converts Bruker multiphoton scanning microscope raw data and stores data
% in an hdf5 container.
%
% Current version: camera frames only.
% 
% Note: Image datasets are of dimension: [frameNum xDim yDim]
% Leading with frameNum ensures maximal compatibility with existing 
% python hdf5 routines.
%
% questions/bugs/suggestions --> cdeister@brown.edu
% anything licenseable is covered under an MIT license contained in the Git
% repository. 

%% get path
clear convertablePaths subDirectories
try
     fPath=uigetdir;
catch
end

dirPath=dir(fPath);
subDirectories={dirPath(find([dirPath.isdir]==1)).name};
goodDirs=0;
for h=1:numel(subDirectories)
    if strcmp(subDirectories{h}(1),'.')==0
        goodDirs=goodDirs+1;
        nonDorDirs(goodDirs)=h;
    else
    end
end
subDirectories=subDirectories(nonDorDirs);

goodDirs=0;
for h=1:numel(subDirectories)
    tDir=dir([fPath filesep subDirectories{h} filesep 'CYCLE*RAWDATA*']);
    if numel(tDir)>0
        goodDirs=goodDirs+1;
        convertablePaths{goodDirs}=subDirectories{h};
    else
        convertablePaths={};
    end
end
clear h goodDirs nonDorDirs subDirectories dirPath tDir

% Convert
tName=strsplit(fPath,filesep);
tName=tName{end};
hdfName=[fPath filesep 'images_' tName '.hdf'];
clear tName

if numel(convertablePaths)>0
    for h=1:numel(convertablePaths)
        workingPath=[fPath filesep convertablePaths{h}];
    
        % a) parse xml
        tic
        disp('parsing xml ... this can be slow with MATLAB')
        % note: xml parsing in MATLAB is SLOW compared to other languages.
        % this step is currently one of the slowest in the script.
        xmlDir=dir([fPath filesep convertablePaths{h} filesep '*xml']);
        xmlName=xmlDir.name;
        clear xmlDir
        xmlFile=xml2struct([fPath filesep convertablePaths{h} filesep xmlName]);
        disp(['... xml parsed in ' num2str(toc) ' seconds'])

        % assign metadata
        md.scanType=xmlFile.PVScan.PVStateShard.PVStateValue{1,1}.Attributes.value;
        md.scanTimestamp=xmlFile.PVScan.Attributes.date;
        md.bitDepth=str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,2}.Attributes.value);
        if strcmp(md.scanType,'Camera')
            md.dwelltime=str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,5}.Attributes.value);
            md.frameDelta=str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,10}.Attributes.value);
        else
            md.dwelltime=str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,9}.Attributes.value);
            md.frameDelta=0;
        end
        md.pockelsValue=str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,16}.IndexedValue.Attributes.value);
        md.dimLines=str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,17}.Attributes.value);
        md.dimPixels=str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,25}.Attributes.value);
        md.pixelSizeXYZ=[str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,19}.IndexedValue{1,1}.Attributes.value),...
            str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,19}.IndexedValue{1,2}.Attributes.value),...
            str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,19}.IndexedValue{1,3}.Attributes.value)];

        xDim=md.dimPixels;
        yDim=md.dimLines;
        totalPixelsPerFrame=xDim*yDim;

        rawDir=dir([workingPath filesep 'CYCLE*RAWDATA*']);
        rawNames={rawDir.name};

        frmWrt=0;

        lastExtra=[];
        lastExtraSize=0;
        flipDim=1;

        % create hdf set
        hdfDSet=[filesep convertablePaths{h}];
        h5create(hdfName,hdfDSet,[yDim xDim Inf],'Datatype','uint16','ChunkSize',[yDim xDim 1]);

        h5writeatt(hdfName,hdfDSet,'scanType',md.scanType);
        h5writeatt(hdfName,hdfDSet,'scanTimestamp',md.scanTimestamp);
        h5writeatt(hdfName,hdfDSet,'bitDepth',md.bitDepth);
        h5writeatt(hdfName,hdfDSet,'dwelltime',md.dwelltime);
        h5writeatt(hdfName,hdfDSet,'frameRate',md.frameDelta);
        h5writeatt(hdfName,hdfDSet,'pockelsValue',md.pockelsValue);
        h5writeatt(hdfName,hdfDSet,'scanLines',md.dimLines);
        h5writeatt(hdfName,hdfDSet,'scanPixels',md.dimPixels);
        h5writeatt(hdfName,hdfDSet,'pixelSizeXYZ',md.pixelSizeXYZ);

         % ------------ Camera Conversion block
        if strcmp(md.scanType,'Camera')
            for n=1:numel(rawNames)    
                fName=rawNames{n};
                m = memmapfile([workingPath filesep fName],'Format','uint16');
                chunkSize=numel(m.Data)+lastExtraSize;
                totalFramesInRawChunk=fix(chunkSize/totalPixelsPerFrame);
                curExtraSize=(chunkSize)-(totalFramesInRawChunk*xDim*yDim);
                curExtra=m.Data(end-curExtraSize+1:end);

                for k=1:totalFramesInRawChunk
                    if k==1
                        gg=vertcat(lastExtra,m.Data(1:totalPixelsPerFrame-lastExtraSize));
                    elseif k>1   
                        gg=m.Data(((totalPixelsPerFrame*(k-1))-lastExtraSize+1):(totalPixelsPerFrame*(k-1)-lastExtraSize)+totalPixelsPerFrame);
                    end
                    if flipDim==1
                        tFrame=rot90(reshape(gg,xDim,yDim)',2);
                    elseif flipDim==0
                        tFrame=reshape(gg(1:(totalPixelsPerFrame)),xDim,yDim)';
                    end
                    frmWrt=frmWrt+1;
                    h5write(hdfName,hdfDSet,tFrame,[1 1 frmWrt],[yDim xDim 1]);
                    if mod(k,5000)==0
                        disp(['finished ' num2str(k) '/' num2str(totalFramesInRawChunk) ' in chunk ' num2str(n) '/' num2str(numel(rawNames))])
                    else
                    end
                    clear gg tFrame
                end
                disp(['done with chunk '  num2str(n) '/' num2str(numel(rawNames))])
                lastExtra=curExtra;
                lastExtraSize=curExtraSize;
                clear m
            end
            disp(['******* done with dataset: wrote ' num2str(frmWrt) ' frames to your hdf'])
        else
        end
    end
else
    disp('no paths with CYCLE*RAW* files exist in any part of your path')
end

% 
% %% import a previously converted tif
% frTLk=44048;
% figure,imagesc(h5read('myfile5.h5', '/ccdMap-02142018-001',[1 1 frTLk],[yDim xDim 1]))
% cTif=imread('/Users/cad/Desktop/curanimals/14Feb2018/ccdMap-02142018-001converted/ccdMap-02142018-001_Cycle00001_Ch3_044048.ome.tif');
% figure,imagesc(h5read('myfile5.h5', '/ccdMap-02142018-001',[1 1 frTLk],[yDim xDim 1])-cTif)