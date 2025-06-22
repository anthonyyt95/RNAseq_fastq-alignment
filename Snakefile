import pandas as pd
import numpy as np
import os

files=list()

with open('filenames.txt') as f:
  mylist = f.read().splitlines()
  for element in mylist:
    files.append(element)


TYPES=['_forward_paired','_reverse_paired','_forward_unpaired','_reverse_unpaired']

star_index="/gpfs/data/feskelab/TonyTao/Documents/STAR/Genomes/mus_musculus"
featureCounts_gtf="/gpfs/data/feskelab/TonyTao/Documents/STAR/gencode.vM24.annotation.gtf"

rule all:
  input:
    expand("preprocessing/STAR/{filename}Aligned.sortedByCoord.out.bam", filename=files),
    "samples/multiqc_report_new.html",
    "preprocessing/STAR/featurecounts.txt"
		
rule featureCounts:
  input:
    expand("preprocessing/STAR/{filename}Aligned.sortedByCoord.out.bam", filename=files)
  output:
    "preprocessing/STAR/featurecounts.txt"
  shell:
    """featureCounts --primary \
    -C \
    -t exon \
    -g gene_id \
    -a {featureCounts_gtf} \
    -o {output} \
    {input}"""

rule multiqc:
  input:
    expand("samples/FASTQC/{filename}{filename2}_fastqc.zip",filename=files,filename2=['_forward_paired','_forward_unpaired','_reverse_paired','_reverse_unpaired']),
    expand("preprocessing/STAR/{filename}Log.final.out",filename=files)
  output:
    "samples/multiqc_report_new.html"
  shell:
    '''
    export LC_ALL=en_US.utf8
    export LANG=$LC_ALL
    multiqc samples/FASTQC/ preprocessing/STAR/ -n {output}
    '''
		

rule fastqc:
  input:
    "samples/trimmed/{filename}{filename2}.fq.gz",
  output:
    "samples/FASTQC/{filename}{filename2}_fastqc.zip"
  threads:16
  shell:
    "fastqc -o samples/FASTQC {input} -threads {threads}"


rule STAR:
  input:
    FP="samples/trimmed/{filename}_forward_paired.fq.gz",
    RP="samples/trimmed/{filename}_reverse_paired.fq.gz"
  output:
    "preprocessing/STAR/{filename}Log.final.out",
    "preprocessing/STAR/{filename}Log.out",
    "preprocessing/STAR/{filename}Log.progress.out",
    "preprocessing/STAR/{filename}SJ.out.tab",
    #directory("preprocessing/STAR/{filename}_STARtmp"),
    "preprocessing/STAR/{filename}Aligned.sortedByCoord.out.bam"
  threads:16
  shell:
    "STAR --readFilesCommand zcat --runMode alignReads --readFilesIn {input.FP} {input.RP} --outSAMtype BAM SortedByCoordinate --runThreadN {threads} --genomeDir {star_index} --outFileNamePrefix  preprocessing/STAR/{wildcards.filename}"

rule trim:
  input:
    forward="/gpfs/data/feskelab/TonyTao/Documents/Projects/hcnAnalysis/PE/samples/{filename}_pass_1.fastq.gz",
    reverse="/gpfs/data/feskelab/TonyTao/Documents/Projects/hcnAnalysis/PE/samples/{filename}_pass_2.fastq.gz"
  output:
    forward_paired = "samples/trimmed/{filename}_forward_paired.fq.gz",
    forward_unpaired = "samples/trimmed/{filename}_forward_unpaired.fq.gz",
    reverse_paired = "samples/trimmed/{filename}_reverse_paired.fq.gz",
    reverse_unpaired = "samples/trimmed/{filename}_reverse_unpaired.fq.gz"
  threads:16
  shell:
    """
    trimmomatic PE -phred33 -threads {threads} {input.forward} {input.reverse} {output.forward_paired} \
    {output.forward_unpaired} {output.reverse_paired} {output.reverse_unpaired} \
    ILLUMINACLIP:./adapters/TruSeq3-PE-2.fa:2:30:10 \
    LEADING:3 \
    TRAILING:3 \
    SLIDINGWINDOW:4:15 \
    MINLEN:36"""





