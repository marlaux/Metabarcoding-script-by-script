#/bin/bash

##FOR ION DUAL INDEX DESIGN, YOU MUST RUN preparing_tags_LCPI.pl to format your barcodes files.
#input mapping file format tab delimited:
#Sample1    tagF      tagR
#Sample2  ACCTGAAT  ATACAGA
#check this mapping file for duplicates in excel before sending to cluster
#write sample names without space, e.g SamPLe 23 is not allowed, but SamPLe_23 is.
#do not use numbers in the beginning of your sample names
#perl preparing_tags_LCPI.pl
		#my_mapping_file.txt 
				#ion
#the perl script should create 4 files Barcodes_alt1.fa to Barcodes_alt4.fa 


INPUT="my_ion_dual_index_single_read.fastq"
PAIR1="Barcodes_alt1.fa"
PAIR2="Barcodes_alt2.fa"
PAIR3="Barcodes_alt3.fa"
PAIR4="Barcodes_alt4.fa"
### demultiplex (Linked Adapter)

cutadapt	\
        -a file:${PAIR1}        \
        -a file:${PAIR2}        \
        -a file:${PAIR3}        \
	-a file:${PAIR4}	\ 
        -o "{name}_ion_LA.fq"  \
        --action=lowercase      \
        ${INPUT}
		
		
mkdir demulti_iondual
mv *.fq demulti_iondual
