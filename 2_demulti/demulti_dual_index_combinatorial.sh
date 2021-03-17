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

##The preparing_tags_LCPI.pl only format your barcodes files as two separated fasta files:
#input mapping file format tab delimited:
#Sample1    tagF      tagR
#Sample2  ACCTGAAT  ATACAGA
#output:
#tagF.fa      tagR.fa  
#>Sample2     >Sample2
#ACCTGAAT     ATACAGA

#check this mapping file for duplicates in excel before sending to cluster
#write sample names without space, e.g SamPLe 23 is not allowed, but SamPLe_23 is.
#do not use numbers in the beginning of your sample names
#perl preparing_tags_LCPI.pl
                #my_mapping_file.txt
                                #combinatorial
#the perl script should create 2 barcode files, Barcodes_F.fa and Barcodes_R.fa

#ANY CUTADAPT ISSUE OR DOUBTS, SEE: 
#https://cutadapt.readthedocs.io/en/stable/guide.html 
#https://support.illumina.com/bulletins/2018/08/understanding-unique-dual-indexes--udi--and-associated-library-p.html

INPUT_F="training_set_R1.fastq"
INPUT_R="training_set_R2.fastq"
TAG_F="Barcodes_F.fa"
TAG_R="Barcodes_R.fa"

cutadapt \
    -e 0.1 --no-indels \
    -g file:${TAG_F} \
    -G file:${TAG_R} \
    -o {name1}-{name2}_1.fq -p {name1}-{name2}_2.fq \
    --action=lowercase	\
    ${INPUT_F} ${INPUT_R}	


mkdir demulti_comb
mv *.fq demulti_comb
