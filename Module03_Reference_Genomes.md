---
title: "Reference Genomes"
author: "UM Bioinformatics Core"
date: "`r Sys.Date()`"
output:
    html_document:
        theme: readable
        toc: true
        toc_depth: 4
        toc_float: true
        number_sections: true
        fig_caption: true
        keep_md: false
---

<!---
library(rmarkdown)
render('Module4a_Reference_Genomes.Rmd', output_dir = 'site')
--->

<!--- Allow the page to be wider --->
<style>
    body .main-container {
        max-width: 1200px;
    }
</style>

> # Objectives
> * Understand what a reference genome is and what it contains.
> * Understand the FASTA and GTF formats.
> * Appreciate the differences in gene identifiers.
> * Understand how to download a reference genome.

# Differential Expression Workflow

In this lesson we will set the stage for steps 5 and 6 by discussing reference genomes, which are integral to genome alignments and gene/isoform quantification. Along the way we will touch on some quirks to be aware of.

| Step | Task |
| :--: | ---- |
| 1 | Experimental Design |
| 2 | Biological Samples / Library Preparation |
| 3 | Sequence Reads |
| 4 | Assess Quality of Raw Reads |
| **5** | **Splice-aware Mapping to Genome** |
| **6** | **Count Reads Associated with Genes** |
| 7 | Test for DE Genes |

# Reference Genomes

A reference genome consists of the **reference sequence** and, optionally, any number of **genomic annotations** that describe attributes about that sequence. Examples of annotations include:

* Gene models consisting of the location and other information about genes.
* Variants consisting of the location of common or rare genetic variants, their alleles, and frequencies.
* Small RNAs consisting of the location and other information about various types of small RNAs.

Of particular relevance to us for this workshop are the reference sequence and gene models.

## Reference Sequence

