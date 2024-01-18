#!/bin/bash -l
#SBATCH -o /home/gmonroe/slurm-log2/%j-stdout.txt
#SBATCH -e /home/gmonroe/slurm-log2/%j-stderr.txt
#SBATCH -J trimmomatic
#SBATCH -t 96:00:00
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=32G
#SBATCH --partition=bmh
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=gmonroe@ucdavis.edu

READ1=$1
READ2=$2
PREFIX=$3
DIR=$4

conda activate trimmomatic
mkdir ${DIR}/1_fastq

# On Farm, the jar file is located in the $TRIMMOMATIC_HOME variable created
# when trimmomatic module is loaded.
# Specify phred33 or phred64 based on sequencing if known. This prevents reader error and improves speed
trimmomatic PE -threads 8 -phred33 \
 $READ1 $READ2 \
  ${DIR}/1_fastq/${PREFIX}_1.trimmed.fastq.gz ${DIR}/1_fastq/${PREFIX}_1un.trimmed.fastq.gz \
  ${DIR}/1_fastq/${PREFIX}_2.trimmed.fastq.gz ${DIR}/1_fastq/${PREFIX}_2un.trimmed.fastq.gz \
  SLIDINGWINDOW:4:20

