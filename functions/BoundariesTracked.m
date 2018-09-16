function [RFP_boundariesBW RFP_boundariesL RFP_boundaries_RGB] = BoundariesTracked_3D(RFP_FTL_tracked,cmap,show)
    RFP_selected = RFP_FTL_tracked;
    RFP_boundaries_RGB = zeros(size(RFP_FTL_tracked,1),size(RFP_FTL_tracked,2),3,size(RFP_FTL_tracked,3));

    for f=1:size(RFP_FTL_tracked,3);
        RFP_boundariesBW(:,:,f) = bwmorph(RFP_selected(:,:,f),'remove');
        RFP_boundariesL(:,:,f) = RFP_boundariesBW(:,:,f).*RFP_FTL_tracked(:,:,f);
        RFP_boundaries_RGB(:,:,:,f) = label2rgb(RFP_boundariesL(:,:,f), cmap, 'k', 'noshuffle');;
    end

    if strcmp(show,'on')==1;
            D=zeros(size(RFP_boundariesL,1),size(RFP_boundariesL,2),1,size(RFP_boundariesL,3));
            D(:,:,1,:)=RFP_boundariesL(:,:,:);
            montage(D, [0 1]);
            D(:,:,1,:)=RFP_boundariesL(:,:,:)+1;
            mov = immovie(RFP_boundaries_RGB);
            implay(mov)
    end

end