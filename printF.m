function[Stats_GFP] = printF(Stats_GFP,Path,File,Name,spot)
    Folder='F/';
    mkdir([Path,File,Name,'/',Folder])
    for f = 1:size(Stats_GFP,1)
        disp(['frame ',num2str(f)]);
        %Stats_GFP_table = struct2table(Stats_GFP{f,1});
        Stats_GFP_table = Stats_GFP{f,1};
        Stats_GFP_table.Label = (1:length(Stats_GFP_table.MeanIntensity))';
        toremove = isnan(table2array(Stats_GFP_table(:,'MeanIntensity')));
        Stats_GFP_table(toremove,:)= [];
        toremove = find(table2array(Stats_GFP_table(:,'Area'))<6);
        Stats_GFP_table(toremove,:)= [];
        if strcmp(spot,'on')==1;
            for Label = [Stats_GFP_table.Label]'
                index = find(Stats_GFP_table.Label==Label);
                %Idx = Stats_GFP_table.PixelIdxList{index,1};
                %List = Stats_GFP_table.PixelList{index,1};
                Values = Stats_GFP_table.PixelValues{index,1};
                Sorted = sort(Values);
                Below50 = Sorted(1:round(length(Sorted)*0.5));
                Top5 = Sorted(round(length(Sorted)-5):length(Sorted));
                Top3 = Sorted(round(length(Sorted)-3):length(Sorted));
                Max = max(Sorted);
                Stats_GFP_table.Top5(index,1) = mean(Top5);
                Stats_GFP_table.Top5Norm(index,1) = mean(Top5)/mean(Below50);
                Stats_GFP_table.Top3(index,1) = mean(Top3);
                Stats_GFP_table.Top3Norm(index,1) = mean(Top3)/mean(Below50);
                Stats_GFP_table.Max(index,1) = max(Values);
                Stats_GFP_table.MaxNorm(index,1) = Max/mean(Below50);
            end
        end  
        try
            Stats_GFP{f,1} = Stats_GFP_table;
            toPrint = Stats_GFP_table(:,[1 2 4 6:size(Stats_GFP_table,2)]);
            writetable(toPrint,[Path,File,Name,'/',Folder,'frame',num2str(f),'.txt']);
        end
    end
end
