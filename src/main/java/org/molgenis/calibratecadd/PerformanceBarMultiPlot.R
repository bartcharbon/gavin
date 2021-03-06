library(ggplot2)
library(scales)


#### COLOURS ####
## from: http://www.cookbook-r.com/Graphs/Colors_(ggplot2)/ + lightgray ##
lightgray <- "#cccccc"; gray <- "#999999"; orange <- "#E69F00"; skyblue <- "#56B4E9"; blueishgreen <- "#009E73"
yellow <- "#F0E442"; blue <-"#0072B2"; vermillion <- "#D55E00"; reddishpurple <- "#CC79A7"
cbPalette <- c(gray, orange, skyblue, blueishgreen, yellow, blue, vermillion, reddishpurple)


# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}


# original data sets
#source("/Users/joeri/github/gavin/data/other/step9_out.R")

# CGD panel sets
source("/Users/joeri/github/gavin/data/other/step9_panels_out.R")

#### ADD DERIVED COLUMNS ####
df$TotalToolClsfNonVOUS <- 0
df$TotalExpertClsfNonVOUS <- 0
df$Coverage <- 0
df$MCCadj <- 0
df$Sensitivity <- 0
df$Specificity <- 0
df$PPV <- 0
df$NPV <- 0
df$ACC <- 0
for(i in 1:nrow(df)) {
  df[i,]$TotalToolClsfNonVOUS <- df[i,]$TP+df[i,]$TN+df[i,]$FP+df[i,]$FN
  df[i,]$TotalExpertClsfNonVOUS <- df[i,]$TotalToolClsfNonVOUS + df[i,]$ExpBenignAsVOUS + df[i,]$ExpPathoAsVOUS
  df[i,]$Coverage <- df[i,]$TotalToolClsfNonVOUS / df[i,]$TotalExpertClsfNonVOUS
  df[i,]$MCCadj <- df[i,]$MCC * df[i,]$Coverage
  df[i,]$Sensitivity <- df[i,]$TP/(df[i,]$TP+df[i,]$FN+df[i,]$ExpPathoAsVOUS)
  df[i,]$Specificity <- df[i,]$TN/(df[i,]$TN+df[i,]$FP+df[i,]$ExpBenignAsVOUS)
  df[i,]$PPV <- df[i,]$TP/(df[i,]$TP+df[i,]$FP)
  df[i,]$NPV <- df[i,]$TN/(df[i,]$TN+df[i,]$FN)
  df[i,]$ACC <- (df[i,]$TP+df[i,]$TN)/(df[i,]$TP+df[i,]$TN+df[i,]$FP+df[i,]$FN+df[i,]$ExpPathoAsVOUS+df[i,]$ExpBenignAsVOUS)
}


#stats per tool
stats <- data.frame()
for(i in unique(df$Tool)) {
  df.sub <- subset(df, Tool == i)
  medianSens <- median(df.sub$Sensitivity)
  medianSpec <- median(df.sub$Specificity)
  medianPPV <- median(df.sub$PPV)
  medianNPV <- median(df.sub$NPV)
  row <- data.frame(Tool = i, medianSens = medianSens, medianSpec = medianSpec, medianPPV = medianPPV, medianNPV = medianNPV)
  stats <- rbind(stats, row)
}

#bit pointless but nevertheless: stats per data set (panel)
panelstats <- data.frame()
for(i in unique(df$Data)) {
  df.sub <- subset(df, Data == i)
  medianSens <- median(df.sub$Sensitivity)
  medianSpec <- median(df.sub$Specificity)
  row <- data.frame(Data = i, medianSens = medianSens, medianSpec = medianSpec)
  panelstats <- rbind(panelstats, row)
}


