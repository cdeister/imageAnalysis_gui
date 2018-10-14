function [trigData]=hmTrigger(nData,stimFrames,stimWin,smoothBool,smoothFac)
% nData is an cell x observations matrix of data like ca2+ imaging data
% stimFrames is a vector of indicies of observations (frames) to trigger on
% stimWin is a two-element vector with the first being the pre-trig window
% in observations and the second being the post.

if nargin == 3
    smoothBool = 0;
    smoothFac = 0;
end

disp(size(nData))
if (smoothBool == 1)
    nData = nPointMean(nData,smoothFac);
    
    nData=nData';
    disp(size(nData))
else
end

% trigger things
preWindow = stimWin(1); % (frames);
postWindow = stimWin(2); % (frames);

% do we pad?
if stimFrames(1)<preWindow
    padLen = preWindow-stimFrames(1);
    nData=padarray(nData',padLen,NaN,'pre');
    % because we added some non-data to our matrix, our trigger indicies
    % are off by that amount (padLen) so we add that to the indicies
    stimFrames=stimFrames+padLen;
    nData=nData';
end

if (stimFrames(end)+postWindow)>size(nData,2)
    disp("padded")
    padLen = (stimFrames(end)+postWindow)-size(nData,2);
    disp(padLen)
    nData=padarray(nData',padLen,NaN,'post');
    nData=nData';
end

    


for n = 1:numel(stimFrames)
    disp(size(nData(:,stimFrames(n)-preWindow:stimFrames(n)+postWindow)))
    trigData(:,:,n) = nData(:,stimFrames(n)-preWindow:stimFrames(n)+postWindow);
end

    
end