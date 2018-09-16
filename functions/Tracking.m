function [RFP_FTL_tracked RFP_FTL_tracked_RGB Stats_new] = Tracking(RFP_FTL, Stats_table, cmap, Distance,N,merge,show)
    Stats_new = Stats_table;
    RFP_FTL_tracked = zeros(size(RFP_FTL));
    RFP_FTL_tracked_RGB = zeros(size(RFP_FTL_tracked,1),size(RFP_FTL_tracked,2),3,size(RFP_FTL_tracked,3));

    RFP_FTL_tracked(:,:,1) = RFP_FTL(:,:,1);
    F0_t_RGB = label2rgb(RFP_FTL(:,:,1), cmap, 'k', 'noshuffle');
    RFP_FTL_tracked_RGB(:,:,:,1) = F0_t_RGB(:,:,:);
    newLabel=max(max(max(RFP_FTL(:,:,:))))+1;
    
    for f=2:size(RFP_FTL,3)
    
        disp(['frame ',num2str(f-1),' to ',num2str(f)])
        %F0 = 1
        %F1 = 2
        F0_t = RFP_FTL_tracked(:,:,f-1);
        F1_0 = RFP_FTL(:,:,f);
        F1_t = RFP_FTL_tracked(:,:,f);

        Stats0 = Stats_new{f-1,1};
        Stats1 = Stats_new{f,1};

        Stats0.Label = (1:size(Stats0,1))';
        toremove = table2array(Stats0(:,'Area'))>50000;
        Stats0(toremove,:)= [];
    
        Stats1.Label = (1:size(Stats1,1))';
        toremove = table2array(Stats1(:,'Area'))>50000;
        Stats1(toremove,:)= [];

        %x=1
        %[F1_t F1_t_RGB Stats1t] = Tracknextframe(Stats0, Stats1,F1_0,F1_t, cmap_shuffled,f,10);     
        %[F1_t F1_t_RGB Stats1t newLabel] = Tracknextframe2(Stats0, Stats1,F0_t,F1_0,F1_t, cmap_shuffled,f,30,newLabel);     
        %[F1_t F1_t_RGB Stats1t newLabel] = Tracknextframe3(Stats_new, Stats0, Stats1,F0_t,F1_0,F1_t, cmap_shuffled,f,30,newLabel);     
        %[F1_t F1_t_RGB Stats1t newLabel] = Tracknextframe4(Stats_new, Stats0, Stats1,F0_t,F1_0,F1_t, cmap_shuffled,f,20,newLabel,8); % for movie1    
        [F1_t F1_t_RGB Stats1t newLabel] = Tracknextframe4(Stats_new, Stats0, Stats1,F0_t,F1_0,F1_t, cmap,f,Distance,newLabel,N);  %for others   
        RFP_FTL_tracked(:,:,f) = F1_t(:,:);
        RFP_FTL_tracked_RGB(:,:,:,f) = F1_t_RGB(:,:,:);
        Stats_new{f,1} = Stats1t;

    end
    if strcmp(merge,'on') == 1;
        [RFP_FTL_tracked RFP_FTL_tracked_RGB ] = MergeTracking(RFP_FTL_tracked, Stats_new, cmap);
    end  
    if strcmp(show,'on')==1;
        D=zeros(size(RFP_FTL_tracked,1),size(RFP_FTL_tracked,2),1,size(RFP_FTL_tracked,3));
        D(:,:,1,:)=RFP_FTL_tracked(:,:,:);
        montage(D, [0 1]);
        D(:,:,1,:)=RFP_FTL_tracked(:,:,:)+1;
        mov = immovie(RFP_FTL_tracked_RGB);
        implay(mov)
    end

end