## nice plot
df.notincgd <- subset(df, Data == "NotInCGD")
ggplot() +
  theme_bw() + theme(panel.grid.major = element_line(colour = "black"), axis.text=element_text(size=12),  axis.title=element_text(size=14,face="bold")) +
  geom_point(data = df, aes(x = Sensitivity, y = Specificity, shape = Tool, colour = Tool), size=3, stroke = 3, alpha=0.75) +
  geom_text(data = df, aes(x = Sensitivity, y = Specificity, label = Data), hjust = 0, nudge_x = 0.01, size = 3, check_overlap = TRUE) +
  geom_text(data = df.notincgd , aes(x = Sensitivity, y = Specificity, label = Data), hjust = 0, nudge_x = 0.01, size = 3, colour="red",check_overlap = TRUE) +
  scale_colour_manual(values=rainbow(14)) +
  # scale_colour_manual(values=c(orange, "green", skyblue, "slateblue", yellow, blue, vermillion, reddishpurple, blueishgreen,"red", "blue","brown","orange", gray)) +
  scale_shape_manual(values = c(1, 0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13)) +
  scale_x_continuous(lim=c(0.393,1), breaks = seq(0, 1, by = 0.1)) +
  scale_y_continuous(breaks = seq(0, 1, by = 0.1))

## tiles TPR/TNR
ggplot() +
  geom_tile(data = df, aes(x = Tool, y = Data), fill = "white", colour="black") + 
  theme_bw() +
  geom_tile(data = df, aes(x = Tool, y = Data, fill = Specificity, width = Sensitivity), height= 0.9) +
  geom_text(data = df, aes(x = Tool, y = Data, label = paste("Sens:",percent(Sensitivity),"\nSpec:",percent(Specificity))), colour = "black", size=2.5) +
  scale_fill_gradient(low = "aliceblue", high = "dodgerblue") +
  ylab("CGD manifestation gene panel") +
  xlab("Prediction tool")


## ppv/npv
ggplot() +
  geom_tile(data = df, aes(x = Tool, y = Data), fill = "gray", colour="black") + 
  theme_bw() +
  geom_tile(data = df, aes(x = Tool, y = Data, fill = NPV, width = PPV)) +
  geom_text(data = df, aes(x = Tool, y = Data, label = paste("PPV:",percent(PPV),"\nNPV:",percent(NPV))), colour = "black", size=2.5) +
  scale_fill_gradient(low = "white", high = "steelblue") +
  ylab("CGD manifestation gene panel") +
  xlab("Prediction tool")

# acc
ggplot() +
  geom_tile(data = df, aes(x = Tool, y = Data, fill = ACC)) +
  geom_text(data = df, aes(x = Tool, y = Data, label = percent(ACC)), colour = "black", size=4) +
  scale_fill_gradient(low = "white", high = "steelblue") +
  theme_bw()
  
  

#save
write.table(df, file = "~/gavinbenchmark.tsv",row.names=FALSE, sep="\t")

#plot
labels = c("TN", "VB", "FP", "FN", "VP", "TP");
palette <- c(vermillion, orange, skyblue, blue, lightgray, gray)

#### MULTIPLOT ####
for(i in 1:nrow(df)) {
  dfrow <- df[i,]
  counts = c(dfrow$TN, dfrow$ExpBenignAsVOUS, dfrow$FP, dfrow$FN, dfrow$ExpPathoAsVOUS, dfrow$TP)
  start = c(0,cumsum(counts)); length(start) <- length(start)-1
  stop <- start+counts
  plotdata <- data.frame(start,stop,labels);
  lbl <- paste("MCC[covadj] == ", round(dfrow$Yield, 2))
  plot <- ggplot() + geom_rect(data = plotdata, aes(xmin = start, xmax = stop, ymin = 0, ymax = 1, fill = labels)) + scale_fill_manual(values=palette) + theme(axis.text=element_blank(),rect=element_blank(),line = element_blank(), legend.position="none") +
    annotate("rect", xmin = sum(counts)/2-sum(counts)/4, xmax = sum(counts)/2+sum(counts)/4, ymin = .25, ymax = .75, alpha = .5, fill="white") + theme(axis.title = element_blank()) +
    annotate("text", x = sum(counts)/2, y = 0.5, label = lbl, parse=TRUE) +
    ggtitle(paste(dfrow$Data, "classified by",dfrow$Tool))
  assign(paste(dfrow$Data,dfrow$Tool,"Plot",sep=""), plot)
}

