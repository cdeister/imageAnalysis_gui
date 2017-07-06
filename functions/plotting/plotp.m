function plotp(mat2D,figNum)

if nargin==2
    figure(figNum)
else
    figure
end


plot(mat2D(:,1),mat2D(:,2))

end