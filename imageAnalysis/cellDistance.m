function [out]=cellDistance(targetCell,compareCells,centroids,pixelSize)

a=centroids(targetCell,1).Centroid;

for n=1:numel(compareCells)
    b=centroids(compareCells(n),1).Centroid;
    out(:,n)=sqrt(((a(1)-b(1))^2)+((a(2)-b(2))^2))*pixelSize;
   
end