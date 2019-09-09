function plotDeconvolvedCell(cellNum,smthNum)

if nargin == 1
    smthNum=1;
else
end

curF = evalin('base',['somaticF_DF(' num2str(cellNum) ',:);']);
curC = evalin('base',['somaticF_DF_Clean(' num2str(cellNum) ',:);']);
curCE = evalin('base',['somaticF_DF_Events(' num2str(cellNum) ',:);']);
curE = evalin('base',['eventEstimate(' num2str(cellNum) ',:);']);


plot(nPointMean(curF,smthNum),'b-')
hold all,plot(curC,'r-')
hold all,plot(curCE,'k-')
hold all,plot(curE,'c-')
hold off

end

