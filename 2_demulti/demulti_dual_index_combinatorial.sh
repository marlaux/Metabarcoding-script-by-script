#/bin/bash

###THE COMBINATORIAL APPROACH WORKS IN YOUR ORIGINAL ILLUMINA FASTQ FILES, BEFORE MERGING####
##Combinatorial design:
#F1-R1
#F2-R1
#F2-R1
#...
#F1-R2
#F2-R2
#F3-R2
#...

#FOLLOW THE COMBINATORIAL MAPPING FILE AND BARCODES.FASTA IN COMBINATORIAL_mapping_file SESSION!!!

INPUT_F="training_set_R1_subsampled.fastq"
INPUT_R="training_set_R2_subsampled.fastq"
TAG_F="Barcodes_F.fa"
TAG_R="Barcodes_R.fa"

cutadapt \
    --no-indels \
    -g file:${TAG_F} \
    -G file:${TAG_R} \
    -o {name1}-{name2}_1.fq -p {name1}-{name2}_2.fq \
    --action=lowercase	\
    --discard-untrimmed \
    ${INPUT_F} ${INPUT_R}	
  
mkdir demulti_comb
mv *.fq demulti_comb
