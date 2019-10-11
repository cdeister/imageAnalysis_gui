% change this to make new bin sizes Xtrials/bins
timingParams.numBins=1;
timingParams.numTrials=numel(session.trial_start_times);

analyzedBehavior.responseRaster=zeros(numel(session.lick_times),1);
analyzedBehavior.licksRelativeToStim=cell(numel(session.lick_times),1);
analyzedBehavior.reactionTimes=zeros(numel(session.lick_times),1);
analyzedBehavior.windowLicks=cell(numel(session.lick_times),1);

for k=1:numel(session.lick_times)
    if numel(session.lick_times{1,k})==0
        analyzedBehavior.responseRaster(k,1)=0;
    else
        for j=1:numel(session.lick_times)
            localVector=session.lick_times{1,k};
            analyzedBehavior.windowLicks{k}=localVector(localVector>0 & localVector<session.reward_duration);
            if numel(analyzedBehavior.windowLicks{k}) ~= 0
                analyzedBehavior.reactionTimes(k)=analyzedBehavior.windowLicks{k}(1);
                analyzedBehavior.responseRaster(k,1)=1;
            else
            end
            clear('localVector')
        end
    end
end

%reactionTimes=cell2mat(reactionTimes);

analyzedBehavior.hitTrials=nan(numel(session.lick_times),1);
analyzedBehavior.missTrials=nan(numel(session.lick_times),1);
analyzedBehavior.falseTrials=nan(numel(session.lick_times),1);
analyzedBehavior.rejectTrials=nan(numel(session.lick_times),1);

for k=1:numel(session.lick_times)
    if analyzedBehavior.responseRaster(k,1)==1 && session.stim_amplitude(1,k)~=0
        analyzedBehavior.hitTrials(k)=1;
        analyzedBehavior.missTrials(k)=0;
    elseif analyzedBehavior.responseRaster(k,1)==1 && session.stim_amplitude(1,k)==0
        analyzedBehavior.falseTrials(k)=1;
        analyzedBehavior.rejectTrials(k)=0;
    elseif analyzedBehavior.responseRaster(k,1)==0 && session.stim_amplitude(1,k)~=0
        analyzedBehavior.missTrials(k)=1;
        analyzedBehavior.hitTrials(k)=0;
    elseif analyzedBehavior.responseRaster(k,1)==0 && session.stim_amplitude(1,k)==0
        analyzedBehavior.rejectTrials(k)=1;
        analyzedBehavior.falseTrials(k)=0;
    end
end

analyzedBehavior.hitRate=nanmean(analyzedBehavior.hitTrials);
analyzedBehavior.falseAlarmRate=nanmean(analyzedBehavior.falseTrials);
analyzedBehavior.dPrimeEstimate=norminv(analyzedBehavior.hitRate)-norminv(analyzedBehavior.falseAlarmRate);

% for j=1:timingParams.numBins,
%     analyzedBehavior.binnedHitRate(:,j)=nanmean(analyzedBehavior.hitTrials(1+((j-1)*(fix(timingParams.numTrials/timingParams.numBins))):((j-1)*(fix(timingParams.numTrials/timingParams.numBins)))+(fix(timingParams.numTrials/timingParams.numBins))));
%     analyzedBehavior.binnedFalseAlarmRate(:,j)=nanmean(analyzedBehavior.falseTrials(1+((j-1)*(fix(timingParams.numTrials/timingParams.numBins))):((j-1)*(fix(timingParams.numTrials/timingParams.numBins)))+(fix(timingParams.numTrials/timingParams.numBins))));
%     analyzedBehavior.binnedMissRate(:,j)=nanmean(analyzedBehavior.missTrials(1+((j-1)*(fix(timingParams.numTrials/timingParams.numBins))):((j-1)*(fix(timingParams.numTrials/timingParams.numBins)))+(fix(timingParams.numTrials/timingParams.numBins))));
%     analyzedBehavior.binnedDPrime=norminv(analyzedBehavior.binnedHitRate)-norminv(analyzedBehavior.binnedFalseAlarmRate);
% end

clear('j','k')
