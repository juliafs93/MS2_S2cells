function [RFPtoThreshold] = ContrastMSD(RFPtoThreshold, InputLow, InputHigh,Bits,show)
    for f=1:size(RFPtoThreshold,3)
        disp(['contrasting f',num2str(f),'...'])
        toThreshold = RFPtoThreshold(:,:,f)./(2^Bits-1);
        Mean = mean2(MAX_proj_3D(toThreshold));
        SD = std2(MAX_proj_3D(toThreshold));
        %Mean = mean(toThreshold(:))
        %SD = std(toThreshold(:))
        Low = Mean-SD; High = Mean+SD;
        if Low < 0; Low = 0; end
        if High > 1; High = 1; end
        toThreshold = imadjust(toThreshold,[Low, High],[0; 1]);
        toThreshold = imadjust(toThreshold,[InputLow,InputHigh],[0; 1]);
        RFPtoThreshold(:,:,f) = toThreshold;
    end

    if strcmp(show,'on')==1;
        D=zeros(size(RFPtoThreshold,1),size(RFPtoThreshold,2),1,size(RFPtoThreshold,4));
        %D(:,:,1,:)=RFPtoThreshold(:,:,1,:);
        %montage(D, [0 1]);
        D(:,:,1,:)=RFPtoThreshold(:,:,floor(size(RFPtoThreshold,3)/2),:);
        montage(D, [0 1]);
        %D(:,:,1,:)=RFPtoThreshold(:,:,size(RFPtoThreshold,3),:);
        %montage(D, [0 1]);
    end
end