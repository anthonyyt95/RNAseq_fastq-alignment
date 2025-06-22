
# RNA-seq Preprocessing & QC Snakemake Pipeline

A complete workflow to trim reads, run FastQC, align with STAR, quantify with featureCounts, and aggregate results with MultiQC.

---

## Overview

This Snakemake pipeline automates:

1. **Read trimming** with Trimmomatic  
2. **Quality control** with FastQC  
3. **Alignment** with STAR  
4. **Gene counting** with featureCounts  
5. **Report aggregation** with MultiQC  

---

## Prerequisites

- **Snakemake** ≥ 5.0  
- **Java** (for Trimmomatic)  
- **Trimmomatic**  
- **FastQC**  
- **STAR**  
- **Subread** (for featureCounts)  
- **MultiQC**  
- Python 3 with `pandas`, `numpy` (for helper scripts)  

---

## Directory Structure

```text
.
├── Snakefile
├── filenames.txt           # one sample basename per line
├── adapters/               # Trimmomatic adapter definitions
│   └── TruSeq3-PE-2.fa
├── samples/
│   ├── FASTQC/             # FastQC output
│   └── trimmed/            # Trimmed FASTQ files
└── preprocessing/
    └── STAR/               # STAR outputs and featureCounts results
