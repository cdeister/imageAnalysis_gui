% csPVConvert (v0.55)
% Converts Bruker multiphoton scanning microscope raw data and stores data
% in an hdf5 container.
%
% NOTE: modified on 2-15-2019 for new scope. XMLs are too rig dependent.
% Need to abstract these things. For instance PMT Gain has two entries vs.
% 4 etc. 
%
% Note: Image datasets are of dimension: [frameNum xDim yDim]
% Leading with frameNum ensures maximal compatibility with existing 
% python hdf5 routines.
%
% questions/bugs/suggestions --> cdeister@brown.edu
% anything licenseable is covered under an MIT license contained in the Git
% repository. 

% odd lines

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
try
subDirectories=subDirectories(nonDorDirs);
catch
    subDirectories=[];
end

goodDirs=0;
convertablePaths={};
for h=1:numel(subDirectories)
    tDir=dir([fPath filesep subDirectories{h} filesep 'CYCLE*']);
    if numel(tDir)>0 && strcmp(subDirectories{h}(1:4),'Sing')==0
        goodDirs=goodDirs+1;
        convertablePaths{goodDirs}=subDirectories{h};
    else
    end
end
clear h goodDirs nonDorDirs subDirectories dirPath tDir
%%
% Convert
tName=strsplit(fPath,filesep);
tName=tName{end};
hdfName=[fPath filesep 'images_' tName '.hdf'];
clear tName

%%
if numel(convertablePaths)>0
    for h=1:numel(convertablePaths)
        workingPath=[fPath filesep convertablePaths{h}];
    
        % a) parse xml
        tic
        disp('parsing xml ... this can be slow with MATLAB; up to 2 min for a massive XML')
        % note: xml parsing in MATLAB is SLOW compared to other languages.
        % this step is currently one of the slowest in the script.
        xmlDir=dir([fPath filesep convertablePaths{h} filesep '*xml']);
        xmlName=xmlDir.name;
        clear xmlDir
        xmlFile=xml2struct([fPath filesep convertablePaths{h} filesep xmlName]);
        disp(['... xml parsed in ' num2str(toc) ' seconds'])
        
        % get frame count and times.
        try
            md.volScan=str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,35}.Attributes.value);
        catch
            md.volScan=0;
        end
            
        md.scanType=xmlFile.PVScan.PVStateShard.PVStateValue{1,1}.Attributes.value;
        md.volumeCount=numel(xmlFile.PVScan.Sequence);

        if md.volScan==0 || md.volumeCount==1
            md.frameCount=numel(xmlFile.PVScan.Sequence.Frame);
            md.absTime=zeros(md.frameCount,1);
            for q=1:md.frameCount
                md.absTime(q)=str2double(xmlFile.PVScan.Sequence.Frame{q}.Attributes.absoluteTime);
            end
            
        % ******* This is the stuff you want Fred.
        elseif md.volScan==1 && md.volumeCount>1
            md.volumeCount=numel(xmlFile.PVScan.Sequence);
            md.framePerVolumeCount=numel(xmlFile.PVScan.Sequence{1, 1}.Frame);
            md.frameCount = md.volumeCount * md.framePerVolumeCount;
            md.absTime=zeros(md.frameCount,1);
            tFrames  = 1;
            for q=1:md.volumeCount
                for g = 1: md.framePerVolumeCount
                    md.absTime(tFrames)=str2double(xmlFile.PVScan.Sequence{1,q}.Frame{1,g}.Attributes.absoluteTime);
                    tFrames = tFrames+1;
                end
            end
        end
            

        % assign metadata
        
        md.scanTimestamp=xmlFile.PVScan.Attributes.date;
        md.bitDepth=str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,2}.Attributes.value);
        
        if strcmp(md.scanType,'Camera')
            md.dwelltime=str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,5}.Attributes.value);
            md.frameDelta=str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,10}.Attributes.value);
            md.dimPixels=str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,25}.Attributes.value);
            md.dimLines=str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,17}.Attributes.value);
