# More QC - Cutadapt and MultiQC

In this module we will learn:
* about the cutadapt software and its uses
* how to use the cutadapt tool for trimming adapters
* how to trim all of our samples in a for-loop
* about the MultiQC tool and its capabilities
* how to run multiQC on a remote system, transfer and view the reports locally

# Differential Expression Workflow

As a reminder, our overall differential expression workflow is shown below. In this lesson, we will go over the bold part of the workflow.

| Step | Task |
| :--: | ---- |
| 1 | Experimental Design |
| 2 | Biological Samples / Library Preparation |
| 3 | Sequence Reads |
| **4** | **Assess Quality of Reads** |
| 5 | Splice-aware Mapping to Genome |
| 6 | Count Reads Associated with Genes |
| 7 | Test for DE Genes |

## Cutadapt

[Cutadapt](https://cutadapt.readthedocs.io/en/stable/) is a very widely used read trimming and fastq processing software, cited several thousands of times. It's written in python, and is user-friendly and reasonably fast.

It is used for removing adapter sequences, primers, and poly-A tails, for trimming based on quality thresholds, for filtering reads based on characteristics, etc.

It can operate on both FASTA and FASTQ file formats, and it supports compressed or raw inputs and outputs.

Notably, cutadapt's error-tolerant adapter trimming likely contributed greatly to its early popularity. We will use it to trim the adapters from our reads. As usual, we'll view the help page to get a sense for how to structure our command.

<br>
<br>
<br>
<br>

Cutadapt Exercise:

1. View the help page of the cutadapt tool
2. Construct a cutadapt command to trim the adapters from paired-end reads
3. View the output of cutadapt, and verify that it's correct
4. Construct commands to trim the reads for all of our samples

<details>
<summary>Click here for solution - cutadapt exercise</summary>

1. View cutadapt help page

        cutadapt --help | less
        # Will need to type `q` to exit from `less`

2. Trim the adapters from sample_01 with cutadapt

        SAMPLE=sample_01
        cutadapt -a AGATCGGAAGAG -A AGATCGGAAGAG -o ~/analysis/out_trimmed/${SAMPLE}_R1.trimmed.fastq.gz -p ~/analysis/out_trimmed/${SAMPLE}_R2.trimmed.fastq.gz ~/data/reads/${SAMPLE}_R1.fastq.gz ~/data/reads/${SAMPLE}_R2.fastq.gz

3. View cutadapt output

        ls -l ~/analysis/out_trimmed

4. Construct commands to trim the reads for all of our samples

Note: We're re-using the same command. We can update `$SAMPLE`, then press 'up' to re-run cutadapt command with newly defined variable.

        SAMPLE=sample_02
        cutadapt -a AGATCGGAAGAG -A AGATCGGAAGAG -o ~/analysis/out_trimmed/${SAMPLE}_R1.trimmed.fastq.gz -p ~/analysis/out_trimmed/${SAMPLE}_R2.trimmed.fastq.gz ~/data/reads/${SAMPLE}_R1.fastq.gz ~/data/reads/${SAMPLE}_R2.fastq.gz

        SAMPLE=sample_03
        cutadapt -a AGATCGGAAGAG -A AGATCGGAAGAG -o ~/analysis/out_trimmed/${SAMPLE}_R1.trimmed.fastq.gz -p ~/analysis/out_trimmed/${SAMPLE}_R2.trimmed.fastq.gz ~/data/reads/${SAMPLE}_R1.fastq.gz ~/data/reads/${SAMPLE}_R2.fastq.gz

        SAMPLE=sample_04
        cutadapt -a AGATCGGAAGAG -A AGATCGGAAGAG -o ~/analysis/out_trimmed/${SAMPLE}_R1.trimmed.fastq.gz -p ~/analysis/out_trimmed/${SAMPLE}_R2.trimmed.fastq.gz ~/data/reads/${SAMPLE}_R1.fastq.gz ~/data/reads/${SAMPLE}_R2.fastq.gz


</details>

<br>
<br>
<br>
<br>

## Re-running FastQC

Now that we've run cutadapt and trimmed the adapters from our reads, we will quickly re-run FastQC on these trimmed read FASTQs. This will confirm that we've successfully trimmed the adapters, and we'll see that our FASTQ files are ready for sequencing.

Re-running FastQC Exercise:

1. Create directory for new fastqc results
2. Construct and execute FastQC command to evaluate trimmed read FASTQ files
3. View the output (filenames)


<details>
<summary>Click here for solution - re-running FastQC exercise</summary>

1. Create directory for new fastqc results

        mkdir ~/analysis/out_fastqc_trimmed

2. FastQC command to evaluate trimmed FASTQ files

        fastqc -o ~/analysis/out_fastqc_trimmed ~/analysis/out_trimmed/*.fastq.gz


</details>

<br>
<br>
<br>
<br>

# MultiQC

FastQC is an excellent tool, but it can be tedious to look at the report for each sample separately, while keeping track of what trends emerge. It would be much easier to look at all the FastQC reports compiled into a single report. [MultiQC](https://multiqc.info/) is a tool that does exactly this.

MultiQC is designed to interpret and aggregate reports from [various tools](https://multiqc.info/#supported-tools) and output a single report as an HTML document.

<br>
<br>
<br>
<br>

MultiQC Exercise:

1. View the multiQC help page
2. Construct a MultiQC command to aggregate our QC results into a single report
3. Transfer the MultiQC report to personal computer using scp
4. View the MultiQC report

<details>
<summary>MultiQC solution</summary>

1. View MultiQC help page

        multiqc --help | less
        # Will need to type `q` to exit from `less`

2. MultiQC command to process our trimmed read results

        multiqc --outdir ~/analysis/out_multiqc ~/analysis/out_fastqc_trimmed/

3. Log out of aws instance and use scp to transfer MultiQC report to local computer

        exit # log out from remote

        # Now on local
        scp <username>@50.17.210.255:~/analysis/out_multiqc/multiqc_report.html ~/workshop_rsd/

4. View MultiQC report
Use GUI file manager to find your ~/workshop_rsd folder
Double-click multiqc_report.html (open it with an internet browser)

</details>

Opening the HTML report, we see it is organized by the same modules and each plot has all samples for which FastQC was run. We can see the report confirms that the adapters have been trimmed from our sequence.

---

These materials have been adapted and extended from materials created by the [Harvard Chan Bioinformatics Core (HBC)](http://bioinformatics.sph.harvard.edu/). These are open access materials distributed under the terms of the [Creative Commons Attribution license (CC BY 4.0)](http://creativecommons.org/licenses/by/4.0/), which permits unrestricted use, distribution, and reproduction in any medium, provided the original author and source are credited.
