function overalyRois(roisCenters,roisBoundaries,roisT,colorString,textT)
if textT    
hold all
    for i=1:numel(roisT)
        plot(roisBoundaries{roisT(i),1}(:,2),roisBoundaries{roisT(i),1}(:,1),colorString,'LineWidth',1.5)
        text(roisCenters(roisT(i),1).Centroid(1)-1, roisCenters(roisT(i),1).Centroid(2), num2str(roisT(i)),'FontSize',11,'FontWeight','Bold','Color',[0 0 0]);
    end
else
    for i=1:numel(roisT)
        plot(roisBoundaries{roisT(i),1}(:,2),roisBoundaries{roisT(i),1}(:,1),colorString,'LineWidth',1.5)
    end  
end
end
