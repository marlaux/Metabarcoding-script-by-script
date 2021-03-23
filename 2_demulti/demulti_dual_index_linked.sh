#/bin/bash
##FOR DUAL INDEX DESIGN, YOU MUST RUN preparing_tags_LCPI.pl to format your barcodes files.
#input mapping file format:
#Sample1    tagF      tagR
#Sample2  ACCTGAAT  ATACAGA
#tab delimited!
#check this mapping file for duplicates in excel before sending to cluster
#write sample names without space, e.g SamPLe 23 is not allowed, but SamPLe_23 is.
#do not use numbers in the beginning of your sample names
#perl preparing_tags_LCPI.pl
                #my_mapping_file.txt
                                #linked
#the perl script should create 3 barcode files, Barcodes_LA1.txt, Barcodes_LA2.txt, Barcodes_LA3.txt for 'linked'
#the linked mode is 5' and 2' anchored by default

#ANY CUTADAPT ISSUE OR DOUBTS, SEE: https://cutadapt.readthedocs.io/en/stable/guide.html


module --quiet purge
module load StdEnv
module load cutadapt/2.10-GCCcore-9.3.0-Python-3.8.2


INPUT="my_training_set.assembled.fastq"
PAIR1="Barcodes_LA1.fa"
PAIR2="Barcodes_LA2.fa"
PAIR3="Barcodes_LA3.fa"

### demultiplex (Linked Adapter)

cutadapt	\
        -a file:${PAIR1}        \
        -a file:${PAIR2}        \
        -a file:${PAIR3}        \
        -o "{name}_LA.fq"  \
        --action=lowercase      \
        ${INPUT}
		
mkdir demulti_linked		
mv *.fq demulti_linked
