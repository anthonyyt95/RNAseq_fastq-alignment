#!/bin/bash
#SBATCH -p cpu_medium
#SBATCH -n 2
#SBATCH --mem-per-cpu=32G
#SBATCH --time=24:00:00
#SBATCH --output=job.out
#SBATCH --error=job.err

srun snakemake

