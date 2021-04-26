---
title: "Day 2 - Module 06: Analysis Setup & Introduction to DESeq2"
author: "UM Bioinformatics Core"
date: "2021-04-25"
output:
        html_document:
            theme: readable
            toc: true
            toc_depth: 4
            toc_float: true
            number_sections: true
            fig_caption: true
            keep_md: true
            markdown: GFM
---

<!--- Allow the page to be wider --->
<style>
    body .main-container {
        max-width: 1200px;
    }
</style>
> # In this module, we will learn:
> * Overview of reproducible research & analysis setup
> * Broad introduction to DESeq2 & why it is widely used for differential expression comparisons
> * How to import and review gene count table

# Differential Expression Workflow

Today we will proceed from a count table similar to what was generated yesterday through key steps in a differential expression analysis. 

| Step | Task |
| :--: | ---- |
| 1 | Experimental Design |
| 2 | Biological Samples / Library Preparation |
| 3 | Sequence Reads |
| 4 | Assess Quality of Raw Reads |
| 5 | Splice-aware Mapping to Genome |
| 6 | Count Reads Associated with Genes |
| **7** | **Organize project files locally** |
| **8** | **Initialize DESeq2 and fit DESeq2 model** |
| 9 | Assess expression variance within treatment groups |
| 10 | Specify pairwise comparisons and test for differential expression |
| 11 | Generate summary figures for comparisons |
| 12 | Annotate differential expression result tables |

---

# Reproducible Research

We'll be exploring some RNA-seq data that is fairly representative of what we see in the core and start with input files similar to what would have been generated by the full alignment process that was introduced yesterday and similar to the count tables currently being delivered by the Advanced Sequencing Core.

To get started, we'll open up our RStudio console and set up for our analysis.
![](./images/Rstudio_example.png)


## Best practices for file organization

To follow best practices as discussed by [Nobel, 2009](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1000424) for file organization for bioinformatics/computational projects, we will need to make sure there are separate storage locations for:    
* Raw data    
* Code    
* Output files       

![](./images/Noble2009_dataprojects.png)    

To organize our files for our analysis today we'll create a new folder, ideally in our home directory, using the 'New Folder' button on the right side of our screen & naming it `RNASeqDemystified`.           

Next, we'll set our working directory and create a new subdirectory within `RNASeqDemystified` called `data`.

```r
## alternative command
# system("mkdir ./RNASeqDemystified")

dir.create("./RNASeqDemystified")
```

```
## Warning in dir.create("./RNASeqDemystified"): './RNASeqDemystified' already
## exists
```

```r
#setwd("~/RNASeqDemystified")
getwd()
```

```
## [1] "/Users/damki/repos/rnaseq_demystified_workshop_2021"
```
**Checkpoint**: *Please use the red x if you are not in your own 'RNASeqDemystified' directory after executing these commands*

Once we confirm our working directory, we'll create a new folder to store our raw data.

```r
## alternative command
# system("mkdir ./data")

dir.create("./RNASeqDemystified/data")
```

```
## Warning in dir.create("./RNASeqDemystified/data"): './RNASeqDemystified/data'
## already exists
```

**TODO: Confirm/test URL for download of new input files... currently on unmerged branch of repo**

Next, we'll download the files we'll need for today.

```r
download.file("https://raw.githubusercontent.com/umich-brcf-bioinf/rnaseq_demystified_workshop_2021/DMK_changes/data/Day2Data/SampleInfo_trimmed.csv", "./RNASeqDemystified/data/SampleInfo_trimmed.csv")

download.file("https://raw.githubusercontent.com/umich-brcf-bioinf/rnaseq_demystified_workshop_2021/DMK_changes/data/Day2Data/gene_expected_count_trimmed.txt", "./RNASeqDemystified/data/gene_expected_count_trimmed.txt")
```


**Checkpoint**: *Please use the 'raise hand' button if you are having issues with downloading the data, or if you don't see the files after clicking on the "data" directory, like shown below to be placed in a breakout room for help. If you have successfully downloaded the data then used the green 'yes' button*