## MULTIPLOT LAYOUT 1
multiplot(
  VariBenchTrainingGAVINPlot, VariBenchTrainingCADDPlot, VariBenchTrainingMSCPlot, VariBenchTrainingPONP2Plot, VariBenchTrainingSIFTPlot, VariBenchTrainingPolyPhen2Plot, VariBenchTrainingPROVEANPlot, VariBenchTrainingCondelPlot, 
  VariBenchTestGAVINPlot, VariBenchTestCADDPlot, VariBenchTestMSCPlot, VariBenchTestPONP2Plot, VariBenchTestSIFTPlot, VariBenchTestPolyPhen2Plot, VariBenchTestPROVEANPlot, VariBenchTestCondelPlot, 
  UMCG_VariousGAVINPlot, UMCG_VariousCADDPlot, UMCG_VariousMSCPlot, UMCG_VariousPONP2Plot, UMCG_VariousSIFTPlot, UMCG_VariousPolyPhen2Plot, UMCG_VariousPROVEANPlot, UMCG_VariousCondelPlot, 
  UMCG_OncoGAVINPlot, UMCG_OncoCADDPlot, UMCG_OncoMSCPlot, UMCG_OncoPONP2Plot, UMCG_OncoSIFTPlot, UMCG_OncoPolyPhen2Plot, UMCG_OncoPROVEANPlot, UMCG_OncoCondelPlot, 
  ClinVarNewGAVINPlot, ClinVarNewCADDPlot, ClinVarNewMSCPlot, ClinVarNewPONP2Plot, ClinVarNewSIFTPlot, ClinVarNewPolyPhen2Plot, ClinVarNewPROVEANPlot, ClinVarNewCondelPlot, 
  MutationTaster2GAVINPlot, MutationTaster2CADDPlot, MutationTaster2MSCPlot, MutationTaster2PONP2Plot, MutationTaster2SIFTPlot, MutationTaster2PolyPhen2Plot, MutationTaster2PROVEANPlot, MutationTaster2CondelPlot, 
  cols=6
)

## MULTIPLOT LAYOUT 2
multiplot(
  UMCG_VariousGAVINPlot, UMCG_VariousCADDPlot, UMCG_VariousMSCPlot, UMCG_VariousPONP2Plot, UMCG_VariousSIFTPlot, UMCG_VariousPolyPhen2Plot, UMCG_VariousPROVEANPlot, UMCG_VariousCondelPlot, 
  UMCG_OncoGAVINPlot, UMCG_OncoCADDPlot, UMCG_OncoMSCPlot, UMCG_OncoPONP2Plot, UMCG_OncoSIFTPlot, UMCG_OncoPolyPhen2Plot, UMCG_OncoPROVEANPlot, UMCG_OncoCondelPlot, 
  ClinVarNewGAVINPlot, ClinVarNewCADDPlot, ClinVarNewMSCPlot, ClinVarNewPONP2Plot, ClinVarNewSIFTPlot, ClinVarNewPolyPhen2Plot, ClinVarNewPROVEANPlot, ClinVarNewCondelPlot, 
  MutationTaster2GAVINPlot, MutationTaster2CADDPlot, MutationTaster2MSCPlot, MutationTaster2PONP2Plot, MutationTaster2SIFTPlot, MutationTaster2PolyPhen2Plot, MutationTaster2PROVEANPlot, MutationTaster2CondelPlot, 
  VariBenchTrainingGAVINPlot, VariBenchTrainingCADDPlot, VariBenchTrainingMSCPlot, VariBenchTrainingPONP2Plot, VariBenchTrainingSIFTPlot, VariBenchTrainingPolyPhen2Plot, VariBenchTrainingPROVEANPlot, VariBenchTrainingCondelPlot, 
  VariBenchTestGAVINPlot, VariBenchTestCADDPlot, VariBenchTestMSCPlot, VariBenchTestPONP2Plot, VariBenchTestSIFTPlot, VariBenchTestPolyPhen2Plot, VariBenchTestPROVEANPlot, VariBenchTestCondelPlot, 
  cols=4, layout = matrix(seq(1, 48), ncol = 4, nrow = 12, byrow=T)
)


