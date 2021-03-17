#/bin/bash

TAGS="barcodes_subsample.txt"
QUALITY_FILE="my_samples_quality_fileb.qual"

for f in *_trim3b.fq; do pre="$(basename $f _trim3.fq)"; echo $pre; \
        sed 'n;n;N;d' $f | \
        awk 'BEGIN {FS = "[;=]"}
           {if (/^@/) {printf "%s\t%s\t", $1, $3} else {print length($1)}}' | \
        tr -d "@" >> tmp_qual.txt
done < "${TAGS}"

# Produce the final quality file
sort -k3,3n -k1,1d -k2,2n tmp_qual.txt | \
   uniq --check-chars=40 > "${QUALITY_FILE}"

rm tmp_qual.txt


