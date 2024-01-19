#!/bin/bash -l
#SBATCH -o /home/gmonroe/slurm-log2/%j-stdout.txt
#SBATCH -e /home/gmonroe/slurm-log2/%j-stderr.txt
#SBATCH -J strelka2
#SBATCH -t 24:00:00
#SBATCH --ntasks=16
#SBATCH --mem=128G
#SBATCH --partition=bmh
#SBATCH --mail-type=ALL
#SBATCH --mail-user=gmonroe@ucdavis.edu

TUMOR=$1
NORMAL=$2
REF=$3
DIR=$4

conda activate py2
module load strelka/2.9.10
#STRELKA_INSTALL_PATH=~/strelka-2.9.2.centos6_x86_64

mkdir -p ${DIR}/3_strelka/${TUMOR}/${NORMAL}
rm -rf ${DIR}/3_strelka/${TUMOR}/${NORMAL}/*

#${STRELKA_INSTALL_PATH}/bin/configureStrelkaSomaticWorkflow.py \
configureStrelkaSomaticWorkflow.py \
        --normalBam ${DIR}/2_bam/${NORMAL}.fix.markdup.bam \
        --tumorBam ${DIR}/2_bam/${TUMOR}.fix.markdup.bam \
        --referenceFasta $REF \
        --runDir ${DIR}/3_strelka/${TUMOR}/${NORMAL}

${DIR}/3_strelka/${TUMOR}/${NORMAL}/runWorkflow.py -m local -j 16

conda deactivate
