#/bin/bash

module --force purge
module load StdEnv
module load VSEARCH/2.13.4-iccifort-2019.1.144-GCC-8.2.0-2.31.1

TAGS="barcodes_subsample.txt"
QUALITY_FILE="my_samples_quality_file.qual"
THREADS="4"


# Discard sequences containing Ns, add expected error rates and convert to fasta
for file in clipped/*_trim2.fq; do pre="$(basename $file _trim2.fq)"; echo $pre; vsearch --quiet --threads ${THREADS} --fastq_filter $file --fastq_maxns 0 --relabel_sha1 --eeout --fastqout ${pre}_trim3.fq; done;

#quality file
# Discard quality lines, extract hash, expected error rates and read length
for f in *_trim3.fq; do pre="$(basename $f _trim3.fq)"; echo $pre; \
        sed 'n;n;N;d' $f | \
        awk 'BEGIN {FS = "[;=]"}
           {if (/^@/) {printf "%s\t%s\t", $1, $3} else {print length($1)}}' | \
        tr -d "@" >> tmp_qual.txt
done < "${TAGS}"

# Produce the final quality file
sort -k3,3n -k1,1d -k2,2n tmp_qual.txt | \
   uniq --check-chars=40 > "${QUALITY_FILE}"

for file in *_trim3.fq; do pre="$(basename $file _trim3.fq)"; echo $pre; vsearch --fastq_filter $file --fastq_maxns 0 --threads ${THREADS} --fastaout ${pre}_f1.fasta; done;

mkdir format
mv *_trim3.fq format
rm tmp_qual.txt

for file in *_f1.fasta; do pre="$(basename $file _f1.fasta)"; echo $pre; vsearch --quiet --threads ${THREADS} --derep_fulllength $file --sizeout --fasta_width 0 --relabel_sha1 --output ${pre}_dp.fasta; done;

mkdir fastas
mv *_f1.fasta fastas
mkdir dereplicated
mv *_dp.fasta dereplicated