%             md.pixelSizeXYZ=[str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,19}.IndexedValue{1,1}.Attributes.value),...
%             str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,19}.IndexedValue{1,2}.Attributes.value);
%             str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,19}.IndexedValue{1,3}.Attributes.value);
            md.pmtGain=[0,0];
            md.numChans=1;
            md.resMultiSamp=0;
        else
            md.dwelltime=str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,5}.Attributes.value);
            md.frameDelta=0;
            md.dimPixels=str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,17}.Attributes.value);
            md.dimLines=str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,9}.Attributes.value);
%             md.pixelSizeXYZ=[str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,15}.IndexedValue{1,1}.Attributes.value),...
%             str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,15}.IndexedValue{1,2}.Attributes.value),...
%             str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,15}.IndexedValue{1,3}.Attributes.value)];
            md.pmtGain=[str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,18}.IndexedValue{1,1}.Attributes.value),...
            str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,18}.IndexedValue{1,2}.Attributes.value)];
            md.numChans=numel(find(md.pmtGain>0));
            md.resMultiSamp=0;
        end
        
        if strcmp(md.scanType,'ResonantGalvo')
            md.resMultiSamp=str2double(xmlFile.PVScan.PVStateShard.PVStateValue{1,23}.Attributes.value);
        else
        end
            

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
        hdfDSet=['/' convertablePaths{h}];
        hdfDSetTime=['/' convertablePaths{h} '_absTime'];
        effectiveFrameCount = md.numChans * md.frameCount;
        h5create(hdfName,hdfDSet,[yDim xDim effectiveFrameCount],'Datatype','uint16','ChunkSize',[yDim xDim 1]);
        h5create(hdfName,hdfDSetTime,[effectiveFrameCount 1],'Datatype','double');
        h5write(hdfName,hdfDSetTime,md.absTime,[1 1],[md.frameCount 1]);

        h5writeatt(hdfName,hdfDSet,'scanType',md.scanType);
        h5writeatt(hdfName,hdfDSet,'scanTimestamp',md.scanTimestamp);
        h5writeatt(hdfName,hdfDSet,'bitDepth',md.bitDepth);
        h5writeatt(hdfName,hdfDSet,'dwelltime',md.dwelltime);
        h5writeatt(hdfName,hdfDSet,'frameRate',md.frameDelta);
        h5writeatt(hdfName,hdfDSet,'scanLines',md.dimLines);
        h5writeatt(hdfName,hdfDSet,'scanPixels',md.dimPixels);
%         h5writeatt(hdfName,hdfDSet,'pixelSizeXYZ',md.pixelSizeXYZ);
        h5writeatt(hdfName,hdfDSet,'frameCount',md.frameCount);
        h5writeatt(hdfName,hdfDSet,'pmtGains',md.pmtGain);
        h5writeatt(hdfName,hdfDSet,'numChans',md.numChans);
        h5writeatt(hdfName,hdfDSet,'resMultiSamp',md.resMultiSamp);
        h5writeatt(hdfName,hdfDSet,'volScan',md.volScan);

