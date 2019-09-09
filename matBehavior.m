function varargout = matBehavior(varargin)
% MATBEHAVIOR MATLAB code for matBehavior.fig
%      MATBEHAVIOR, by itself, creates a new MATBEHAVIOR or raises the existing
%      singleton*.
%
%      H = MATBEHAVIOR returns the handle to a new MATBEHAVIOR or the handle to
%      the existing singleton*.
%
%      MATBEHAVIOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MATBEHAVIOR.M with the given input arguments.
%
%      MATBEHAVIOR('Property','Value',...) creates a new MATBEHAVIOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before matBehavior_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to matBehavior_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help matBehavior

% Last Modified by GUIDE v2.5 29-Apr-2019 00:56:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @matBehavior_OpeningFcn, ...
                   'gui_OutputFcn',  @matBehavior_OutputFcn, ...
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


% --- Executes just before matBehavior is made visible.
function matBehavior_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to matBehavior (see VARARGIN)

% Choose default command line output for matBehavior
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes matBehavior wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = matBehavior_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




function btn_loadSession_Callback(hObject, eventdata, handles)

    try
        curDir = pwd;
        lastDir = evalin('base','lastDir;');
        cd(lastDir)
        [aa,bb]=uigetfile('*.mat');
        cd(curDir)
        assignin('base','lastDir',bb);
    catch
        [aa,bb]=uigetfile('*.mat');
        assignin('base','lastDir',bb);
    end
    
    
    load([bb aa] ,'session')
    close gcf
    assignin('base','session',session);
    evalin('base','getBehavioralStuff')
    set(handles.dPrimeEst,'String',0);
	set(handles.critEstimate,'String',0);
	set(handles.filteredTrialCount,'String',0);
	set(handles.strongDPEstimate,'String',0);
	set(handles.strongCritEstimate,'String',0);
	set(handles.strongOnlyTrialCount,'String',0);
	set(handles.weakDPEstimate,'String',0);
	set(handles.weakCritEstimate,'String',0);
	set(handles.weakOnlyTrialCount,'String',0);
	set(handles.catchTrialCount,'String',0);
%     evalin('base',load([bb aa],'session'))
%     set(handles.nameEntry,'String',bdFileNames)
    btn_filterTrials_Callback(hObject, eventdata, handles);
    guidata(hObject, handles);


function nameEntry_Callback(hObject, eventdata, handles)


function nameEntry_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function btn_loadTrialData_Callback(hObject, eventdata, handles)





function dPrimeEst_Callback(hObject, eventdata, handles)


function dPrimeEst_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function critEstimate_Callback(hObject, eventdata, handles)


function critEstimate_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function preStimLickTimeEntry_Callback(hObject, eventdata, handles)


function preStimLickTimeEntry_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function trialBinWidthEntry_Callback(hObject, eventdata, handles)
% hObject    handle to trialBinWidthEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trialBinWidthEntry as text
%        str2double(get(hObject,'String')) returns contents of trialBinWidthEntry as a double


% --- Executes during object creation, after setting all properties.
function trialBinWidthEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trialBinWidthEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lickTooEarlyEntry_Callback(hObject, eventdata, handles)
% hObject    handle to lickTooEarlyEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lickTooEarlyEntry as text
%        str2double(get(hObject,'String')) returns contents of lickTooEarlyEntry as a double


