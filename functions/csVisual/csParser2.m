function [parsedStruct,csBData,csBehavHDFInfo]=csParser2(csBehaviorHDFPath)

% csParser2, a function that parses behavior data from csDiscrim/csVisual
% arguments: "csBehaviorHDFPath" is a path to the hdf file you want to
% parse. "versionNum" is an optional argument that isn't implemented yet.
% You can also pass 0 arguments and a dialog to select an hdf will pop up.
% returns: "parsedStruct" is a struct of parsed behavior data and what the 
% function is intended to produce."csBData" is the raw dataset in the hdf
% only. "csBehavHDFInfo" is the hdf5 library info.
%
% v0.9 -- Chris Deister - cdeister@brown.edu

%% 


[tHDF,tPth]=uigetfile('*.hdf','what what?');
csBehaviorHDFPath=[tPth tHDF];

csBehavHDFInfo=h5info(csBehaviorHDFPath);
curDatasetPath=['/' csBehavHDFInfo.Datasets.Name];
csSessionData=h5read(csBehaviorHDFPath,curDatasetPath);
csTrialData=csBehavHDFInfo.Datasets.Attributes;

% performance
perf.droppedSamples = numel(find(csSessionData(1,:)==0))-1;
perf.peakLoop = double(max(csSessionData(9,:)));
disp(["dropped samples: " num2str(perf.droppedSamples)])


%%

% map of data labels and numerical indicies (for the data in the dataset only).
chStrMap={'interrupt','sessionTime','stateTime','teensyStates','loadCell','lickSensor',...
    'encoder','frame','interruptTime','analogInput0','analogInput1',...
    'analogInput2','analogInput3','pythonStates','thresholdedLicks'};

chIndMap=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15];
% simple anonymous function to easily index the channels by name. This allows flexibility.
% use: chFind('interruptsco') will return 1.
chFind=@(b) chIndMap(find(strcmp(chStrMap,b)==1));


% A) Parse the dataset.
for n=1:numel(chStrMap)
    try
        disp(['parsedStruct.' chStrMap{n} '=double(csSessionData(chFind(''' chStrMap{n} '''),:));'])
        eval(['parsedStruct.' chStrMap{n} '=double(csSessionData(chFind(''' chStrMap{n} '''),:));'])
    catch
        a=1;
    end
end

% scale things (teensy ADC is 12-bit/3.3V)
parsedStruct.sessionTime=parsedStruct.sessionTime/1000;
parsedStruct.stateTime=parsedStruct.stateTime/1000;
parsedStruct.analogInput0=(parsedStruct.analogInput0/4095)*3.3;
parsedStruct.analogInput1=(parsedStruct.analogInput1/4095)*3.3;
parsedStruct.analogInput2=(parsedStruct.analogInput2/4095)*3.3;
parsedStruct.analogInput3=(parsedStruct.analogInput3/4095)*3.3;
parsedStruct.encoder=(parsedStruct.encoder/4095)*3.3;

% we don't use the encoder voltage, but convert it into motion variables
parsedStruct.position=decodeShaftEncoder(parsedStruct.encoder,3);
parsedStruct.velocity=nPointDeriv(parsedStruct.position,parsedStruct.sessionTime,1000);
% there can be divide by zeros
parsedStruct.velocity(find(isnan(parsedStruct.velocity)==1))=0;
parsedStruct.binaryVelocity=binarizeResponse(parsedStruct.velocity,0.005);
parsedStruct.motionBoutStarts=find(diff(parsedStruct.binaryVelocity)>0.8);

% B) Define a trial by the onset of the stimulus state (usually state2). 
% Store the stim-onset samples, make a binary vector and count trials.
% State is logged on teensy and in python, and can differ during transitions. However, the teensyState
% is the actual state.




% C) Resolve 'attribute' data.
% Data that do not change within a 'trial' are stored as attributes for the
% parent dataset, which is the ms-ms data that comprise all trials.
% For the most part, these attribute data are stimulus parameters. Here we
% parse the attribute data. Some stimulus parameters are generated for all 
% trials at run-time. This prevents having to recalculate things that are pre-determined. 
% For these I pad the arrays by a large amount, just in case the user wants to
% increase the number of trials. Thus, we will usually end up with more of
% these than trials we ran. So, we need to trim these to the length of the trials ran.
% This stuff is most likley to change with format changes.

for n=1:numel(csTrialData)
    tName = csTrialData(n).Name;
    try
        tData = double(csTrialData(n).Value);
    catch
        tData = csTrialData(n).Value;
    end
    eval(['parsedStruct.' tName '=tData;'])
end

parsedStruct.completedTrials=numel(parsedStruct.trialDurs);
% 
% % contrasts as a fraction.
% attDataScalars=[1,1,1,0.001,0.001];
% attDataLabels={'contrasts','orientations','spatialFreqs','waitTimePads','trialDurs'};
% attDataNames={'contrasts','orientations','spatialFreqs','waitTimes','trialDurations'};
% 
[parsedStruct.stimSamps,parsedStruct.stimVector]=getStateSamps(parsedStruct.teensyStates,2,1);




end

