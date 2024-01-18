

#!/bin/bash

# Path to the parent directory
parent_directory=~/projects/atx_ko/0_raw

# Loop over each directory within the parent directory
for dir in "$parent_directory"/*; do
    # Check if it's a directory
    if [ -d "$dir" ]; then
        # Extract only the directory name
        dir_name=$(basename "$dir")

        echo "Processing: $dir_name"
        
        #READ1=$1, READ2=$2, PREFIX=$3, DIR=$4
        sbatch ./somut/sbatch/1_trimmomatic.sbatch.sh ~/projects/atx_ko/0_raw/${dir_name}/${dir_name}_L1_1.fq.gz ~/projects/atx_ko/0_raw/${dir_name}/${dir_name}_L1_2.fq.gz $dir_name ~/projects/atx_ko
    fi
done


rm -rf ./somut
git clone https://github.com/greymonroe/somut.git

# tests

parent_directory=~/projects/atx_ko/0_raw
dir=/home/gmonroe/projects/atx_ko/0_raw/WT_1
dir_name=$(basename "$dir")

        echo "Processing: $dir"
        sbatch ./somut/sbatch/1_trimmomatic.sbatch.sh $dir/${dir_name}_L1_1.fq.gz $dir/${dir_name}_L1_2.fq.gz $dir_name ~/projects/atx_ko

         #REF=$1, PREFIX=$2, DIR=$3
        sbatch ./somut/sbatch/2_bwa.sbatch.sh ~/data/genome/a_thaliana/TAIR10_chr_all.fasta $dir_name ~/projects/atx_ko/0_raw
        
        
        #READ1=$1, READ2=$2, PREFIX=$3, DIR=$4
        sbatch ./somut/sbatch/1_trimmomatic.sbatch.sh $dir/${dir_name}_L1_1.fq.gz $dir/${dir_name}_L1_2.fq.gz $dir_name ~/projects/atx_ko
        #REF=$1, PREFIX=$2, DIR=$3
        sbatch ./somut/sbatch/1_bwa.sbatch.sh ~/data/genome/a_thaliana/TAIR10_chr_all.fasta $dir_name ~/projects/atx_ko/0_raw

~/projects/atx_ko/0_raw/WT_1

