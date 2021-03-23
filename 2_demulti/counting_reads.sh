#/bin/bash

#UNCOMMENT FOR FQ OR FASTA
for file in *.fq; do grep --with-filename -c "^@M" $file; done >> counting_demulti_reads.txt

for file in *.fasta; do grep --with-filename -c "^>" $file; done >> counting_clean_reads.txt

