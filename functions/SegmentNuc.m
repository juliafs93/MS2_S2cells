function [RFP_FTL RFP_FTL_RGB Stats_table] = SegmentNuc(RFPtoThreshold, Function, parameters,Bits, show)
    RFP_FTL = zeros(size(RFPtoThreshold,1),size(RFPtoThreshold,2),size(RFPtoThreshold,3));
    RFP_FTL_RGB = zeros(size(RFPtoThreshold,1),size(RFPtoThreshold,2),3,size(RFPtoThreshold,3));
    %Stats = cell(size(RFPtoThreshold,3),1);
    Stats_table = cell(size(RFPtoThreshold,3),1);
    for f=1:size(RFPtoThreshold,3)
        disp(['Segmenting f',num2str(f)]);
        %[T_L T_L_RGB Stats] = FiltThresLab(img,LoGradius, level, areaopen)
        %[T_L T_L_RGB Stats] = ThresLabNBs(toThreshold,remove1, diskSize, WatershedParameter,remove2)
        [RFP_FTL(:,:,f) RFP_FTL_RGB(:,:,:,f) Stats_table{f,1}] = Function(RFPtoThreshold(:,:,f),parameters, Bits);
        %[RFP_FTL(:,:,f) RFP_FTL_RGB(:,:,:,f) Stats_table{f,1}] = SegMembrane(RFPtoThreshold(:,:,f),parameters, Bits);

    end
    
    %
    if strcmp(show,'on')==1;
        D=zeros(size(RFP_FTL,1),size(RFP_FTL,2),1,size(RFP_FTL,3));
        D(:,:,1,:)=RFP_FTL(:,:,:);
        montage(D, [0 1]);
        D(:,:,1,:)=RFP_FTL(:,:,:)+1;
        mov = immovie(RFP_FTL_RGB);
        implay(mov)
    end
end