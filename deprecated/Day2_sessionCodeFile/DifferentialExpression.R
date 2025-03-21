# setup directories
dir.create("./RNASeqDemystified")
setwd("./RNASeqDemystified")
getwd()

# make data folder
dir.create("./data")

# download files
download.file("https://raw.githubusercontent.com/umich-brcf-bioinf/2021-04-26-umich-rnaseqDemystified/master/data/Day2Data/SampleInfo_trimmed.csv", "./data/SampleInfo_trimmed.csv")

download.file("https://raw.githubusercontent.com/umich-brcf-bioinf/2021-04-26-umich-rnaseqDemystified/master/data/Day2Data/gene_expected_count_trimmed.txt", "./data/gene_expected_count_trimmed.txt")

# check for packages
missing <- setdiff(c("tidyr", "ggplot2", "pheatmap", "ggrepel", "formattable", "RColorBrewer", "matrixStats", "dplyr", "biomaRt", "DESeq2"), rownames(installed.packages()))
if (!length(missing)) { cat("Ready for Computational Foundations workshop\n")} else {cat("PROBLEM: could not install:", missing, "\n")}
?setdiff

# load packages for today
library(DESeq2)
library(ggplot2)
library(tidyr)
library(matrixStats)
library('ggrepel', character.only=TRUE)
library('pheatmap', character.only=TRUE)
library('RColorBrewer', character.only=TRUE)
?library

?`DESeq2-package`

# load raw count table
?read.table
CountTable <- read.table("./data/gene_expected_count_trimmed.txt", header = TRUE, row.names = 1)
head(CountTable)
tail(CountTable)

# round count table - need whole numbers
?floor
CountTable <- floor(CountTable)
tail(CountTable)

sessionInfo()

# load sample info
MetaInfo <- read.table("~/RNASeqDemystified/data/SampleInfo_trimmed.csv", sep = ",", header = TRUE, row.names = 1)
head(MetaInfo)
str(MetaInfo)

# reorder factors
MetaInfo$Gtype.Tx <- factor(MetaInfo$Gtype.Tx, levels = c( "wt.Tx", "ko.Tx", "ko.control", "wt.control" ))
unique(MetaInfo$Gtype.Tx)

head(CountTable)

# check that counts and sample info match
all(colnames(CountTable) == rownames(MetaInfo))

# Create DESeq2 Dataset
dds <- DESeqDataSetFromMatrix(countData = CountTable, colData = MetaInfo, design = ~ Gtype.Tx)
str(dds)

# filter out very low expressed genes
keep <- rowSums(counts(dds)) >= 10
dds <- dds[keep,]

# create normalized count object
?rlog
rld <- rlog(dds, blind = TRUE)
head(assay(rld), 3)

# fit DESeq2 model
dds <- DESeq(dds)
head(dds)
str(dds)


resultsNames(dds)

# setting up plot directories
dir.create("./Figures")
dir.create("./Figures/BySamples")
getwd()

# Setup plot variables
plotPath <- "./Figures/BySamples/"
Comparison <- "ko.Tx"

# generate PCA projections for top 500 genes
?plotPCA
p.all <- plotPCA(rld, intgroup = c('Gtype.Tx'), ntop = 500)
head(p.all)
p.all

# write out plot to file
pdf(file = paste0(plotPath, 'PCAplot_rlog_', Comparison, '.pdf'), onefile = TRUE)
p.all
dev.off()

# look at results
resultsNames(dds)

# look at Tx ko comparison
Comparison <- "Gtype.Tx_ko.Tx_vs_wt.Tx"  
res_Tx <- results(dds, name=Comparison)

# generate additional contrast
res_WT <- results(dds, contrast=c("Gtype.Tx", "ko.control", "wt.control")) 
head(res_WT)

# set threshold 
fc <- 1.5
pval <- 0.05

# select data of interest
df<- res_WT[order(res_WT$padj),]
df <- as.data.frame(df)
df <- cbind("id" = row.names(df), df)
str(df)

# specify plot variables
Comparison <- "ko.control_v_wt.control"
plotPath = "./Figures/"

# generate volcano plot
p <- ggplot(df, aes(x = log2FoldChange, y = -log10(padj))) + geom_point(shape = 21, fill= 'darkgrey', color= 'darkgrey', size = 1) + theme_classic() + xlab('Log2 fold-change') + ylab('-Log10 adjusted p-value')

p <- p + geom_vline(xintercept = c(0, -log2(fc), log2(fc)), linetype = c(1, 2, 2), color = c('black', 'black', 'black')) + geom_hline(yintercept = -log10(pval), linetype = 2, color = 'black')

p <- p + ggtitle(as.character(Comparison))

p


# summarize DE results
sum(res_WT$padj < 0.05 & abs(res_WT$log2FoldChange) >= log2(1.5), na.rm = TRUE)
# 735 DE genes for ko.control groups

sum(res_Tx$padj < 0.05 & abs(res_Tx$log2FoldChange) >= log2(1.5), na.rm = TRUE)
# 1152 DE genes for ko.tx groups

head(res_WT)











