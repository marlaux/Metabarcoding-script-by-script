#/bin/bash

module --force purge
module load StdEnv
module load VSEARCH/2.13.4-iccifort-2019.1.144-GCC-8.2.0-2.31.1


TAGS="my_original_mapping_file.txt" #(sample   Ftag   Rtag)
QUALITY_FILE="my_project_quality_file.qual"


# Discard sequences containing Ns, add expected error rates and convert to fasta
for file in /primer_clip/*_trim2.fq; do pre="$(basename $file _trim2.fq)"; echo $pre; vsearch --quiet --fastq_filter $file --relabel_sha1 --fastq_qmax 45 --eeout --fastq_maxns 0 --fastqout ${pre}_trim3.fq; done;

#quality file
# Discard quality lines, extract hash, expected error rates and read length
TMP_QUAL=$(mktemp --tmpdir=".")
for f in *_trim3.fq; do pre="$(basename $f _trim3.fq)"; echo $pre; \
        sed 'n;n;N;d' $f | \
        awk 'BEGIN {FS = "[;=]"}
           {if (/^@/) {printf "%s\t%s\t", $1, $3} else {print length($1)}}' | \
        tr -d "@" >> "${TMP_QUAL}"
done < "${TAGS}"

# Produce the final quality file
sort -k3,3n -k1,1d -k2,2n $TMP_QUAL  | \
   uniq --check-chars=40 > "${QUALITY_FILE}"

for i in *_trim3.fq; do pre="$(basename $i _trim3.fq)"; echo $pre; vsearch --quiet --fastq_filter $i --xee --fastaout ${pre}_trim3.fasta; done;
mkdir trimming
mv *_trim3.fq trimming
mv *_trim3.fasta trimming

for f in /trimming/*_trim3.fasta; do pre="$(basename $f _trim3.fasta)"; echo $pre; vsearch --quiet --derep_fulllength $f --sizeout --fasta_width 0 --output ${pre}_dp.fasta; done;
mkdir dereplicated
mv *_dp.fasta dereplicated
rm $TMP_QUAL


