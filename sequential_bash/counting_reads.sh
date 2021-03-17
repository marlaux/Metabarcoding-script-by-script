#/bin/bash

for file in demulti_linked/*.fq; do grep --with-filename -c "^@M" $file; done >> counting_demulti_reads.txt