# optional: condensed per tool, sum of all data performances
for(i in unique(df$Tool)) {
  dfrow <- subset(df, Tool == i)
  counts = c(sum(dfrow$TN), sum(dfrow$ExpBenignAsVOUS), sum(dfrow$FP), sum(dfrow$FN), sum(dfrow$ExpPathoAsVOUS), sum(dfrow$TP))
  start = c(0,cumsum(counts)); length(start) <- length(start)-1
  stop <- start+counts
  plotdata <- data.frame(start,stop,labels);
  lbl <- paste("MCC[covadj] == ", round(median(dfrow$Yield), 2))
  plot <- ggplot() + geom_rect(data = plotdata, aes(xmin = start, xmax = stop, ymin = 0, ymax = 1, fill = labels)) + scale_fill_manual(values=palette) + theme(axis.text=element_blank(),rect=element_blank(),line = element_blank(), legend.position="none") +
#    annotate("rect", xmin = sum(counts)/2-sum(counts)/4, xmax = sum(counts)/2+sum(counts)/4, ymin = .25, ymax = .75, alpha = .5, fill="white") + theme(axis.title = element_blank()) +
#    annotate("text", x = sum(counts)/2, y = 0.5, label = lbl, parse=TRUE) +
#    annotate("text", x = (sum(counts)/2.25), y = 0.7, label = "median for 6 sets", size=3.5) +
    ggtitle(paste(dfrow$Tool, ", all variants", sep=""))
  assign(paste("AllData",dfrow$Tool,"Plot",sep=""), plot)
}
multiplot(
  AllDataGAVINPlot, AllDataCondelPlot, AllDataMSCPlot, AllDataCADDPlot, AllDataPolyPhen2Plot, AllDataPROVEANPlot, AllDataPONP2Plot, AllDataSIFTPlot, cols=2
)


# "Overall yield per tool across datasets (correlation x coverage)"

#### MCC plot #### ,fill=factor(Type)
yieldbox <- ggplot() + geom_boxplot(data = df, fill = blueishgreen, aes(x = Tool, y = MCC*Coverage)) + theme_classic() + theme(axis.line.x = element_line(), axis.line.y = element_line(), plot.title = element_text(size = 12), axis.text.x = element_text(angle=45, vjust=.5)) + ggtitle(expression(paste("", MCC[covadj], " per tool across datasets")))
mccbox <- ggplot() + geom_boxplot(data = df, fill = yellow , aes(x = Tool, y = MCC)) + theme_classic() + theme(axis.line.x = element_line(), axis.line.y = element_line(), plot.title = element_text(size = 12), axis.text.x = element_text(angle=45, vjust=.5)) + ggtitle("MCC per tool across datasets")
coveragebox <- ggplot() + geom_boxplot(data = df, fill = reddishpurple, aes(x = Tool, y = Coverage)) + theme_classic() + theme(axis.line.x = element_line(), axis.line.y = element_line(), plot.title = element_text(size = 12), axis.text.x = element_text(angle=45, vjust=.5)) + ggtitle("Coverage per tool across datasets")
databox <- ggplot() + geom_boxplot(data = df, fill = "gray70", aes(x = Data, y = MCC*Coverage)) + theme_classic() + theme(axis.line.x = element_line(), axis.line.y = element_line(), plot.title = element_text(size = 12), axis.text.x = element_text(angle=45, vjust=.5)) + scale_x_discrete(breaks=c("UMCG_Onco", "UMCG_Various", "VariBenchTest", "VariBenchTraining", "MutationTaster2", "ClinVarNew"), labels=c("UMCG-Onco", "UMCG-Various", "VB-Test", "VB-Training", "MT2-Test", "ClinVarNew")) + ggtitle(expression(paste("Dataset ", MCC[covadj], " distribution across tools")))
multiplot(yieldbox, coveragebox, mccbox, databox, cols=2)


