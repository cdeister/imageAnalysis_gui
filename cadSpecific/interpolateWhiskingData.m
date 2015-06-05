nullPositions=find(y1_positions==0);
for n=1:numel(nullPositions)
    y1_positions(nullPositions(n))=y1_positions(nullPositions(n)-1);
end

nullPositions=find(x1_positions==0);
for n=1:numel(nullPositions)
    x1_positions(nullPositions(n))=x1_positions(nullPositions(n)-1);
end

nullPositions=find(y2_positions==0);
for n=1:numel(nullPositions)
    y2_positions(nullPositions(n))=y2_positions(nullPositions(n)-1);
end

nullPositions=find(x2_positions==0);
for n=1:numel(nullPositions)
    x2_positions(nullPositions(n))=x2_positions(nullPositions(n)-1);
    
end

%%
figure,hold all,plot(y1_positions),hold all,plot(y2_positions),hold all,plot(y2_positions-y1_positions),hold all,plot(smooth(diff(y2_positions-y1_positions)))
hold all,plot(dendriticF'-34)
