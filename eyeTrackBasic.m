
cropEye = importedImages(224:297,447:529,:);
frameClock = 0.0111:0.0111:size(cropEye,3)*0.0111;
for n = 1:size(cropEye,3)
    cropEyeBW = medfilt2(im2bw( cropEye(:,:,n) , 0.25 ));
    cropEyeBW2 = medfilt2(im2bw( cropEye(:,:,n) , 0.45 ));
    tPL = regionprops(cropEyeBW,'PixelList');
    tPL2 = regionprops(cropEyeBW2,'PixelList');
    tCtr = regionprops(cropEyeBW,'Centroid');
    tCtr2 = regionprops(cropEyeBW2,'Centroid');
    for k=1:numel(tPL)
        maxPixels(k)=size(tPL(1).PixelList,1);
        maxPixels2(k)=size(tPL2(1).PixelList,1);
    end
    [maxPixCount(n) maxInd] = max(maxPixels);
    [maxPixCount2(n) maxInd2] = max(maxPixels2);
    eyeCenters(:,n) = tCtr(maxInd).Centroid;
    eyeCenters2(:,n) = tCtr2(maxInd2).Centroid;
    clear maxPixels tCtr tPL tCtr2 tPL2 maxPixels2
    
end