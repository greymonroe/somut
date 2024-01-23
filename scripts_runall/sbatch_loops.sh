

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
NORMAL=WT_6
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
TUMORS=$(ls ~/projects/atx_ko/0_raw | grep -v -e "WT_10" -e "atx12r7_F4_11" -e "atx12r7_F4_10" -e "WT_9")
NORMALS=$(ls ~/projects/atx_ko/0_raw | grep -v -e "WT_10" -e "atx12r7_F4_11" -e "atx12r7_F4_10" -e "WT_9")

#!/bin/bash
for TUMOR in $TUMORS; do
for NORMAL in $NORMALS; do
if [ "$TUMOR" != "$NORMAL" ]; then
#TUMOR=$1 NORMAL=$2 REF=$3 DIR=$4#
FILE="3_strelka/$TUMOR/$NORMAL/results/variants/somatic.snvs.vcf.gz"
        if [ ! -f "$FILE" ]; then
            echo ${TUMOR} vs $NORMAL
            sbatch ./somut/sbatch/3_strelka2.sbatch.sh "$TUMOR" "$NORMAL" ~/data/genome/a_thaliana/TAIR10_chr_all.fasta ~/projects/atx_ko
        fi
fi
done
done

# STRELKA ORGANIZE
TUMORS=$(ls ~/projects/atx_ko/0_raw | grep -v -e "WT_10" -e "atx12r7_F4_11" -e "atx12r7_F4_10" -e "WT_9")
NORMALS=$(ls ~/projects/atx_ko/0_raw | grep -v -e "WT_10" -e "atx12r7_F4_11" -e "atx12r7_F4_10" -e "WT_9")

rm -rf 4_strelka_organized
rm 4_strelka_organized.tar.gz

mkdir -p 4_strelka_organized
#!/bin/bash
for TUMOR in $TUMORS; do
for NORMAL in $NORMALS; do
if [ "$TUMOR" != "$NORMAL" ]; then
mkdir -p 4_strelka_organized/$TUMOR/$NORMAL/results/variants
cp 3_strelka/$TUMOR/$NORMAL/results/variants/somatic.snvs.vcf.gz 4_strelka_organized/$TUMOR/$NORMAL/results/variants
cp 3_strelka/$TUMOR/$NORMAL/results/variants/somatic.indels.vcf.gz 4_strelka_organized/$TUMOR/$NORMAL/results/variants
cp 3_strelka/$TUMOR/$NORMAL/results/regions/somatic.callable.regions.bed.gz 4_strelka_organized/$TUMOR/$NORMAL/results/variants
fi
done
done

tar -czvf 4_strelka_organized.tar.gz 4_strelka_organized

#local
scp -r gmonroe@farm.cse.ucdavis.edu:~/projects/atx_ko/4_strelka_organized.tar.gz ~/Documents
tar -xzvf ~/Documents/4_strelka_organized.tar.gz
