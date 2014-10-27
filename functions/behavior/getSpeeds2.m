function [steps,interStepIntervals,acceleration,velocity]=getSpeeds2(dataV,diam,sampRate,quadRange)

% data, should be a vector of encoder step data.
% diam, is the diameter of the ball
% quadRange, is the number of steps per revolution as specified by the encoder you have.
% I use an encoder with 1024 steps/rev
% sample rate, is the sample rate of the session you aquired data in. 

convDiam=diam*0.0254;   % to convert inches to meters
stepDist=convDiam/quadRange; % in meters should be .00062341 m/step for 8 inch ball/1024 quad.

steps=zeros(size(dataV));
steps(find(diff(dataV)>0.5))=1;

countSteps=numel(find(diff(dataV)>0.5));
stepSample=find(diff(dataV)>0.5);
stepISI=diff(stepSample);

if countSteps>=2;
    interStepIntervals=zeros(size(dataV));
    interStepIntervals(stepSample(2:end))=stepISI;
    acceleration=zeros(size(dataV));
    acceleration(stepSample(2:end))=stepDist./stepISI;
else
    interStepIntervals=zeros(size(dataV));
    acceleration=zeros(size(dataV));

end

if countSteps>=3;
velocity=zeros(size(dataV));
velocity(stepSample(3:end))=diff(stepDist./stepISI);
else
velocity=zeros(size(dataV));
end
    

end