% --- Executes during object creation, after setting all properties.
function lickTooEarlyEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lickTooEarlyEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function btn_filterTrials_Callback(hObject, eventdata, handles)

    trialFilter.preLickThreshold=str2num(get(handles.preStimLickTimeEntry,'string'));
    trialFilter.tooEarly=str2num(get(handles.lickTooEarlyEntry,'string'));
    trialFilter.binWidth=str2num(get(handles.trialBinWidthEntry,'string'));
    try
        session = evalin('base','session;');
        disp(session.mouse)
    catch
        disp("no session in workspace")
        return
    end
    try
        analyzedBehavior = evalin('base','analyzedBehavior;');
    catch
        disp("no analyzedBehavior in workspace")
        return
    end
    try
        timingParams = evalin('base','timingParams;');
    catch
        disp("no timingParams in workspace")
        return
    end
    set(handles.nameEntry,'String',session.mouse);
    stimTimes=session.relative_trial_start_times;
    stimAmps=session.stim_amplitude(1:numel(stimTimes));
    
    trialFilter.convKern = normpdf(-1*fix(trialFilter.binWidth/2):fix(trialFilter.binWidth/2),0,((trialFilter.binWidth)/10)); 
    trialFilter.convKern = trialFilter.convKern./sum(trialFilter.convKern); 
    
    trialFilter.smoothHit=nanconv(session.behavior.hits,trialFilter.convKern);
    trialFilter.engThreshold=((max(trialFilter.smoothHit)-min(trialFilter.smoothHit))/3)+min(trialFilter.smoothHit); %0.4;   %<--- the red line in the plot
    trialFilter.engagedTrials=find(trialFilter.smoothHit>trialFilter.engThreshold);
    trialFilter.disengagedTrials=find(trialFilter.smoothHit<=trialFilter.engThreshold);
    trialFilter.smoothCrit=crtiloc(nanconv(session.behavior.hits,trialFilter.convKern),nanconv(session.behavior.falsepos,trialFilter.convKern));
    
    %
    for n=1:numel(session.trial_start_times)
        trialFilter.preLickNumberByTrial(:,n)= ...
            numel(find(session.lick_times{1,n}>=trialFilter.preLickThreshold & session.lick_times{1,n}<trialFilter.tooEarly));
    end

    trialFilter.trialsWithPreLicks=find(trialFilter.preLickNumberByTrial>0);
    trialFilter.trialsWithNoPreLicks=find(trialFilter.preLickNumberByTrial==0);
    
    trialFilter.engagedNoLickTrials=intersect(trialFilter.engagedTrials,trialFilter.trialsWithNoPreLicks);

    trialFilter.hitTrials=analyzedBehavior.hitTrials(find(trialFilter.engagedNoLickTrials & session.optical_stim_amplitudes(trialFilter.engagedNoLickTrials)==0));
    trialFilter.rejectTrials=analyzedBehavior.rejectTrials(find(trialFilter.engagedNoLickTrials & session.optical_stim_amplitudes(trialFilter.engagedNoLickTrials)==0));
    trialFilter.stimAmps=stimAmps(find(trialFilter.engagedNoLickTrials & session.optical_stim_amplitudes(trialFilter.engagedNoLickTrials)==0));
    trialFilter.stimTimes=stimTimes(find(trialFilter.engagedNoLickTrials & session.optical_stim_amplitudes(trialFilter.engagedNoLickTrials)==0));
    trialFilter.reactionTimes=analyzedBehavior.reactionTimes(find(trialFilter.engagedNoLickTrials & session.optical_stim_amplitudes(trialFilter.engagedNoLickTrials)==0));


    trialFilter.disengaged.hitTrials=analyzedBehavior.hitTrials(find(trialFilter.engagedNoLickTrials & session.optical_stim_amplitudes(trialFilter.engagedNoLickTrials)==0));
    trialFilter.disengaged.rejectTrials=analyzedBehavior.rejectTrials(find(trialFilter.engagedNoLickTrials & session.optical_stim_amplitudes(trialFilter.engagedNoLickTrials)==0));
    trialFilter.disengaged.stimAmps=stimAmps(find(trialFilter.engagedNoLickTrials & session.optical_stim_amplitudes(trialFilter.engagedNoLickTrials)==0));
    trialFilter.disengaged.stimTimes=stimTimes(find(trialFilter.engagedNoLickTrials & session.optical_stim_amplitudes(trialFilter.engagedNoLickTrials)==0));
    trialFilter.disengaged.reactionTimes=analyzedBehavior.reactionTimes(find(trialFilter.engagedNoLickTrials & session.optical_stim_amplitudes(trialFilter.engagedNoLickTrials)==0));


    axes(handles.axes1)
    children = get(gca, 'children');
    delete(children);
    
    for i=1:timingParams.numTrials
        plot(session.lick_times{i},ones(1,numel(session.lick_times{i}))*i,'.k')
        hold all
    end
    plot([0 0],[1 timingParams.numTrials],'r-')
    xlim([-0.5 2]),title('Your Original Trials')
    ylim([-20 timingParams.numTrials])
    tempGCA=gca;
    set(tempGCA, 'Ydir', 'reverse');
    ylabel('trial number')
    xlabel('time relative to stim (sec)')
    hold off
    
    axes(handles.axes2)
    children = get(gca, 'children');
    delete(children);
    
    for i=1:numel(trialFilter.engagedNoLickTrials)
        plot(session.lick_times{trialFilter.engagedNoLickTrials(i)},...
        	ones(1,numel(session.lick_times{trialFilter.engagedNoLickTrials(i)}))*i,'.k')
        hold all
    end
    plot([0 0],[1 timingParams.numTrials],'r-')
    
    xlim([-0.5 2]),title(['Your ' num2str(numel(trialFilter.engagedNoLickTrials)) ...
    	'Filtered Trials'])
    
    tempGCA=gca;
    set(tempGCA, 'Ydir', 'reverse');
    set(tempGCA,'ytick',[]);
    xlabel('time relative to stim (sec)')
    clear tempGCA
    hold off
    
    set(handles.filteredTrialCount,'String',num2str(numel(trialFilter.engagedNoLickTrials)));

    axes(handles.axes3)
    children = get(gca, 'children');
    delete(children);

    plot(trialFilter.smoothHit,'k-')
    hold all
    plot([1 timingParams.numTrials],[trialFilter.engThreshold trialFilter.engThreshold],'b-')
    ylim([0 1])
    ylabel('response rate')
    xlabel('trial number')
    title('engagement threshold and convolved hits')
    legend('smoothed hit raster','engagement threshold')
    hold off
    
    
    assignin('base','trialFilter',trialFilter)
    
    psychometrics.stimBoundaries=[-7,-4,-3,-1.75,-0.05];

    % temp
    sA=trialFilter.stimAmps;
    hT=trialFilter.hitTrials;
    hR=trialFilter.rejectTrials;
    sB=psychometrics.stimBoundaries;

    psychometrics.stimAmplitudes=psychometrics.stimBoundaries;
    psychometrics.hitRate=zeros(size(psychometrics.stimBoundaries));
    psychometrics.stimAmplitudes(:,1)=sB(1);
    h=numel(find(hT==1 & sA'==sB(1)));
    m=numel(find(hT==0 & sA'==sB(1)));
    psychometrics.hitRate(:,1)=h/(h+m);
    psychometrics.weights(:,1)=(h+m);

    for n=2:numel(sB)
        psychometrics.stimAmplitudes(:,n)=mean(sA(find(sA>sB(n-1) & sA<=sB(n))));
        h=numel(find(hT==1 & sA'>sB(n-1) & sA'<=sB(n)));
        m=numel(find(hT==0 & sA'>sB(n-1) & sA'<=sB(n)));
        psychometrics.hitRate(:,n)=h/(h+m);
        psychometrics.weights(:,n)=(h+m);
    end



    psychometrics.stimAmplitudes(:,numel(sB)+1)=0;
    psychometrics.hitRate(:,numel(sB)+1)=numel(find(trialFilter.rejectTrials==0))/...
        numel(find(trialFilter.rejectTrials==0 | trialFilter.rejectTrials==1));
    psychometrics.weights(:,numel(sB)+1)=(h+m);
    psychometrics.stimAmplitudes(find(isnan(psychometrics.stimAmplitudes)))=psychometrics.stimBoundaries(find(isnan(psychometrics.stimAmplitudes)));

    if numel(find(isnan(psychometrics.hitRate) | psychometrics.hitRate==0))>=4
        badFitFlag=1;
    else
        badFitFlag=0;
    end
    % 

    h=numel(find(hT==1));
    m=numel(find(hT==0));
    f=numel(find(hR==0));
    r=numel(find(hR==1));

    trialFilter.dPrimeEst=norminv(h/(h+m))-norminv(f/(f+r));
    trialFilter.critEst=-0.5*(norminv(h/(h+m))+norminv(f/(f+r)));
    set(handles.dPrimeEst,'String',num2str(trialFilter.dPrimeEst))
    set(handles.critEstimate,'String',num2str(trialFilter.critEst))

    


    clear('sA','hT','hR','sB','h','m','f','r')

if badFitFlag==0
bFit = fittype('1/(1+exp((v5-x)/k))',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'v5','k'});


psychometrics.nonNormHitRate=smooth(psychometrics.hitRate(find(isnan(psychometrics.hitRate)==0))');
psychometrics.normHitRate=smooth(psychometrics.nonNormHitRate./max(psychometrics.nonNormHitRate));


psychometrics.fitCurve_x=0:0.1:max(-1*psychometrics.stimAmplitudes);

f = fit(-1*psychometrics.stimAmplitudes(find(isnan(psychometrics.hitRate)==0))',psychometrics.nonNormHitRate,bFit,'Robust','on','StartPoint', [12 6]);
fN = fit(-1*psychometrics.stimAmplitudes(find(isnan(psychometrics.hitRate)==0))',psychometrics.normHitRate,bFit,'Robust','on','StartPoint', [12 6]);

psychometrics.normCurve_y=1./(1+exp((f.v5-psychometrics.fitCurve_x)/f.k));
psychometrics.nonNormCurve_y=1./(1+exp((fN.v5-psychometrics.fitCurve_x)/fN.k));

% now plot the stimulus response function (psychometric curve)
% figure,plot(-1*psychometrics.stimAmplitudes(find(isnan(psychometrics.nonNormHitRate)==0)),psychometrics.normHitRate,'ko')
% hold all,plot(psychometrics.fitCurve_x,psychometrics.normCurve_y,'r-')
psychometrics.threshold=f.v5;
psychometrics.slope=f.k;
set(handles.pCurve_V5,'String',num2str(psychometrics.threshold));
set(handles.pCurve_k,'String',num2str(psychometrics.slope));
if timingParams.numTrials<20
    psychometrics.threshold=NaN;
    psychometrics.slope=NaN;
else
end


tNn=find(isnan(psychometrics.hitRate)==0);
tNy=find(isnan(psychometrics.hitRate)==1);

psychometrics.normHitRate(tNn)=psychometrics.normHitRate;
psychometrics.normHitRate(tNy)=NaN;
psychometrics.nonNormHitRate(tNn)=psychometrics.nonNormHitRate;
psychometrics.nonNormHitRate(tNy)=NaN;
clear tNn tNy

elseif badFitFlag==1
    psychometrics.threshold=NaN;
    psychometrics.slope=NaN;
    psychometrics.normHitRate=[NaN NaN NaN NaN NaN NaN];
    psychometrics.nonNormHitRate=[NaN NaN NaN NaN NaN NaN];
    psychometrics.fitCurve_x=0:0.5:max(-1*psychometrics.stimAmplitudes);
    psychometrics.normCurve_y=NaN(size(psychometrics.fitCurve_x));
    psychometrics.nonNormCurve_y=NaN(size(psychometrics.fitCurve_x));
end
 

psychometrics.f_threshold=f.v5;
psychometrics.f_slope=f.k;

psychometrics.f_nthreshold=fN.v5;
psychometrics.f_nslope=fN.k;

% Make Psychometric Curve Before

psychometrics.unfiltered.stimBoundaries=[-7,-4,-3,-1.75,-0.05];

% temp
sA=stimAmps;
hT=analyzedBehavior.hitTrials;
hR=analyzedBehavior.rejectTrials;
sB=psychometrics.unfiltered.stimBoundaries;

psychometrics.unfiltered.stimAmplitudes=psychometrics.unfiltered.stimBoundaries;
psychometrics.unfiltered.hitRate=zeros(size(psychometrics.unfiltered.stimBoundaries));
psychometrics.unfiltered.stimAmplitudes(:,1)=sB(1);
h=numel(find(hT==1 & sA'==sB(1)));
m=numel(find(hT==0 & sA'==sB(1)));
psychometrics.unfiltered.hitRate(:,1)=h/(h+m);
psychometrics.unfiltered.weights(:,1)=(h+m);

for n=2:numel(sB)
    psychometrics.unfiltered.stimAmplitudes(:,n)=mean(sA(find(sA>sB(n-1) & sA<=sB(n))));
    h=numel(find(hT==1 & sA'>sB(n-1) & sA'<=sB(n)));
    m=numel(find(hT==0 & sA'>sB(n-1) & sA'<=sB(n)));
    psychometrics.unfiltered.hitRate(:,n)=h/(h+m);
    psychometrics.unfiltered.weights(:,n)=(h+m);
end

if numel(find(isnan(psychometrics.unfiltered.hitRate) | psychometrics.unfiltered.hitRate==0))>=4
    badFitFlag=1;
else
    badFitFlag=0;
end
% 
psychometrics.unfiltered.stimAmplitudes(:,numel(sB)+1)=0;
psychometrics.unfiltered.hitRate(:,numel(sB)+1)=numel(find(analyzedBehavior.rejectTrials==0))/...
    numel(find(trialFilter.rejectTrials==0 | trialFilter.rejectTrials==1));
psychometrics.unfiltered.weights(:,numel(sB)+1)=(h+m);
psychometrics.unfiltered.stimAmplitudes(find(isnan(psychometrics.unfiltered.stimAmplitudes)))=psychometrics.unfiltered.stimBoundaries(find(isnan(psychometrics.unfiltered.stimAmplitudes)));


h=numel(find(hT==1));
m=numel(find(hT==0));
f=numel(find(hR==0));
r=numel(find(hR==1));

clear('sA','hT','hR','sB','h','m','f','r')

if badFitFlag==0
bFit = fittype('1/(1+exp((v5-x)/k))',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'v5','k'});


psychometrics.unfiltered.nonNormHitRate=smooth(psychometrics.unfiltered.hitRate(find(isnan(psychometrics.unfiltered.hitRate)==0))');
psychometrics.unfiltered.normHitRate=smooth(psychometrics.unfiltered.nonNormHitRate./max(psychometrics.unfiltered.nonNormHitRate));


psychometrics.unfiltered.fitCurve_x=0:0.1:max(-1*psychometrics.unfiltered.stimAmplitudes);

f = fit(-1*psychometrics.unfiltered.stimAmplitudes(find(isnan(psychometrics.unfiltered.hitRate)==0))',psychometrics.unfiltered.nonNormHitRate,bFit,'Robust','on','StartPoint', [12 6]);
fN = fit(-1*psychometrics.unfiltered.stimAmplitudes(find(isnan(psychometrics.unfiltered.hitRate)==0))',psychometrics.unfiltered.normHitRate,bFit,'Robust','on','StartPoint', [12 6]);

psychometrics.unfiltered.normCurve_y=1./(1+exp((f.v5-psychometrics.unfiltered.fitCurve_x)/f.k));
psychometrics.unfiltered.nonNormCurve_y=1./(1+exp((fN.v5-psychometrics.unfiltered.fitCurve_x)/fN.k));

% now plot the stimulus response function (psychometric curve)
% figure,plot(-1*psychometrics.unfiltered.stimAmplitudes(find(isnan(psychometrics.unfiltered.nonNormHitRate)==0)),psychometrics.unfiltered.normHitRate,'ko')
% hold all,plot(psychometrics.unfiltered.fitCurve_x,psychometrics.unfiltered.normCurve_y,'r-')
psychometrics.unfiltered.threshold=f.v5;
psychometrics.unfiltered.slope=f.k;

psychometrics.unfiltered.nthreshold=fN.v5;
psychometrics.unfiltered.nslope=fN.k;

if timingParams.numTrials<20;
    psychometrics.unfiltered.threshold=NaN;
    psychometrics.unfiltered.slope=NaN;
else
end


tNn=find(isnan(psychometrics.unfiltered.hitRate)==0);
tNy=find(isnan(psychometrics.unfiltered.hitRate)==1);

psychometrics.unfiltered.normHitRate(tNn)=psychometrics.unfiltered.normHitRate;
psychometrics.unfiltered.normHitRate(tNy)=NaN;
psychometrics.unfiltered.nonNormHitRate(tNn)=psychometrics.unfiltered.nonNormHitRate;
psychometrics.unfiltered.nonNormHitRate(tNy)=NaN;
clear tNn tNy

elseif badFitFlag==1
    psychometrics.unfiltered.threshold=NaN;
    psychometrics.unfiltered.slope=NaN;
    psychometrics.unfiltered.normHitRate=[NaN NaN NaN NaN NaN NaN];
    psychometrics.unfiltered.nonNormHitRate=[NaN NaN NaN NaN NaN NaN];
    psychometrics.unfiltered.fitCurve_x=0:0.5:max(-1*psychometrics.unfiltered.stimAmplitudes);
    psychometrics.unfiltered.normCurve_y=NaN(size(psychometrics.unfiltered.fitCurve_x));
    psychometrics.unfiltered.nonNormCurve_y=NaN(size(psychometrics.unfiltered.fitCurve_x));
end
 



% ratio of pre-lick to none
trialFilter.lickNoLickRatio=numel(trialFilter.trialsWithPreLicks)./numel(trialFilter.trialsWithNoPreLicks);

% strong vs. weak dprime
% find weak and strong trials
clear strongHits strongMisses weakHits weakMisses fAs cRs
strongResponses=find(trialFilter.stimAmps<-6.0);
weakResponses=find(trialFilter.stimAmps>-3.5 & trialFilter.stimAmps<=-0.5);
noiseResponses=find(trialFilter.stimAmps==0);
set(handles.strongOnlyTrialCount,'String',num2str(numel(strongResponses)));
set(handles.weakOnlyTrialCount,'String',num2str(numel(weakResponses)));
set(handles.catchTrialCount,'String',num2str(numel(noiseResponses)));


strongHits=find(trialFilter.hitTrials(strongResponses)==1);
strongMisses=find(trialFilter.hitTrials(strongResponses)==0);
weakHits=find(trialFilter.hitTrials(weakResponses)==1);
weakMisses=find(trialFilter.hitTrials(weakResponses)==0);
fAs=find(trialFilter.rejectTrials(noiseResponses)==0);
cRs=find(trialFilter.rejectTrials(noiseResponses)==1);


psychometrics.rt_all=nanmean(trialFilter.reactionTimes(([strongHits; weakHits])));
psychometrics.rt_weak=nanmean(trialFilter.reactionTimes(weakHits));
psychometrics.rt_strong=nanmean(trialFilter.reactionTimes(strongHits));
psychometrics.rt_fa=nanmean(trialFilter.reactionTimes(fAs));


if numel(fAs)==0
    fAs=[999];
else
end
sHR=numel(strongHits)/(numel(strongHits)+numel(strongMisses));
wHR=numel(weakHits)/(numel(weakHits)+numel(weakMisses));
fAR=numel(fAs)/(numel(fAs)+numel(cRs));

if wHR==0 || isnan(wHR)
    wHR=0.001;
else
end

if sHR==0 || isnan(sHR)
    sHR=0.001;
else
end

if fAR==0 || isnan(fAR)
    fAR=0.001;
else
end

if wHR==1
    wHR=0.999;
else
end

if sHR==1
    sHR=0.999;
else
end

if fAR==1
    fAR=0.999;
else
end

psychometrics.minDPTrials = 6;
psychometrics.strongDP=norminv(sHR)-norminv(fAR);
psychometrics.strongCrit=-0.5*(norminv(sHR)+norminv(fAR));
psychometrics.weakDP=norminv(wHR)-norminv(fAR);
psychometrics.weakCrit=-0.5*(norminv(wHR)+norminv(fAR));
    set(handles.strongDPEstimate,'String',num2str(psychometrics.strongDP));
	set(handles.strongCritEstimate,'String',num2str(psychometrics.strongCrit));
	set(handles.weakDPEstimate,'String',num2str(psychometrics.weakDP));
	set(handles.weakCritEstimate,'String',num2str(psychometrics.weakCrit));
    set(handles.weakCritEstimate,'String',num2str(psychometrics.weakCrit));
    set(handles.faEntry,'String',num2str(fAR));
    set(handles.strongHR,'String',num2str(sHR));


if numel(strongResponses)<psychometrics.minDPTrials
    psychometrics.strongDP=0;
else
end

if numel(weakResponses)<psychometrics.minDPTrials
    psychometrics.weakDP=0;
else
end

%
if isnan(psychometrics.threshold)==0

axes(handles.axes4)
children = get(gca, 'children');
delete(children);

plot(-1*psychometrics.stimAmplitudes,psychometrics.nonNormHitRate,'bo')
hold all,plot(psychometrics.fitCurve_x,psychometrics.normCurve_y,'b-')
hold all,plot(-1*psychometrics.unfiltered.stimAmplitudes,psychometrics.unfiltered.nonNormHitRate,'ro')
hold all,plot(psychometrics.unfiltered.fitCurve_x,psychometrics.unfiltered.normCurve_y,'r-')
ylim([0 1])
ylabel('hit rate')
title('raw curves')
legend('engaged','engaged fit','unfiltered','unfiltered fit')


axes(handles.axes5)
children = get(gca, 'children');
delete(children);
plot(-1*psychometrics.stimAmplitudes,psychometrics.normHitRate,'bo')
hold all,plot(psychometrics.fitCurve_x,psychometrics.nonNormCurve_y,'b-')
hold all,plot(-1*psychometrics.unfiltered.stimAmplitudes,psychometrics.unfiltered.normHitRate,'ro')
hold all,plot(psychometrics.unfiltered.fitCurve_x,psychometrics.unfiltered.nonNormCurve_y,'r-')
ylim([0 1])
ylabel('hit rate')
xlabel('stimulus amplitude')
title('normalized curves')
legend(['engaged only; dprime=' num2str(trialFilter.dPrimeEst,'%.2f')],['engaged fit; thresh=' num2str(psychometrics.threshold,'%.2f')],['unfiltered; dprime=' num2str(analyzedBehavior.dPrimeEstimate,'%.2f')],['unfiltered fit; thresh=' num2str(psychometrics.unfiltered.threshold,'%.2f')],'Location','southwest')

else
    disp('fits no good; too few trials')
end

btn_addToPool_Callback(hObject, eventdata, handles)

guidata(hObject, handles);


function pushbutton4_Callback(hObject, eventdata, handles)


function filteredTrialCount_Callback(hObject, eventdata, handles)


function filteredTrialCount_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function strongDPEstimate_Callback(hObject, eventdata, handles)


function strongDPEstimate_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function strongCritEstimate_Callback(hObject, eventdata, handles)


function strongCritEstimate_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function btn_addToPool_Callback(hObject, eventdata, handles)
	curSubject = get(handles.nameEntry,'String');
   	curSubject(regexp(curSubject,'[-]'))=[]
	try
		poolData = evalin('base',['pooled_' curSubject]);
	catch
		poolData = [];
	end
	curEntry = str2num(get(handles.poolIndex,'String'));
	disp(curEntry)
	disp(str2num(get(handles.dPrimeEst,'String')))
	poolData(1,curEntry) = str2num(get(handles.dPrimeEst,'String'));
	poolData(2,curEntry) = str2num(get(handles.critEstimate,'String'));
	poolData(3,curEntry) = str2num(get(handles.filteredTrialCount,'String'));
	poolData(4,curEntry) = str2num(get(handles.strongDPEstimate,'String'));
	poolData(5,curEntry) = str2num(get(handles.strongCritEstimate,'String'));
	poolData(6,curEntry) = str2num(get(handles.strongOnlyTrialCount,'String'));
	poolData(7,curEntry) = str2num(get(handles.weakDPEstimate,'String'));
	poolData(8,curEntry) = str2num(get(handles.weakCritEstimate,'String'));
	poolData(9,curEntry) = str2num(get(handles.weakOnlyTrialCount,'String'));
	poolData(10,curEntry) = str2num(get(handles.catchTrialCount,'String'));
    poolData(11,curEntry) = str2num(get(handles.strongHR,'String'));
    poolData(12,curEntry) = str2num(get(handles.faEntry,'String'));
    poolData(13,curEntry) = str2num(get(handles.pCurve_V5,'String'));
    poolData(14,curEntry) = str2num(get(handles.pCurve_k,'String'));

	assignin('base',['pooled_' curSubject],poolData);
	size(poolData)
	set(handles.poolIndex,'String',curEntry+1); 


function strongOnlyTrialCount_Callback(hObject, eventdata, handles)


function strongOnlyTrialCount_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function weakDPEstimate_Callback(hObject, eventdata, handles)


function weakDPEstimate_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function poolIndex_Callback(hObject, eventdata, handles)


function poolIndex_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function weakCritEstimate_Callback(hObject, eventdata, handles)


function weakCritEstimate_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function weakOnlyTrialCount_Callback(hObject, eventdata, handles)


function weakOnlyTrialCount_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function catchTrialCount_Callback(hObject, eventdata, handles)


function catchTrialCount_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function strongHR_Callback(hObject, eventdata, handles)


function strongHR_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function faEntry_Callback(hObject, eventdata, handles)


function faEntry_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pCurve_V5_Callback(hObject, eventdata, handles)


function pCurve_V5_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pCurve_Max_Callback(hObject, eventdata, handles)


function pCurve_Max_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pCurve_k_Callback(hObject, eventdata, handles)


function pCurve_k_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
