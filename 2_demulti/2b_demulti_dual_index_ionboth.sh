#/bin/bash
##RUN preparing_tags_LCPI.pl to format your barcodes files.
#input mapping file format:
#Sample1    tagF      tagR
#Sample2  ACCTGAAT  ATACAGA
####tab delimited!
#check this mapping file for duplicates in excel before sending to cluster
#write sample names without space, e.g sample 23 as sample_23 or sample23.
####DO NOT USE NUMBERS in the beginning of your sample names
#perl preparing_tags_LCPI.pl
                #my_mapping_file.txt
                                #linked
#the perl script should create 3 barcode files, Barcodes_LA1.txt, Barcodes_LA2.txt, Barcodes_LA3.txt for 'linked'
#the linked mode is 5' and 3' anchored

#ANY CUTADAPT ISSUE OR DOUBTS, SEE: https://cutadapt.readthedocs.io/en/stable/guide.html

module --quiet purge
module load StdEnv
module load cutadapt/2.10-GCCcore-9.3.0-Python-3.8.2

INPUT="${1}"
ERR="${2}"
PAIR1="Tags_alt1_bothanch.fa"
PAIR2="Tags_alt1_bothanch.fa"
PAIR3="Tags_alt1_bothanch.fa"
PAIR4="Tags_alt1_bothanch.fa"

### demultiplex (Linked Adapter)

cutadapt	\
	--quiet	\
        -a file:${PAIR1}        \
        -a file:${PAIR2}        \
        -a file:${PAIR3}        \
	-a file:${PAIR4}        \
        -o "{name}_Ion_LA.fq"  \
	-e ${ERR}	\
        --action=lowercase      \
        ${INPUT}
		
mkdir demulti_ionboth_${ERR}err		
mv *.fq demulti_ionboth_${ERR}err
./count_fastq_sequences.sh demulti_ionboth_${ERR}err/*.fq > demulti_ionboth_${ERR}err_count.txt

