# Differential Expression Analysis of Mouse RNA-seq Data

This repository contains an end-to-end RNA-seq differential expression analysis
of 12 mouse samples sequenced on a NextSeq500 platform.


## Overview
- Organism: Mouse (chromosome 2)
- Samples: 12 (3 groups: A, B, C; 4 biological replicates)
- Sequencing: Single-end RNA-seq
- Analysis: QC → Alignment → Quantification → Differential Expression

## Tools Used
- Scythe (adapter trimming)
- Sickle (quality trimming)
- HISAT2 (alignment)
- Samtools
- StringTie
- DESeq2
- limma
- ggplot2

## Key Analyses
- Batch-aware differential expression (~ batch + group)
- Gene- and transcript-level analysis
- LFC shrinkage (ashr)
- PCA before and after batch correction
- MA plots under different LFC hypotheses

## How to Run
### 1) Preprocess + align + quantify (HPC / PBS)
The preprocessing, alignment (HISAT2), and transcript quantification (StringTie) were run on an HPC cluster using the PBS job script:

- `scripts/run_rnaseq_pbs.sh`

This step produces per-sample StringTie GTF outputs and a `list.gtf.txt`, which is then used by `prepDE.py` (StringTie utility) to generate:

- `gene_count_matrix.csv`
- `transcript_count_matrix.csv`

> Note: This script assumes required tools are installed and available in `$PATH` (scythe, sickle, hisat2, samtools, stringtie, prepDE.py).

To submit on a PBS cluster:
```bash
qsub scripts/run_rnaseq_pbs.sh
```
### 2) Differential expression 

Open `analysis/differential_expression.Rmd` in RStudio and knit to HTML.

## Author
Liyana Saleem