%%
         % ------------ Camera Conversion block
        if strcmp(md.scanType,'Camera')
            for n=1:numel(rawNames)    
                fName=rawNames{n};
                m = memmapfile([workingPath filesep fName],'Format','uint16');
                chunkSize=numel(m.Data)+lastExtraSize;
                totalFramesInRawChunk=fix(chunkSize/(totalPixelsPerFrame*md.numChans));
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
        
        elseif strcmp(md.scanType,'Galvo')
            for n=1:numel(rawNames)
                mSamp=fix(md.dwelltime/0.4);    
                fName=rawNames{n};
                m = memmapfile([workingPath filesep fName],'Format','uint16');

                chunkSize=numel(m.Data)+lastExtraSize;
                testPix=totalPixelsPerFrame*md.numChans*mSamp;
                totalFramesInRawChunk=fix(chunkSize/testPix);
                curExtraSize=(chunkSize)-(totalFramesInRawChunk*testPix);
                curExtra=m.Data(end-curExtraSize+1:end);
                tIM=uint16(zeros(yDim,xDim,md.numChans));
                for k=1:totalFramesInRawChunk
                    if k==1
                        gg=vertcat(lastExtra,m.Data(1:testPix-lastExtraSize));
                    elseif k>1   
                        gg=m.Data(((testPix*(k-1))-lastExtraSize+1):(testPix*(k-1)-lastExtraSize)+testPix);
                    end
                    
                    for l=1:md.numChans*mSamp
                        tF(:,l)=gg(l:md.numChans*mSamp:end);
                    end
                    for x=1:md.numChans
                        tIM(:,:,x)=reshape(mean(tF(:,x:mSamp:end),2),xDim,yDim)';
                        frmWrt=frmWrt+1;
                        h5write(hdfName,hdfDSet,tIM(:,:,x),[1 1 frmWrt],[yDim xDim 1]);
                    end                        
                    if mod(k,5000)==0
                        disp(['finished ' num2str(k) '/' num2str(totalFramesInRawChunk) ' in chunk ' num2str(n) '/' num2str(numel(rawNames))])
                    else
                    end
                    clear gg tFrame
                end
                disp(['done with chunk '  num2str(n) '/' num2str(numel(rawNames))])
                lastExtra=curExtra;
                lastExtraSize=curExtraSize;
                clear m tF
            end
            disp(['******* done with dataset: wrote ' num2str(frmWrt) ' frames to your hdf'])
        
        elseif strcmp(md.scanType,'ResonantGalvo')
            clear tF
            frmWrt=0;
            lastExtra=[];
            lastExtraSize=0;
            mSamp=md.resMultiSamp;
            totalPixelsPerFrame=(xDim*mSamp)*yDim;
            testPix=totalPixelsPerFrame*md.numChans;
            
            % prealloc image array (z is num channels)
            tIM=uint16(zeros(yDim,xDim,md.numChans));
            tF=uint16(zeros(totalPixelsPerFrame,md.numChans));
            tp3=uint16(zeros(yDim,xDim*mSamp));
            
            for n=1:numel(rawNames)
                fName=rawNames{n};
                m = memmapfile([workingPath filesep fName],'Format','uint16');
                chunkSize=numel(m.Data)+lastExtraSize;
                totalFramesInRawChunk=fix(chunkSize/testPix);
                curExtraSize=(chunkSize)-(totalFramesInRawChunk*testPix);
                curExtra=m.Data(end-curExtraSize+1:end);
                for k=1:totalFramesInRawChunk
                    % append new chunk's pixels to the last chunks
                    % remainder.
                    if k==1
                        gg=vertcat(lastExtra,m.Data(1:testPix-lastExtraSize));
                    elseif k>1   
                        gg=m.Data(((testPix*(k-1))-lastExtraSize+1):(testPix*(k-1)-lastExtraSize)+testPix);
                    end
                    
                    % would reshape be faster here?
                     for l=1:md.numChans
                         tF(:,l)=gg(l:md.numChans:end);
                     end
                    for x=1:md.numChans
                        rOffset=min(tF(:,x))-abs(8192-min(tF(:,x)));
                        tty=tF(:,x);  %:mSamp:end);
                        taa=reshape(tty,xDim*2*mSamp,yDim/2)';
                        taa(:,1:xDim*mSamp)=fliplr(taa(:,1:xDim*mSamp));
                        tp1=taa(:,1:xDim*3);
                        tp2=taa(:,(xDim*3)+1:end);
                        tp3(1:2:yDim,1:xDim*3)=tp1;
                        tp3(2:2:yDim,1:xDim*3)=tp2;  
                        tp3=uint16(squeeze(mean(reshape(tp3,yDim,mSamp,xDim),2)));                     
                        frmWrt=frmWrt+1;
                        if frmWrt<=effectiveFrameCount
                            h5write(hdfName,hdfDSet,tp3,[1 1 frmWrt],[yDim xDim 1]);
                        else
                            extraFrames(:,:,frmWrt-effectiveFrameCount)=tp3;
                        end
         
                    end                        
                    if mod(k,5000)==0
                        disp(['finished ' num2str(k) '/' num2str(totalFramesInRawChunk) ' in chunk ' num2str(n) '/' num2str(numel(rawNames))])
                    else
                    end
                    clear gg tF
                end
                disp(['done with chunk '  num2str(n) '/' num2str(numel(rawNames))])
                lastExtra=curExtra;
                lastExtraSize=curExtraSize;
                clear m tF

            end
            disp(['******* done with dataset: wrote ' num2str(frmWrt) ' frames to your hdf'])
            
        else
        end
    end
else
    disp('no paths with CYCLE*RAW* files exist in any part of your path')
end