#!/bin/bash -l
#SBATCH -o /home/gmonroe/slurm-log/%j-stdout.txt
#SBATCH -e /home/gmonroe/slurm-log/%j-stderr.txt
#SBATCH -J test
#SBATCH -t 24:00:00
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=32G
#SBATCH --partition=bmh
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=gmonroe@ucdavis.edu

TUMOR=$1
NORMAL=$2
REF=$3
DIR=$4

module load strelka/2.9.10
source activate strelka-2.9.10
configureStrelkaSomaticWorkflow.py

mkdir ${DIR}/3_strelka
mkdir ${DIR}/3_strelka/${TUMOR}
mkdir ${DIR}/3_strelka/${TUMOR}/${NORMAL}

configureStrelkaSomaticWorkflow.py \
        --normalBam ${DIR}/2_bam/${NORMAL}.fix.markdup.bam \
        --tumorBam ${DIR}/2_bam/${TUMOR}.fix.markdup.bam \
        --referenceFasta $REF \
        --runDir ${DIR}/3_strelka/${TUMOR}/${NORMAL}

${DIR}/3_strelka/${TUMOR}/${NORMAL}/runWorkflow.py -m local -j 8

conda deactivate
