function out=bandPassData(data,sampleInterval,lowCut,highCut,meanSubtract)

%sampleInterval = 0.03297953;
sampleRate= 1/sampleInterval;
N = size(data,1);
dF = sampleRate/N;
f = (-sampleRate/2:dF:sampleRate/2-dF)';
%lowCut=.0005;
%highCut=2;
BPF = ((lowCut < abs(f)) & (abs(f) < highCut));

for g=1:size(data,2)
    if meanSubtract,
        meanSubData=data(:,g)-mean(data(:,g));
        dataFilt = fftshift(fft(meanSubData))/N;
        dataFilt = BPF.*dataFilt;
        out(:,g)=ifft(ifftshift(dataFilt))*N+mean(data(:,g)); %inverse ifft
    else
        dataFilt = fftshift(fft(data(:,g)))/N;
        dataFilt = BPF.*dataFilt;
        out(:,g)=ifft(ifftshift(dataFilt))*N+mean(data(:,g)); %inverse ifft
    end
end

end
