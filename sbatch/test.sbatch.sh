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



echo $REF 
echo $PREFIX
echo $DIR

conda activate trimmomatic
conda deactivate