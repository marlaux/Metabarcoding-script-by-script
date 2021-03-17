#/bin/bash

###DEMULTIPLEXING ILLUMINA DUAL INDEXED EXACT PAIRS
###THIS STRATEGY IS EXCLUSIVE FOR PRIMER DESIGN UNIQUE, NO INDEX IS SHARED, ALL SAMPLES INDEPENDENT
##The preparing_tags_LCPI.pl only format your barcodes files as two forward fasta files and two reverse complement fasta files:
#input mapping file format tab delimited:
#Sample1    tagF      tagR
#Sample2  ACCTGAAT  ATACAGA
#output:
#Barcode_R1.fa     Barcode_R2.fa     Barcode_R1_RC.fa     Barcode_R2_RC.fa
#>Sample1          >Sample1          >Sample1             >Sample1
#ACCTGAAT          ACCTACAG          ATTCAGGT             CTGTAGGT   

#check the mapping file for duplicates in excel before sending to server
#write sample names without space, e.g SamPLe 23 is not allowed, but SamPLe_23 is.
#do not use numbers in the beginning of your sample names
#perl preparing_tags_LCPI.pl
                #my_mapping_file.txt
                                #unique
#ANY CUTADAPT ISSUE OR DOUBTS, SEE: 
#https://cutadapt.readthedocs.io/en/stable/guide.html
#https://support.illumina.com/bulletins/2018/08/understanding-unique-dual-indexes--udi--and-associated-library-p.html

INPUT_F="My_project_my_marker_R1.fastq"
INPUT_R="My_project_my_marker_R2.fastq"
R1_TAGS="Barcode_R1.fa"
R2_TAGS="Barcode_R2.fa"
R1_TAGS_RC="Barcode_R1_RC.fa"
R2_TAGS_RC="Barcode_R2_RC.fa"

cutadapt --pair-adapters -a file:${R1_TAGS} -a file:${R2_TAGS_RC} -G file:${R2_TAGS} -G file:${R1_TAGS_RC} -o {name}.1.fq -p {name}.2.fq ${INPUT_R1} ${INPUT_R2} --info-file matches.txt


mkdir demulti_samples
mv *.fq demulti_samples