Reference sequence is stored in [FASTA](https://en.wikipedia.org/wiki/FASTA_format) files. They are similar to FASTQ files in their storage of sequence information, but their format is a little different in a couple ways:

1. Records are separated by lines beginning with `>` instead of `@`.
2. Only the sequence is stored in a FASTA file, there is no notion of quality attached to the nucleotides.

```
>chrM
GATCACAGGTCTATCACCCTATTAACCACTCACGGGAGCTCTCCATGCAT
TTGGTATTTTCGTCTGGGGGGTGTGCACGCGATAGCATTGCGAGACGCTG
GAGCCGGAGCACCCTATGTCGCAGTATCTGTCTTTGATTCCTGCCTCATT
CTATTATTTATCGCACCTACGTTCAATATTACAGGCGAACATACCTACTA
AAGTGTGTTAATTAATTAATGCTTGTAGGACATAATAATAACAATTGAAT
GTCTGCACAGCCGCTTTCCACACAGACATCATAACAAAAAATTTCCACCA
AACCCCCCCCTCCCCCCGCTTCTGGCCACAGCACTTAAACACATCTCTGC
CAAACCCCAAAAACAAAGAACCCTAACACCAGCCTAACCAGATTTCAAAT
TTTATCTTTAGGCGGTATGCACTTTTAACAGTCACCCCCCAACTAACACA
```

## Gene Models

Well-characterized organisms (e.g. human, mouse, zebrafish) have fairly mature gene models. These are stored in [GTF](https://uswest.ensembl.org/info/website/upload/gff.html) format, which gives location and other information about each gene feature. Below are two examples:

```
chr1	unknown	exon	11874	12227	.	+	.	gene_id "DDX11L1"; gene_name "DDX11L1"; transcript_id "NR_046018"; tss_id "TSS16932";
chr1	unknown	exon	12613	12721	.	+	.	gene_id "DDX11L1"; gene_name "DDX11L1"; transcript_id "NR_046018"; tss_id "TSS16932";
chr1	unknown	exon	13221	14409	.	+	.	gene_id "DDX11L1"; gene_name "DDX11L1"; transcript_id "NR_046018"; tss_id "TSS16932";
chr1	unknown	exon	14362	14829	.	-	.	gene_id "WASH7P"; gene_name "WASH7P"; transcript_id "NR_024540"; tss_id "TSS8568";
```

```
1	havana	gene	11869	14409	.	+	.	gene_id "ENSG00000223972"; gene_version "5"; gene_name "DDX11L1"; gene_source "havana"; gene_biotype "transcribed_unprocessed_pseudogene";
1	havana	transcript	11869	14409	.	+	.	gene_id "ENSG00000223972"; gene_version "5"; transcript_id "ENST00000456328"; transcript_version "2"; gene_name "DDX11L1"; gene_source "havana"; gene_biotype "transcribed_unprocessed_pseudogene"; transcript_name "DDX11L1-202"; transcript_source "havana"; transcript_biotype "lncRNA"; tag "basic"; transcript_support_level "1";
1	havana	exon	11869	12227	.	+	.	gene_id "ENSG00000223972"; gene_version "5"; transcript_id "ENST00000456328"; transcript_version "2"; exon_number "1"; gene_name "DDX11L1"; gene_source "havana"; gene_biotype "transcribed_unprocessed_pseudogene"; transcript_name "DDX11L1-202"; transcript_source "havana"; transcript_biotype "lncRNA"; exon_id "ENSE00002234944"; exon_version "1"; tag "basic"; transcript_support_level "1";
```

The GTF format stores specific information in each column:

| Column | Description |
| :----: | ----------- |
| 1 | Chromosome |
| 2 | Source, e.g. ensembl, havana |
| 3 | Gene feature, e.g. exon, intron, mRNA, transcript |
| 4 | Start location, 1-based |
| 5 | End location, 1-based |
| 6 | Score |
| 7 | Strand |
| 8 | Frame, relating to codons |
| 9 | Attribute, a semicolon separated list of key/value pairs giving additional information about the feature. |

## Minutiae, Very Briefly

Bioinformatics is a relatively new, fast-changing, field and its data standards and formats are no different. Consequently there are some oddities and tedious items of note which we would like to only briefly touch on here.

### Genome Builds

On occassion new reference genomes are released, and the genome build number changes. You may be familiar with the UCSC manner of naming human genome builds: hg18, hg19, hg38. ENSEMBL, naturally, has their own way of referring to genome builds: GRCh36, GRCh37, and GRCh38. Notice with the most recent human reference, the numbering now aligns between UCSC and ENSEMBL.

Different organisms have their own versioning.

### Annotation Sources

[NCBI RefSeq](https://www.ncbi.nlm.nih.gov/refseq/rsg/), [ENSEMBL](https://www.ensembl.org/info/genome/genebuild/index.html), and [UCSC Known Genes](https://academic.oup.com/bioinformatics/article/22/9/1036/200093) are the three primary gene annotation databases (different organisms have their own databases). We will not go into exactly how the gene annotations are different, but we note that the are, and [others have examined the consequences of this](https://bmcgenomics.biomedcentral.com/articles/10.1186/s12864-015-1308-8).

### Gene IDs

The two GTF examples above highlight different ways of referring to the same gene. In the first GTF we see:

* DDX11L1, the gene symbol, controlled by the [Human Gene Nomenclature Committee (HUGO)](https://www.genenames.org/).
* NR_046018, the RefSeq transcript ID

And in the second GTF we see:

* ENSG00000223972, the ENSEMBL gene ID
* DDX11L1, the gene symbol, thankfully the same
* ENST00000456328, the ENSEMBL transcript ID

Translating between different gene IDs is possible, as we will see in Day Two with `biomaRt`. But in terms of **best practice** it is generally a good idea to avoid using the gene symbol as the primary gene identifier because not everyone refers to the same gene by the same symbol.

# Getting a Reference Genome

The [Illumina iGenomes](https://support.illumina.com/sequencing/sequencing_software/igenome.html) resource is one of the easiest, and most comprehensive, ways to download a reference genome. iGenomes includes both the reference sequence and gene models.

Reference genomes can be **very large**, depending on the organism, and so we will not download one to the Amazon instance we are using for this workshop. It is not advised to download these references to your personal computer either. Instead, these should be downloaded on the server where you intend to do the RNA-seq analysis (your lab's or Great Lakes).

To do that, you would go to the [iGenomes](https://support.illumina.com/sequencing/sequencing_software/igenome.html) page, find the build you want from the source you want, right click the genome build you want to download, and select "Copy link location":

![iGenomes image for copying link location](images/genome_copy_link.png)

Then on the remote server you would go to the directory you'd like to download the genome to and type (that URL is what we copied):

```
$ wget http://igenomes.illumina.com.s3-website-us-east-1.amazonaws.com/Homo_sapiens/NCBI/GRCh38/Homo_sapiens_NCBI_GRCh38.tar.gz
```

After the download finishes (it may take a while as it is tens of GB large), you can unpack it with:

```
$ tar -xf Homo_sapiens_NCBI_GRCh38.tar.gz
```

## Which Reference is Right for Me?

The key is to be consistent in your research. Switching from ENSEMBL to UCSC will create many headaches because of the change in gene identifiers, and differences in the gene models themselves. Often people choose the one they're most comfortable with, which is often a function of historical accident. The key is not to overthink it.

Another important note is not to mix the sources. If you download reference sequence from UCSC, don't use an ENSEMBL GTF (and vice versa). One of the quirky differences between the two databases is that ENSEMBL refers to chromosome only by their number, i.e. `1`, whereas UCSC refers to chromsomes as `chr1`. This makes reference FASTAs from one source incompatible with gene builds from another.

---

These materials have been adapted and extended from materials created by the [Harvard Chan Bioinformatics Core (HBC)](http://bioinformatics.sph.harvard.edu/). These are open access materials distributed under the terms of the [Creative Commons Attribution license (CC BY 4.0)](http://creativecommons.org/licenses/by/4.0/), which permits unrestricted use, distribution, and reproduction in any medium, provided the original author and source are credited.
