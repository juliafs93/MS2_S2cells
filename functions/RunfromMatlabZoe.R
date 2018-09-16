#!/usr/bin/env Rscript
setwd('~/Google Drive/MATLAB_R_scripts/')
library('ggplot2')
library(gridExtra)

info <- read.delim('~/Google Drive/MATLAB_R_scripts/metadata MS2_cells_new.txt', stringsAsFactors = FALSE)
minNumber <- 10

ReplaceLabels <- function(Path, GFP_all,frames){
  try({
    cat('finding toReplace.txt')
    toReplaceFile <- list.files(path = Path, pattern ='toReplace.txt')
    toReplace <- read.delim(paste(Path,toReplaceFile,sep=''),sep='\t', header=TRUE, stringsAsFactors = FALSE)
    toReplace$fromF[is.na(toReplace$fromF)] <- 1
    toReplace$toF[is.na(toReplace$toF)] <- frames
    # 
    for (x in 1:length(rownames(toReplace))){
      GFP_all$NewLabel[GFP_all$NewLabel == toReplace[x,2] & GFP_all$Frame >= toReplace[x,3] & GFP_all$Frame <= toReplace[x,4]] <- toReplace[x,1]
    }
    GFP_all <- GFP_all[!GFP_all$NewLabel == 0,]
    cat('Labels replaced')
  }, silent=TRUE)
  return(GFP_all)
}
Run <- function(Start, End, info, minNumber,toPlot){
  for (x in Start:End){
    Path  <- paste(info[x,1],info[x,2],info[x,3],sep='')
    cat(Path)
    frames <- info[x,4]
    Width <- frames/20
    Folder <- unlist(strsplit(Path,'/'))
    Folder <- Folder[length(Folder)]
    Bits <- info[x,5]
    TimeRes <- info[x,6]
    XYRes <- info[x,7]
    ZRes <- info[x,8]
    
    
    
    GFP_all <- data.frame()
    for (f in 1:frames){
      try({
        GFP <- read.delim(paste(Path,'/F/frame',f,'.txt',sep=''),sep=',', header=TRUE, stringsAsFactors = FALSE)
      }, silent = TRUE)
      #GFP$Label <- as.factor(GFP$Label)
      GFP$Frame <- rep(f, length(rownames(GFP)))
      GFP$Time <- rep(f*TimeRes/60, length(rownames(GFP)))
      #GFP$Norm <- GFP$MaxIntensity/GFP$MeanIntensity
      GFP_all <- rbind(GFP_all,GFP)
    }
    #GFP_all$Label[GFP_all$Label == 32] = 2
    #GFP_all$MeanIntensity[GFP_all$Label == 29 & GFP_all$Frame == 251] = NA
    GFP_all$NewLabel <- GFP_all$Label
    
    GFP_all <- ReplaceLabels(Path, GFP_all,frames)
    
    # for (x in GFP_all$NewLabel){
    #    if (length(GFP_all$NewLabel[GFP_all$NewLabel==x]) < minNumber){
    #      GFP_all <- GFP_all[-c(GFP_all$NewLabel==x),]
    #   }
    #  }
    GFP_all$NewLabel <- as.factor(GFP_all$NewLabel)
    GFP_all$Label <- as.factor(GFP_all$Label)
    
    ###
    #     GFP_sub <- rbind(GFP_sub,GFP_all[GFP_all$Label==355,])
    #     
    #     GFP_sub <- GFP_all[GFP_all$Label==453|
    #                          GFP_all$Label==216|
    #                          GFP_all$Label==192|
    #                          GFP_all$Label==152|
    #                          GFP_all$Label==2244|
    #                          GFP_all$Label==225|
    #                          GFP_all$Label==99|
    #                          GFP_all$Label==1812|
    #                          GFP_all$Label==2107|
    #                          GFP_all$Label==2057|
    #                          GFP_all$Label==236,]
    ##
    Skip=FALSE
    toSelect <- GFP_all$NewLabel
    try({
      toSelect <-  read.delim(paste(Path,'/toSelect.txt',sep=''),sep='\t', header=TRUE, stringsAsFactors = FALSE)
      toSelect <- unique(toSelect$Var1)
    }, silent=TRUE)
    try({
      toSelect <-  read.delim(paste(Path,'/toReplace.txt',sep=''),sep='\t', header=TRUE, stringsAsFactors = FALSE)
      toSelect <- unique(toSelect$newL)
    }, silent=TRUE)
    try({
      GFP_sub <- data.frame()
      GFP_sub <- GFP_all
      # for (x in toSelect){
      #   if (length(GFP_all$NewLabel[GFP_all$NewLabel==x]) >= minNumber){
      #     GFP_sub <- rbind(GFP_sub,GFP_all[GFP_all$NewLabel==x,])
      #   }
      # }
      write.table(GFP_sub,paste(Path,'/F_selected.txt',sep=''), quote=F, row.names = F, sep='\t')
      
      # for (x in toSelect$Var1){
      #   GFP_nosub <- GFP_nosub[GFP_nosub$Label!=x,]
      # }
      #pdf (paste (Path,'/',Folder,'_plots_selected.pdf', sep = "", collapse = NULL), width=20, height=15, onefile = F)
      gList <- list()
      SelectedLabels <- unique(GFP_sub$NewLabel)
      # SelectedLabels <- intersect(toSelect$Var1,GFP_all$NewLabel)
      for (x in 1:length(SelectedLabels)){
        GFP_each <- GFP_sub[GFP_sub$NewLabel==SelectedLabels[x],]
        gList[[x]] <- plotF(GFP_each, toPlot,frames,2^Bits-1, TimeRes, paste('nuc #',toString(SelectedLabels[x]),sep=''))
      }
      #     gListnoL <- list()
      #     for (x in 1:length(SelectedLabels)){
      #     gListnoL[[x]] <- gList[[x]]+theme(legend.position="none")
      #     }
      #gListnoL <- lapply(gList, function(x){x+theme(legend.position="none")+
      #    scale_y_continuous(limits=c(0,2^Bits-1))+
      #    scale_x_continuous(limits=c(0,frames*TimeRes/60),breaks =seq(0,frames*TimeRes/60,6), labels=seq(0,frames*TimeRes/60,6))})
      #Grobs <- arrangeGrob(grobs=gListnoL,ncol=4)
      #grid.arrange(Grobs)
      #dev.off()
      
      pdf (paste (Path,'/',Folder,'_plots_selected_20pp.pdf', sep = "", collapse = NULL), width=15, height=20)
      for (n in 1:(length(gList)%/%20)){
        Grobs <- arrangeGrob(grobs=gList[((n-1)*20+1):(n*20)],ncol=2,nrow = 10)
        grid.arrange(Grobs)
      }
      
      Grobs <- arrangeGrob(grobs=gList[(length(gList)%/%20*20+1):length(gList)],ncol=2,nrow=10)
      grid.arrange(Grobs)
      
      
      # gList <- list()
      # for (x in 1:length(SelectedLabels)){
      #   GFP_each <- GFP_all[GFP_all$NewLabel==SelectedLabels[x],]
      #   gList[[x]] <- plotF(GFP_each, 'Top3',frames,2^Bits-1, TimeRes,paste('nuc #',toString(SelectedLabels[x]),sep=''))
      # }
      # Grobs <- arrangeGrob(grobs=gList,ncol=4)
      # grid.arrange(Grobs)
      # 
      # 
      # 
      # gList <- list()
      # toPlot <- c('Max', 'Top3','Top5','MaxNorm','Top3Norm','Top5Norm')
      # Ymax <- c(2^Bits-1,2^Bits-1,2^Bits-1,20,20,20)
      # for (x in 1:length(toPlot)){
      #   gList[[x]] <- plotF(GFP_sub, toPlot[x],frames, Ymax[x],TimeRes,toPlot[x])
      # }
      # Grobs <- arrangeGrob(grobs=gList,ncol=3)
      # grid.arrange(Grobs)
      
      #     gList <- list()
      #     toPlot <- c('Max', 'Top3','Top5','MaxNorm','Top3Norm','Top5Norm')
      #     Ymax <- c(4095,4095,4095,20,20,20)
      #     for (x in 1:length(toPlot)){
      #       gList[[x]] <- plotF(GFP_nosub, toPlot[x],frames, Ymax[x])
      #     }
      #     Grobs <- arrangeGrob(grobs=gList,ncol=3)
      #     grid.arrange(Grobs)
      
      dev.off()
      Skip=TRUE
    }, silent=TRUE)
    # if (Skip==FALSE){
    # ## print all
    # pdf (paste (Path,'/',Folder,'_plots_all.pdf', sep = "", collapse = NULL), width=30, height=20)
    # gList <- list()
    # Labels <- unique(GFP_all$NewLabel)
    # for (x in 1:length(Labels)){
    #   GFP_sub <- GFP_all[GFP_all$NewLabel==Labels[x],]
    #   gList[[x]] <- plotF(GFP_sub, 'Max',frames, 2^Bits-1,TimeRes,paste('nuc #',toString(Labels[x]),sep=''))
    # }
    # Grobs <- arrangeGrob(grobs=gList)
    # grid.arrange(Grobs)
    # gList <- list()
    # Labels <- unique(GFP_all$NewLabel)
    # for (x in 1:length(Labels)){
    #   GFP_sub <- GFP_all[GFP_all$NewLabel==Labels[x],]
    #   gList[[x]] <- plotF(GFP_sub, 'Top3',frames, 2^Bits-1,TimeRes,paste('nuc #',toString(Labels[x]),sep=''))
    # }
    # Grobs <- arrangeGrob(grobs=gList)
    # grid.arrange(Grobs)
    # 
    # gList <- list()
    # toPlot <- c('Max', 'Top3','Top5','MaxNorm','Top3Norm','Top5Norm')
    # Ymax <- c(2^Bits-1,2^Bits-1,2^Bits-1,30,30,30)
    # for (x in 1:length(toPlot)){
    #   gList[[x]] <- plotF(GFP_all, toPlot[x],frames, Ymax[x],TimeRes,toPlot[x])
    # }
    # Grobs <- arrangeGrob(grobs=gList,ncol=3)
    # grid.arrange(Grobs)
    # 
    # dev.off()
    # }
  }
}  
plotF <- function(df, Y, frames,Ymax,TimeRes,Title,...){
  Plot <- ggplot(df,aes_string(y=Y, x='Time',col='Label'))+
    geom_point(size=0.25)+
    #geom_text(aes(label=Label), size=2,vjust = 0, nudge_y = 0)+
    geom_line(size=0.25)+
    #geom_smooth(se=FALSE, span=0.15)+
    scale_x_continuous(limits=c(0,frames*TimeRes/60),breaks =seq(0,frames*TimeRes/60,2), labels=seq(0,frames*TimeRes/60,2))+
    #scale_y_continuous(limits=c(1,6))+
    scale_y_continuous(limits=c(0,Ymax))+
    scale_color_discrete()+
    #scale_colour_manual(values=cols)+
    theme_classic(base_size = 8)+
    # theme(legend.position="none")+
    ggtitle(Title)
  #theme(legend.position="none")
  return(Plot)
}

Run(length(rownames(info)), length(rownames(info)), info, minNumber,'MaxIntensity')