![Working directory and data folder structure](./images/DirectoryWithData.png)


# Setting up our analysis

Next, we'll open a new '.R' script file by using the toolbar at the top of our window. We'll save our 'Untitled1' file as "RNASeqAnalysis". This new "RNASeqAnalysis.R" will serve as a record of our analysis and, following best practices, is saved in a separate location from our raw data. 

This code file can also serve as a 'cheatsheet' of commands to use for working through differential expression comparisons with other example datasets or your own data in the future.

*Another note is that there are several bonus content sections on the instruction pages, like the two below that we will not be covering in this workshop, but that may have useful context or be helpful when you review this material*

<details>
    <summary>*Click for code execution shortcut reminder*</summary>
    **Ctrl-Enter** is a standard shortcut in Rstudio to send the current line (or selected lines) to the console. If you see an `>`, then R has executed the command. If you see a `+`, this means that the command is not complete and R is waiting (usually for a `)`).
</details>


<details>
    <summary>*Click for review of R conventions for object names*</summary>
    R has some restrictions for naming objects:   
    * Cannot start with numbers   
    * Cannot include dashes   
    * Cannot have spaces   
    * Should not be identical to a named function   
    * Dots & underscores will work but are better to avoid   
</details>

## Check package installations

You should already have several  packages installed, so we can load them into our R session now. To do that we'll use the `library` function to load the required packages.


```r
library(DESeq2)
library(ggplot2)
library(tidyr)
library(matrixStats)
library('ggrepel', character.only=TRUE)
library('pheatmap', character.only=TRUE)
library('RColorBrewer', character.only=TRUE)
```


*Note: Expect to see some messages in your console while these packages are loading*

