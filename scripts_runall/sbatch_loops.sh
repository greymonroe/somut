

#!/bin/bash


########## Tests
rm -rf ./somut
git clone https://github.com/greymonroe/somut.git

# tests

parent_directory=~/projects/atx_ko/0_raw
dir=/home/gmonroe/projects/atx_ko/0_raw/WT_2
dir_name=$(basename "$dir")

        echo "Processing: $dir"
        sbatch ./somut/sbatch/1_trimmomatic.sbatch.sh $dir/${dir_name}_L1_1.fq.gz $dir/${dir_name}_L1_2.fq.gz $dir_name ~/projects/atx_ko
        sbatch ./somut/sbatch/2_bwa.sbatch.sh l $dir_name ~/projects/atx_ko


########## Tests
rm -rf ./somut
git clone https://github.com/greymonroe/somut.git

TUMOR=WT_2
NORMAL=WT_4
sbatch ./somut/sbatch/3_strelka2.sbatch.sh $TUMOR $NORMAL ~/data/genome/a_thaliana/TAIR10_chr_all.fasta ~/projects/atx_ko



# TRIMMOMATIC
parent_directory=~/projects/atx_ko/0_raw

# Loop over each directory within the parent directory
for dir in "$parent_directory"/*; do
    # Check if it's a directory
    if [ -d "$dir" ]; then
        # Extract only the directory name
        dir_name=$(basename "$dir")

        echo "Processing: $dir_name"
        
        #READ1=$1, READ2=$2, PREFIX=$3, DIR=$4
        sbatch ./somut/sbatch/1_trimmomatic.sbatch.sh $dir/${dir_name}_L1_1.fq.gz $dir/${dir_name}_L1_2.fq.gz $dir_name ~/projects/atx_ko
    fi
done

# TRIMMOMATIC
parent_directory=~/projects/atx_ko/0_raw

# BWA
for dir in "$parent_directory"/*; do
    # Check if it's a directory
    if [ -d "$dir" ]; then
        # Extract only the directory name
        dir_name=$(basename "$dir")

        echo "Processing: $dir_name"
        
        #REF=$1, PREFIX=$2, DIR=$3
        sbatch ./somut/sbatch/2_bwa.sbatch.sh ~/data/genome/a_thaliana/TAIR10_chr_all.fasta $dir_name ~/projects/atx_ko

    fi
done


# STRELKA
TUMORS=$(ls ~/projects/atx_ko/0_raw)
NORMALS=$(ls ~/projects/atx_ko/0_raw)

#!/bin/bash
for TUMOR in $TUMORS; do
for NORMAL in $NORMALS; do
if [ "$TUMOR" != "$NORMAL" ]; then
echo ${TUMOR} vs $NORMAL
#TUMOR=$1 NORMAL=$2 REF=$3 DIR=$4#
sbatch ./somut/sbatch/3_strelka2.sbatch.sh $TUMOR $NORMAL ~/data/genome/a_thaliana/TAIR10_chr_all.fasta ~/projects/atx_ko
fi
done
done

TUM

echo ${TUMOR} vs $NORMAL
#TUMOR=$1 NORMAL=$2 REF=$3 DIR=$4#
sbatch ./somut/sbatch/3_strelka2.sbatch.sh $TUMOR $NORMAL ~/data/genome/a_thaliana/TAIR10_chr_all.fasta ~/projects/atx_ko
