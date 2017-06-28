function out=dpSig(dist1,dist2)

out=(mean(dist1)-mean(dist2))./sqrt((std(dist1)+std(dist2)));


end