As discussed in the computation foundations/prerequsite sessions, R/RStudio has great resources for getting help, including [code 'cheatsheets'](https://www.rstudio.com/wp-content/uploads/2016/10/r-cheat-sheet-3.pdf) and package vignettes, like for [tidyr](https://cran.r-project.org/web/packages/tidyr/vignettes/tidy-data.html).

**Checkpoint**: *Please use the 'red x' button if you need help loading your libraries*

# Tools for Differential Gene Expression analysis

As discussed during the seminar, a common application for bulk RNA-seq is to test for differential expression between conditions or treatments, using statistical approaches that are appropriate for biological data.

While there are several tools that can be used for differential expression comparisons, we use [DESeq2](https://bioconductor.org/packages/release/bioc/html/DESeq2.html) in our analysis today. DESeq2 is one of two tools, along with [EdgeR](https://bioconductor.org/packages/release/bioc/html/edgeR.html), considered ['best practice'](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-14-91) for differential expression, as both tools apply similar methods that account for the distributions we expect to see for RNA-seq and are fairly stringent in calling differentially expressed genes.

Additionally, `DESeq2` also has an
[this excellent vignette](https://bioconductor.org/packages/release/bioc/vignettes/DESeq2/inst/doc/DESeq2.html) *click to open*
from Love, Anders, and Huber from which our workflow is partially adapted and is a good resource when analyzing your own data
(see also: [Love, Anders, and Huber. _Genome Biology_. 2014.](https://doi.org/10.1186/s13059-014-0550-8)).


<details>
    <summary>*Click for additional resources regarding statistical testing and tool comparison for RNA-seq data*</summary>
    To learn more about statistical testing and what distributions best model the behavior of RNA-seq data, a good resource is this [EdX lecture by Rafael Irizarry](https://www.youtube.com/watch?v=HK7WKsL3c2w&feature=youtu.be) or this [lecture by Kasper Hansen](https://www.youtube.com/watch?v=C8RNvWu7pAw). Another helpful guide is this [Comparative Study for Differential Expression Analysis by Zhang et al.](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0103207) from 2014. 
</details>

We previously loaded several libraries into our R session, we can check the tools documentation out using the `?` operator.

```r
?`DESeq2-package`
```

**Checkpoint**: *If you see the R documentation for `DESeq2` pop up in your 'help' panel on the right, please indicate with the green 'yes' button. Please use the 'raise hand' button, if you see this message `No documentation for 'DESeq2-package' in specified packages and libraries` to be placed in a breakout room for help*

## DESeq2 assumptions and requirements

A key assumption is that since a vast number of RNAs are represented in each sample, the probability of counting a particular transcript is small. In addition, we expect that the mean expression of any given gene is less than the variance (or spread) of expression across different samples.

For most experiments biological variance is much greater than technical variance, especially if [best practices](https://www.txgen.tamu.edu/faq/rna-isolation-best-practices/) for [quality RNA isolation](https://www.biocompare.com/Bench-Tips/128790-Four-Tips-for-Perfecting-RNA-Isolation/) are followed (including DNase treatment!).

<details>
    <summary>*Click for statistical thinking around RNA-seq data & replicates with cell lines*</summary>
    For a walk through of mean versus variance in RNA-seq data, this [blog post by David Tang](https://davetang.org/muse/2012/04/14/variance-in-rna-seq-data/) has a nice practical walk through. A more technical talk by Gordon Smyth is summarized in this [blog post by Peter Hicky](https://www.peterhickey.org/2011/11/23/bioinf-seminar-gordon-smyth/) and described in detail in [Symth's voom paper](https://genomebiology.biomedcentral.com/articles/10.1186/gb-2014-15-2-r29)
    **Note**: If you are working with cell lines and would like more detail about replicates for *in vitro* studies, this [archived page](https://web-archive-org.proxy.lib.umich.edu/web/20170807192514/http://www.labstats.net:80/articles/cell_culture_n.html) could be helpful.
</details>    



Since variance is key to the statistical approach used for DESeq2, if you try to compare treatment groups with less than **two** replicates, DESeq2 will give you an error, as shown in [this blog post](https://support.bioconductor.org/p/89746/). Without replicates, statistical significance (i.e. p-values) cannot be calculated, but qualitative approaches like looking at the top expressed genes after normalization are an option.

### Replicates in RNA-seq experiments

A question we are frequently asked is "How many replicates do I need?" As mentioned in the seminar, there is often more contributing to the observed gene expression in each sample than the experimental treatment or condition.


![Above: Image of technical, biological, and experimental contributors to gene expression, from HBC training materials](./images/de_variation.png)
   
The general goal of differential expression analysis to seperate the “interesting” biological contributions from the “uninteresting” technical or extraneous contributions that either cannot be or were not controlled in the experimental design. The more sources of variation, such as samples coming from heterogenous tissues or experiments with incomplete knockdowns, the more replicates (>3) are recommended.  

For a more in depth discussion of experimental design considerations, particularly for the number of replicates, please review [Koch et al.](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6096346/) and these papers, like this one by [Hart et al.](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3842884/) that focus on estimating statistical power for RNA-seq experiments.

#### Sequencing depth recommendations 

A related aspect to consider for experimental design is how much sequencing depth should be generated per sample. This figure shared by Illumina in their technical talks is helpful to understand the relative importance of sequencing depth versus number of replicates.


![Illumina's differential expression recovery across replicate number and sequencing depth](./images/de_replicates_img.png)

Generally, for the human and mouse genomes, the general recommendation is 30-40 million reads per sample if measuring the ~20,000  protein-coding genes (i.e.: polyA library prep) to capture both highly expressed (common) and more lowly expresssed (rarer) transcripts. However, as the image above shows, sequencing depth has less of an impact in detecting differentially expressed genes (DEGs) than number of replicates.

### Raw data as input

Another key assumption for DESeq2 is that the analysis will start with [un-normalized counts](http://bioconductor.org/packages/devel/bioc/vignettes/DESeq2/inst/doc/DESeq2.html#why-un-normalized-counts).

To begin our analysis, we'll read in the **raw** count data file, `gene_expected_count_trimmed.txt` which is similar to what would be generated in the alignment steps yesterday (and what you could receive from AGC). We'll discuss later a few normalizations that can be helpful for us to understand how much a gene is expressed within or between samples, but normalized data **should not** be used as an input for DESeq2.


```r
CountTable <- read.table("./RNASeqDemystified/data/gene_expected_count_trimmed.txt", header = TRUE, row.names = 1)
head(CountTable) # look at the top of the table
```

```
##                    Sample_116498 Sample_116499 Sample_116500 Sample_116501
## ENSMUSG00000000001          8256          6680          7532          5122
## ENSMUSG00000000003             0             0             0             0
## ENSMUSG00000000028           226           244           199           193
## ENSMUSG00000000031             1             2             2             0
## ENSMUSG00000000037            29            11            22            16
## ENSMUSG00000000049             0             0             1             8
##                    Sample_116502 Sample_116503 Sample_116504 Sample_116505
## ENSMUSG00000000001          6684          8047          6446          5559
## ENSMUSG00000000003             0             0             0             0
## ENSMUSG00000000028           293           382          2297          2138
## ENSMUSG00000000031             2             0             9             5
## ENSMUSG00000000037            13            15            32            51
## ENSMUSG00000000049             4             2             2             0
##                    Sample_116506 Sample_116507 Sample_116508 Sample_116509
## ENSMUSG00000000001          5443          5906          5771          4792
## ENSMUSG00000000003             0             0             0             0
## ENSMUSG00000000028          2344          2357          2531          2225
## ENSMUSG00000000031             2             1             8            12
## ENSMUSG00000000037            54            28            25            31
## ENSMUSG00000000049             3             4             1             0
```

Now that the file is read into R, note that we've created a data frame that includes 'gene ids' in ENSEMBL format as rownames and count data from twelve different samples.

If we think back to the 'expected_counts' RSEM output, the values in the count table are likely *not* integers (due to how the alignment tool resolves reads that map to multiple locuses). Since DESeq2 requires whole numbers, if we try to use the RSEM ouputs without rounding the estimated counts to a whole number first, DESeq2 will give us an error. To resolve this, we'll round down all the columns of our `CountTable` that include count data (all columns since we set the gene names to be our row names).

```r
tail(CountTable) # not all whole numbers
```

```
##                    Sample_116498 Sample_116499 Sample_116500 Sample_116501
## ENSMUSG00000118573          1.76          0.00          0.00          0.00
## ENSMUSG00000118574          0.00          0.00          0.00          0.00
## ENSMUSG00000118575          0.00          0.00          0.00          0.00
## ENSMUSG00000118576          3.00          0.00          1.00          1.00
## ENSMUSG00000118577        752.33        613.24        417.04        412.63
## ENSMUSG00000118578         34.49         20.58         12.10         14.88
##                    Sample_116502 Sample_116503 Sample_116504 Sample_116505
## ENSMUSG00000118573          0.00          0.00          0.00          2.29
## ENSMUSG00000118574          0.00          0.00          0.00          0.00
## ENSMUSG00000118575          0.00          0.00          0.00          0.00
## ENSMUSG00000118576          1.00          5.00          3.00          1.00
## ENSMUSG00000118577        429.74        553.50        479.16        825.36
## ENSMUSG00000118578         14.05         34.62         18.57         14.01
##                    Sample_116506 Sample_116507 Sample_116508 Sample_116509
## ENSMUSG00000118573          0.00          0.00          0.43          0.71
## ENSMUSG00000118574          0.00          0.00          0.00          0.00
## ENSMUSG00000118575          0.00          0.00          0.00          0.00
## ENSMUSG00000118576          2.00          0.00          0.00          2.00
## ENSMUSG00000118577        520.06        383.61        404.31        353.35
## ENSMUSG00000118578         11.14          4.69         11.81          7.74
```

```r
CountTable <- floor(CountTable)
tail(CountTable) # now whole numbers
```

```
##                    Sample_116498 Sample_116499 Sample_116500 Sample_116501
## ENSMUSG00000118573             1             0             0             0
## ENSMUSG00000118574             0             0             0             0
## ENSMUSG00000118575             0             0             0             0
## ENSMUSG00000118576             3             0             1             1
## ENSMUSG00000118577           752           613           417           412
## ENSMUSG00000118578            34            20            12            14
##                    Sample_116502 Sample_116503 Sample_116504 Sample_116505
## ENSMUSG00000118573             0             0             0             2
## ENSMUSG00000118574             0             0             0             0
## ENSMUSG00000118575             0             0             0             0
## ENSMUSG00000118576             1             5             3             1
## ENSMUSG00000118577           429           553           479           825
## ENSMUSG00000118578            14            34            18            14
##                    Sample_116506 Sample_116507 Sample_116508 Sample_116509
## ENSMUSG00000118573             0             0             0             0
## ENSMUSG00000118574             0             0             0             0
## ENSMUSG00000118575             0             0             0             0
## ENSMUSG00000118576             2             0             0             2
## ENSMUSG00000118577           520           383           404           353
## ENSMUSG00000118578            11             4            11             7
```
    

<details>
    <summary>*Click for alternative DESeq2 input options for RSEM outputs*</summary>
    The package `tximport` is another option[recommended the DESeq2  authors](https://support.bioconductor.org/p/90672/) to read in the RSEM expected_counts, as this  package allows for the average transcript length per gene to be used in the DE analysis and, as [described by the author](https://support.bioconductor.org/p/88763/), the `tximport-to-DESeqDataSet` constructor function round the non-integer data generated by RSEM to whole numbers.
</details>
    
<details>
    <summary>*Click for comparison of RNA-seq data and microarray data*</summary>
    With [higher sensitivity, greater flexiblity, and decreasing cost](https://www.illumina.com/science/technology/next-generation-sequencing/microarray-rna-seq-comparison.html), sequencing has largely replaced microarray assays for measuring gene expression. A key difference between the platforms is that microarrays measure intensities and are therefore *continous* data while the count data from sequencing is *discrete*. A more detailed comparison between microarrays and sequencing technologies/analysis is outlined in [the online materials for Penn State's STAT555 course](https://online.stat.psu.edu/stat555/node/30/)
</details>   
     

Now that we have our count data processed, we can move on to "unblinding" our data, as the sample names are unique identifiers generated by a sequencing center and not very informative as far as our experimental conditions.

---

# Sources
## Training resources used to develop materials
* HBC DGE setup: https://hbctraining.github.io/DGE_workshop/lessons/01_DGE_setup_and_overview.html   
* HBC Count Normalization: https://hbctraining.github.io/DGE_workshop/lessons/02_DGE_count_normalization.html   
* DESeq2 standard vignette: http://bioconductor.org/packages/devel/bioc/vignettes/DESeq2/inst/doc/DESeq2.html   
* DESeq2 beginners vignette: https://bioc.ism.ac.jp/packages/2.14/bioc/vignettes/DESeq2/inst/doc/beginner.pdf   
* Bioconductor RNA-seq Workflows: https://www.bioconductor.org/help/course-materials/2015/LearnBioconductorFeb2015/B02.1_RNASeq.html   
* CCDL Gastric cancer training materials: https://alexslemonade.github.io/training-modules/RNA-seq/03-gastric_cancer_exploratory.nb.html
* CCDL Neuroblastoma training materials: https://alexslemonade.github.io/training-modules/RNA-seq/05-nb_cell_line_DESeq2.nb.html




---

These materials have been adapted and extended from materials listed above. These are open access materials distributed under the terms of the [Creative Commons Attribution license (CC BY 4.0)](http://creativecommons.org/licenses/by/4.0/), which permits unrestricted use, distribution, and reproduction in any medium, provided the original author and source are credited.