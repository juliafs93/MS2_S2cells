% BEFORE START DO manual = true
%%
if manual == true
    clear all
    [File,Path] = uigetfile('*.tif');
    %Name = '_m5m8peveLacZt2/' 
    Name = '_segmented/'
    %Name = '_eve2_2_blast/'% CHANGE NICKNAME HERE
    mkdir([Path,File,Name])
    PathToSave = [Path,File,Name,File]; 
    show = 'on'
else
    show = 'off'
end

%%
mkdir([Path,File,Name])  

try %reads parameters file and imports previous parameters
    Parameters = readtable([Path,File,Name,File,'_parameters.txt']);
    for x = [1:length(Parameters.Properties.VariableNames)]
        command = strcat(char(Parameters.Properties.VariableNames(x)), ' = ', num2str(Parameters.(x)));
        eval(command)
    end
    skip = true %dont change
    %MaxN = 10 %here add parameters that you want to change globally when
    %mainNBs is run as function in all datasets
catch
    % if no parameter file, set them here
    % Z0 and Zf are slices used for max projection and F measurements, so
    % far always used all of them
    % Z0toSeg and ZftoSeg are the slices used for segmentation and tracking
    % (will do the max projection of Red and Green channels and add them,
    % so choose slices in which both R and G signals are strong but dont
    % overlap too much when projecting)
    disp('couldnt read parameters, set them below (press any key to continue)')
    pause
    [Bits, Width,Height, Channels, SlicesO, FramesO,XRes, YRes, ZRes] = readMetadata(Path, File)
    try
    XYRes=round(mean([XRes,YRes]),2);
    ZRes = round(ZRes,2);
    end
    Y0 = 1 % Y start, pixels, default 1
    Yf = Height % Y end, pixels, default Heigth
    X0 = 1 % X start, pixels, default 1
    Xf = Width % X end, pixels, default Width
    Z0 = 1 % Z start, pixels, default 1
    Zf = SlicesO % Z end, pixels, default Slices
    T0 = 31 % T start, frame, default 1
    Tf = FramesO-1 %T end, frame, default Frames
    Z0toSeg = 1 % Z start for segmentation, pixels, default 1
    ZftoSeg = SlicesO % Z start for segmentation, pixels,default Slices
    skip = false %dont change
    TimeRes=9.816; %set time resolution
end
%%
A = Read5d([Path,File], Channels, SlicesO, FramesO);
disp('read 5d')
B = A(Y0:Yf, X0:Xf,:,Z0:Zf,T0:Tf);
Frames = size(B,5) 
Slices = size(B,4)
clear A
    
% RFPtoThreshold = MAX_proj(B, 1,Frames, Z0toSeg, ZftoSeg, 2);
GFP_max_proj = MAX_proj(B, 1,Frames, 1,Slices,1);
  % parametersn to segment and track cells
MedianFilt = 3;
InputLow = 0.2; %%0.1
InputHigh = 0.8;
RadiusMin = 7;
RadiusMax = 12;
Sensitivity = 0.94;
Distance = 15;
MaxN = 5;


% Filter
[toThresholdG] = Filter_3D(GFP_max_proj, MedianFilt, 'off');
% Increase contrast
[toThreshold3G] = ContrastMSD(toThresholdG, InputLow, InputHigh,Bits,show);
% Segment cells
[FTL_G FTL_RGB_G Stats_table_G] = SegmentNuc(toThreshold3G, @FindCircles, num2cell([RadiusMin RadiusMax Sensitivity]),Bits,show);
% Track cells
cmap = jet(100000);   
cmap_shuffled = cmap(randperm(size(cmap,1)),:);
[FTL_tracked FTL_tracked_RGB Stats_tracked] = Tracking(FTL_G, Stats_table_G, cmap_shuffled, Distance,MaxN,'off',show);
[boundariesBW boundariesL boundaries_RGB] = BoundariesTracked(FTL_tracked,cmap_shuffled,show);
WriteRGB(boundaries_RGB, PathToSave, '_segmented_tracked_boundaries_RGB.tiff','none')
Write8b(boundariesL, PathToSave, '_segmented_tracked_boundariesL.tiff')

% measure and save F, save movies by F levels
[Stats_GFP MaxF MinF] = getStatsF(FTL_tracked, GFP_max_proj);
[Stats_GFP] = printF(Stats_GFP,Path,File,Name,'on');
[FTL_tracked_meanF] = replaceLabelsbyF(FTL_tracked, Stats_GFP, 1,2^Bits-1,'Max');
%Write8b(FTL_tracked_meanF, PathToSave, '_segmented_tracked_8F.tiff')
Merged_meanF_maxGFP = (GFP_max_proj./(2.^(Bits-8))+FTL_tracked_meanF);
Write8b(Merged_meanF_maxGFP, PathToSave, '_maxF_maxGFP.tiff')


% save all images and parameters
Baseline=0;

parameters = table(Bits,Channels, SlicesO, FramesO,Slices, Frames,Width,...
    Height,X0,Xf,Y0,Yf,Z0,Zf,T0,Tf,Z0toSeg,ZftoSeg,MedianFilt,InputLow,...
    InputHigh,RadiusMin,RadiusMax,Sensitivity,Distance,MaxN,TimeRes,XYRes,ZRes);
writetable(parameters,[Path,File,Name,File,'_parameters.txt']);

Metadata = readtable('~/MATLAB_R_scripts/metadata MS2_cells_new.txt','Delimiter', '\t');
NewMetadata = cell2table({Path,File,Name,Frames,Bits,TimeRes,XYRes,ZRes,Baseline},'VariableNames', {'Path','File','Name','Frames', 'Bits','TimeRes','XYRes','ZRes','Baseline'});
SaveMetadata = [Metadata;NewMetadata];
writetable(SaveMetadata,'~/MATLAB_R_scripts/metadata MS2_cells_new.txt','Delimiter', '\t');

system('/usr/local/bin/Rscript --verbose ~/MATLAB_R_scripts/RunfromMatlabZoe.R ');

FTL_tracked_meanF_maxGFP_noB_selected = ~boundariesL.*Merged_meanF_maxGFP;
[FTL_tracked_meanF_maxGFP_boundaries_selected] = Merge8bRGB(FTL_tracked_meanF_maxGFP_noB_selected, boundaries_RGB,show);
Factor = 2; % 1 in macbook, 2 in pro
printLabels_new(FTL_tracked_meanF_maxGFP_boundaries_selected,Stats_GFP,Factor,'off', PathToSave, '_segmented_tracked_info.tiff','packbits')
disp('done')
