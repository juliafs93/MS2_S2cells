function [TL TL_RGB Stats_table] = FindCircles(T,parameters,Bits)
        [RadiusMin RadiusMax Sensitivity] = parameters{:};
        %level = graythresh(toThreshold);
        %T = MAX_proj_3D(toThreshold);
         [centers,radii] = imfindcircles(T,[RadiusMin,RadiusMax],'Sensitivity',Sensitivity);
         %subplot(133);imagesc(toThreshold); hold on
        %viscircles(centers, radii,'EdgeColor','k','EnhanceVisibility',true);
        mask = zeros(size(T));
        for i = 1:length(centers)
        [x,y] = meshgrid(1:size(T,2),1:size(T,1));
        distance = (x-centers(i,1)).^2+(y-centers(i,2)).^2;
        mask(:,:,i) = (distance<radii(i)^2)*i;
        %imshow(mask)
        end
     TL = MAX_proj_3D(mask);
     %imagesc(Labelled)
        TL_RGB = label2rgb(TL,'jet', 'k', 'shuffle');
        Stats_table = regionprops('table',TL,'Area','Centroid','SubarrayIdx');

end