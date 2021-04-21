---
title: "Alignment and Gene Quantification"
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
render('Module4b_Alignment.Rmd', output_dir = 'site')
--->

<!--- Allow the page to be wider --->
<style>
    body .main-container {
        max-width: 1200px;
    }
</style>

> # Objectives
> * Understand the idea behind splice-aware alignments.
> * Understand the two steps needed to run RSEM+STAR.
> * Understand what SAM/BAM files are.

# Differential Expression Workflow

In this lesson we will discuss the alignment and gene quantification steps which are necessary prior to testing for differential expression, the topic of Day 2.

| Step | Task |
| :--: | ---- |
| 1 | Experimental Design |
| 2 | Biological Samples / Library Preparation |
| 3 | Sequence Reads |
| 4 | Assess Quality of Raw Reads |
| **5** | **Splice-aware Mapping to Genome** |
| **6** | **Count Reads Associated with Genes** |
| 7 | Test for DE Genes |

# Alignment and Gene Quantification

The FASTQ files of raw sequenced reads are untethered from any notion of where they came from in the genome, and which transcribed genes the sequence belongs to. The alignment and gene quantification steps fill in that gap and allow us to proceed with the question we are really interested in: Which genes are differentially expressed between groups of samples?

We will use RSEM ([paper](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-12-323) and [GitHub](https://github.com/deweylab/RSEM)) combined with STAR Aligner ([paper](https://academic.oup.com/bioinformatics/article/29/1/15/272537) and [GitHub](https://github.com/alexdobin/STAR)) to accomplish the task of read mapping and gene quantifcation simultaneously.

## STAR

The "Spliced Transcripts Alignment to a Reference" (STAR) Aligner is aware of splice-sites of transcripts and is able to align reads that span them. The figure below illustrates the difference between splice-unaware aligners (e.g. Bowtie2) and splice-aware aligners (e.g. STAR).

Some benefits of splice-aware aligners include:

* Fewer reads are discarded for lack of alignments, leading to more accurate gene quantification.
* Direct evidence of isoform usage is possible.

We should note that the default parameters for STAR are optimized for **mammalian genomes**.

<center>

![Splice-aware alignmnet](images/splice_aware.png)

Credit: https://raw.githubusercontent.com/hbctraining/Intro-to-rnaseq-hpc-O2/master/lectures/Sequence_alignment.pdf

</center>

## RSEM

RSEM (RNA-seq by Expectation Maximization) determines gene and isoform abundance using an expectation maximization (EM) algorithm to determine the probability that any particular read originated from a particular transcript. From there, gene-level quantification is reported by effectively collapsing the isoform quantifications over all isoforms belonging to the gene.

The primary issue that RSEM attempts to solve is that reads can align to multiple isoforms (when, for example, they share an exon), and that creates ambiguity in deciding which isoform a read gets assigned to for quantification. See the image below for an illustration of this problem.

<center>

![Image of alignment track and gene isoforms](images/Mdm4_locus.png)

</center>

# Running RSEM+STAR

RSEM can be run with just two commands: the first `rsem-prepare-reference` ([manual](https://deweylab.github.io/RSEM/rsem-prepare-reference.html)) builds an index for STAR and RSEM to use, and the second `rsem-calculate-expression` ([manual](https://deweylab.github.io/RSEM/rsem-calculate-expression.html)) does the alignment and gene quantification.

## `rsem-prepare-reference`

 A reference index is essentially a lookup table that speeds up the finding of sequence matches for alignment. In the case of a splice-aware aligner, the reference index is also aware of the various isoforms of genes in the gene model.

To use `rsem-prepare-reference` ([manual](https://deweylab.github.io/RSEM/rsem-prepare-reference.html)) we would need the FASTA sequence for the reference genome, and the gene model in the form of a GTF, as discussed in the previous section.

> **Note**: We will avoid running RSEM+STAR in this workshop because of the computational requirements and our limited Amazon instance. We would also recommend not running it on a personal computer for the same reason.

If we were to have a genome FASTA in hand, call it `GRCm38.fasta` and a GTF in hand, call it `GRCm38.gtf`, then we would create the reference index by calling:

```
$ rsem-prepare-reference --gtf /path/to/GRCm38.gtf \
                         --star \
                         --num-threads 8 \
                         /path/to/GRCm38
                         /desired/path/to/index/GRCm38
```

**Note**, the `/path/to/GRCm38` line is a bit odd in that we might expect to give the path to the genome FASTA file, but `rsem-prepare-reference` only wants the *prefix*, so everything up to the file extension.

The result of `rsem-prepare-reference` is a folder containing files for RSEM and STAR to be able to look up genomic location and gene model information as quickly and efficiently as possible.

## `rsem-calculate-expression`

After preparing the reference index, we can do alignment and quantification with the `rsem-calculate-expression` ([manual](https://deweylab.github.io/RSEM/rsem-calculate-expression.html)) command using the FASTQ reads and the path to the reference index:

```
$ rsem-calculate-expression --star \
                            --num-threads 8 \
                            --star-gzipped-read-file \
                            --star-output-genome-bam \
                            --keep-intermediate-files \
                            --paired-end \
                            /path/to/example_R1.fastq.gz /path/to/example_R2.fastq.gz \
                            /path/to/index/GRCm38
                            /path/to/example
```

RSEM+STAR, with the above options, outputs the following files:

| File | Description |
| ---- | ----------- |
| `example.genome.bam` | The alignments in genomic coordinates. Used for visualization in a gennome browser such as [IGV](https://software.broadinstitute.org/software/igv/). |
| `example.transcript.bam` | The alignments in transcriptomic coordinates. Not used for this workshop. |
| `example.genes.results` | Gene-level results to be used in downstream DE analysis. |
| `example.isoforms.results` | Isoform-level results. Not used for this workshop. |

# Output of RSEM+STAR

The two results we will use most often from RSEM+STAR are the gene-level quantifications (`example.genes.results`) and the alignments in genome-coordinates (`example.genome.bam`). Each sample for which we run RSEM+STAR will have these output files named after the sample.

## Genome Alignments

The `example.genome.bam` alignments file is a special, compressed, version of a SAM file (sequence alignment/map). In order to view it, we have to use a special program called [`samtools`](https://www.htslib.org/doc/samtools.html).

If we were too peek inside of `example.genome.bam`, we would see:

```
$ samtools view ~/workshop_data/rsem_star/example.genome.bam | head -2
NB551521:212:H5L73AFX2:1:11101:16446:1034       0       2       10022660        255     148M    *       0       0       GANAGACAGATATCCTACAAAACACAGAAAGACTAATAAACTCTTATGTTGACTATGAAAGCTGTAAGAAACTTCCAGAAGAAATATTGAAAATGTAGAATAACTGAAGTGTGCTGTGTGTCCATAGCTGTTCTGCTGAGGAAACATT   AA#EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEAEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEAEEEEEEEE<EEEEAEAEEAEA<A<AAAAEEEEEA    NH:i:1  HI:i:1  AS:i:145        NM:i:1  MD:Z:2A145
NB551521:212:H5L73AFX2:1:11101:16366:1035       0       X       48488697        255     146M    *       0       0       TANGTACGCACACAAATTGATCCATACCTTTACTTCCTTTTTTTCCAGCTACTGAATAAGGGGACCTTTCTATTCCTTTGTGTCTCACCATTTTATTGTCTTTCAGAATCTTCACCTGGTCCATTCATTCCTCTACCCTCTCCTGT     AA#EEEEEEEEEEEEEEEEEEEEEEAEEEEEEEEEEEEEEEEEEE<EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE6EEEAEEEEEEEEEEEEEEEEEAEEEEEEEAAEEEE/<E<AA<<<AAAA<AEE      NH:i:1  HI:i:1  AS:i:143        NM:i:1  MD:Z:2G143
```

The [SAM format](https://en.wikipedia.org/wiki/SAM_(file_format)) gives information about where each read maps to in the genome (one read per line), and has information about that mapping.

## Gene-level Quantification

If we were to look at the top 3 lines of `example.genes.results`, we see it is a plain-text file separated by tabs where each row is a gene, and the columns are described the first row. The `genes.results` files for each sample can be directly imported into DESeq2 using the [`tximport`](https://bioconductor.org/packages/release/bioc/vignettes/tximport/inst/doc/tximport.html#rsem) R Bioconductor package. More on this tomorrow.

```
$ head -3 ~/workshop_data/rsem_star/example.genes.results
gene_id                 transcript_id(s)                        length  effective_length        expected_count  TPM     FPKM
ENSMUSG00000000001      ENSMUST00000000001                      3262.00 3116.28                 601.00          45.50   36.70
ENSMUSG00000000003      ENSMUST00000000003,ENSMUST00000114041   799.50  653.78                  0.00            0.00    0.00
```

| Column | Description |
| ---- | ----------- |
| gene_id | The ID from the gene model GTF. |
| transcript_id(s) | The transcript IDs corresponding to the gene in the gene model GTF. |
| length | The weighted average of its transcripts' lengths. |
| effective_length | The weighted average, over its transcripts, of the mean number of positions from which a fragment may start within the sequence of transcript. |
| expected_count | The sum, over all transcripts, of the estimated counts from the EM algorithm. |
| TPM | Transcript per million, a relative measure of transcript abundance where the sum of all TPMs is 1 million. |
| FPKM | Fragments per kilobase of transcript per million mapped reads. |

# Running MultiQC Again

After aligning reads it is often helpful to know how many reads were uniquely aligned, mapped to multiple loci, or not mapped at all. The `exampleLog.final.out` file which is output alongside the alignments in `example.temp/` folder (we used the `--keep-intermediate-files` flag), reports this information:

```
                                 Started job on |	Oct 02 13:09:23
                             Started mapping on |	Oct 02 13:09:51
                                    Finished on |	Oct 02 13:12:47
       Mapping speed, Million of reads per hour |	238.82

                          Number of input reads |	11675504
                      Average input read length |	146
                                    UNIQUE READS:
                   Uniquely mapped reads number |	10609591
                        Uniquely mapped reads % |	90.87%
                          Average mapped length |	146.37
                       Number of splices: Total |	2755543
            Number of splices: Annotated (sjdb) |	2734730
                       Number of splices: GT/AG |	2739697
                       Number of splices: GC/AG |	13204
                       Number of splices: AT/AC |	1744
               Number of splices: Non-canonical |	898
                      Mismatch rate per base, % |	0.18%
                         Deletion rate per base |	0.01%
                        Deletion average length |	1.60
                        Insertion rate per base |	0.01%
                       Insertion average length |	1.29
                             MULTI-MAPPING READS:
        Number of reads mapped to multiple loci |	599915
             % of reads mapped to multiple loci |	5.14%
        Number of reads mapped to too many loci |	12786
             % of reads mapped to too many loci |	0.11%
                                  UNMAPPED READS:
  Number of reads unmapped: too many mismatches |	20381
       % of reads unmapped: too many mismatches |	0.17%
            Number of reads unmapped: too short |	389960
                 % of reads unmapped: too short |	3.34%
                Number of reads unmapped: other |	42871
                     % of reads unmapped: other |	0.37%
                                  CHIMERIC READS:
                       Number of chimeric reads |	0
                            % of chimeric reads |	0.00%
```

If we were to run `multiqc` again, then it would detect these reports and include them. For example:

```
$ multiqc --outdir multiqc_with_alignments .
```

**Note**, since we haven't actually done the alignments we won't call this. Also note the use of `.`, meaning "here". `multiqc` looks for reports it can recognize in the directory you give it, and all its sub-directories. The resulting section will look something like the following:

<center>

![Example of STAR alignment statistics in MultiQC.](images/multiqc_star.png)
Example of STAR alignment statistics in MultiQC.

Source: [MultiQC example report](https://multiqc.info/examples/rna-seq/multiqc_report.html#star)

</center>

---

These materials have been adapted and extended from materials created by the [Harvard Chan Bioinformatics Core (HBC)](http://bioinformatics.sph.harvard.edu/). These are open access materials distributed under the terms of the [Creative Commons Attribution license (CC BY 4.0)](http://creativecommons.org/licenses/by/4.0/), which permits unrestricted use, distribution, and reproduction in any medium, provided the original author and source are credited.
