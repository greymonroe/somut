#!/bin/bash -l
#SBATCH -o /home/gmonroe/slurm-log2/%j-stdout.txt
#SBATCH -e /home/gmonroe/slurm-log2/%j-stderr.txt
#SBATCH -J bwa
#SBATCH -t 72:00:00
#SBATCH --mem 30G
#SBATCH -n 8
#SBATCH --partition=bmh
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=greymonroe@gmail.com
set -e
set -u
set -xv

REF=$1
PREFIX=$2
DIR=$3

READ1=${DIR}/1_fastq/${PREFIX}_1.trimmed.fastq.gz
READ2=${DIR}/1_fastq/${PREFIX}_2.trimmed.fastq.gz

bwa mem -t 32 -r "@RG\tID:$PREFIX\tSM:$PREFIX\tPL:DBSEQ" $REF $READ1 $READ2 | samtools sort -n -@5 -o ${DIR}/2_bam/$PREFIX.bam

samtools fixmate -m ${DIR}/2_bam/$PREFIX.bam - | samtools sort -@5 -o ${DIR}/2_bam/$PREFIX.fix.bam

samtools index ${DIR}/2_bam/$PREFIX.fix.bam

samtools markdup -@5 -s ${DIR}/2_bam/$PREFIX.fix.bam - | samtools sort -@5 -o  ${DIR}/2_bam/$PREFIX.fix.markdup.bam

samtools index ${DIR}/2_bam/$PREFIX.fix.markdup.bam
