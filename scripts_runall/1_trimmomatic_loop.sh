

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
        #sbatch ../1_trimmomatic.sbatch.sh $dir/${dir_name}_L1_1.fq.gz $dir/${dir_name}_L1_2.fq.gz $dir_name ~/projects/atx_ko

    fi
done

parent_directory=~/projects/atx_ko/0_raw
dir=/home/gmonroe/projects/atx_ko/0_raw/WT_1
dir_name=$(basename "$dir")

        echo "Processing: $dir_name"
        
        #READ1=$1, READ2=$2, PREFIX=$3, DIR=$4
        sbatch ../sbatch/1_trimmomatic.sbatch.sh $dir/${dir_name}_L1_1.fq.gz $dir/${dir_name}_L1_2.fq.gz $dir_name ~/projects/atx_ko
~/projects/atx_ko/0_raw/WT_1