#### SUBSETS ####
df.gavin <- subset(df, Tool == "GAVIN")
df.cadd <- subset(df, Tool == "CADD")
df.msc <- subset(df, Tool == "MSC")
df.ponp2 <- subset(df, Tool == "PONP2")
df.condel <- subset(df, Tool == "Condel")
df.polyphen2 <- subset(df, Tool == "PolyPhen2")
df.provean <- subset(df, Tool == "PROVEAN")
df.sift <- subset(df, Tool == "SIFT")

df.onco <- subset(df, Data == "UMCG_Onco")
df.various <- subset(df, Data == "UMCG_Various")
df.vbtest <- subset(df, Data == "VariBenchTest")
df.vbtraining <- subset(df, Data == "VariBenchTraining")
df.mt2 <- subset(df, Data == "MutationTaster2")
df.clinvar <- subset(df, Data == "ClinVarNew")

# Yield means per tool across datasets
mean(df.gavin$Yield)
mean(df.cadd$Yield)
mean(df.msc$Yield)
mean(df.ponp2$Yield)
mean(df.condel$Yield)
mean(df.polyphen2$Yield)
mean(df.provean$Yield)
mean(df.sift$Yield)

mean(df.gavin$MCC)
mean(df.cadd$MCC)
mean(df.msc$MCC)
mean(df.ponp2$MCC)
mean(df.condel$MCC)
mean(df.polyphen2$MCC)
mean(df.provean$MCC)
mean(df.sift$MCC)

median(df.gavin$MCC)
median(df.cadd$MCC)
median(df.msc$MCC)
median(df.ponp2$MCC)
median(df.condel$MCC)
median(df.polyphen2$MCC)
median(df.provean$MCC)
median(df.sift$MCC)

median(df.gavin$Yield)
median(df.cadd$Yield)
median(df.msc$Yield)
median(df.ponp2$Yield)
median(df.condel$Yield)
median(df.polyphen2$Yield)
median(df.provean$Yield)
median(df.sift$Yield)



# naive yield vs calibration coverage
nonVousClsfInCalibGenes <- df.gavin$VCG/df.gavin$TotalToolClsfNonVOUS
plot(df.gavin$Yield ~ nonVousClsfInCalibGenes)

# relative yield gain vs calibration coverage
avgYields <- c(mean(df.clinvar$Yield), mean(df.mt2$Yield), mean(df.onco$Yield), mean(df.various$Yield), mean(df.vbtest$Yield), mean(df.vbtraining$Yield))
relYield <- df.gavin$Yield-avgYields
plot(relYield ~ nonVousClsfInCalibGenes)

# LM
lmDat <- lm(relYield ~ nonVousClsfInCalibGenes)
summary(lmDat)$r.squared
lmCoeff <- coef(lmDat)

#ggplot
yieldComp <- data.frame(matrix(c(unlist(nonVousClsfInCalibGenes), unlist(relYield)), nrow=6, ncol=2, byrow=F)) 
colnames(yieldComp) <- c("calibcov", "rel")
plot <- ggplot() + geom_point(data = yieldComp, aes(xmin=0,xmax=1,x = calibcov, y = rel, size=5)) +
  geom_abline(intercept = lmCoeff[1], slope = lmCoeff[2]) +
  theme_bw() +
  theme(legend.position="none", panel.grid.major = element_line(colour = "darkgray"), axis.text=element_text(size=12),  axis.title=element_text(size=14,face="bold")) +
  xlab("Percentage of variants located in calibrated genes") +
  ylab(expression(~MCC[covadj]~"improvement of GAVIN, relative to dataset average for all tools")) +
  ggtitle(expression("Yield improves when genes are calibrated ("~R^{2}~" = 0.40)"))
plot




### bootstrap analysis result processing

df <- read.table("/Users/joeri/github/gavin/data/other/performancebootstrap_output_usedinpaper.r",header=TRUE)
df$Acc <- as.double(as.character(df$Acc))

ggplot() + geom_boxplot(data = df, aes(x = Label, fill = Calib, colour=Tool, y = Acc)) +
  theme_bw() + theme(panel.grid.major = element_line(colour = "black"), axis.text=element_text(size=12),  axis.title=element_text(size=14,face="bold")) +
  ylab("Accuracy") + xlab("GAVIN classification") +
  scale_x_discrete(limits=c("C3_GAVINnocal","C3_GAVIN","C4_GAVINnocal","C4_GAVIN", "C1_C2_GAVINnocal", "C1_C2_GAVIN"),
                   labels = c("C1_C2_GAVIN" = "",
                              "C1_C2_GAVINnocal" = "",
                              "C4_GAVIN" = "", 
                              "C4_GAVINnocal" = "", 
                              "C3_GAVIN" = "",
                              "C3_GAVINnocal"="" )) +
  scale_fill_manual(values=c(blueishgreen, yellow, reddishpurple), 
                    name="Selected gene group",
                    breaks=c("C1_C2", "C4", "C3"),
                    labels=c("CADD predictive genes (520)", "CADD less predictive genes (660)", "Scarce training data genes (737)")) +
  scale_colour_manual(values=c("black", "blue"), name="GAVIN classification", breaks=c("GAVIN", "GAVINnocal"), labels=c("Gene-specific", "Genome-wide")) +
  coord_flip()



# mann-whitney-wilcoxon test and median values
calib <- subset(df, Tool == "GAVIN")
uncalib <- subset(df, Tool == "GAVINnocal")

C1_calib <- subset(calib, Calib == "C1_C2")
C1_uncalib <- subset(uncalib, Calib == "C1_C2")
median(C1_calib$Acc)
median(C1_uncalib$Acc)
wilcox.test(C1_calib$Acc, C1_uncalib$Acc)

C4_calib <- subset(calib, Calib == "C4")
C4_uncalib <- subset(uncalib, Calib == "C4")
median(C4_calib$Acc)
median(C4_uncalib$Acc)
wilcox.test(C4_calib$Acc, C4_uncalib$Acc)

C3_calib <- subset(calib, Calib == "C3")
C3_uncalib <- subset(uncalib, Calib == "C3")
median(C3_calib$Acc)
median(C3_uncalib$Acc)
wilcox.test(C3_calib$Acc, C3_uncalib$Acc)

# bonus: density plot of the same
ggplot() + geom_density(data = df, alpha = 0.5, aes(MCCcovadj, fill = Label, colour = Label)) +
  theme_classic() +
  theme(plot.title = element_text(size = 15)) +
  ggtitle("title")


# bonus: pie-chart gene calibration overview
library(ggplot2)
geneList <- c("Highly predictive (n = 257, pval < 0.01)", "Predictive (n = 263, pval < 0.05)", "Less predictive (n = 660, pval > 0.05)", "Scarce data (n = 737, pval > 0.05 with <5 samples)","'Effect impact predictive' (n = 309)", "Other (n = 829)");
df <- data.frame(
  Genes = geneList,
  value = c(257, 263, 660, 737, 309, 829)
)
df$Genes <- factor(df$Genes, levels = geneList)

bp <- ggplot(df, aes(x="", y=value, fill=Genes)) +
  geom_bar(width = 1, stat = "identity") +
  theme_bw() +
  theme(text = element_text(size = 15), axis.title.y=element_blank(), axis.title.x=element_blank()) +
  theme(legend.text=element_text(size=20), legend.title=element_text(size=25)) + 
  theme(axis.text = element_blank(), axis.ticks = element_blank(), panel.grid  = element_blank()) +
  scale_fill_manual(values=c(blue,skyblue,yellow,orange,blueishgreen,vermillion,reddishpurple)) +
  coord_polar("y", start=0)
bp


