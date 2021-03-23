#/bin/bash

#module load VSEARCH/2.9.1-foss-2018b
module --force purge
module load StdEnv
module load VSEARCH/2.13.4-iccifort-2019.1.144-GCC-8.2.0-2.31.1


THREADS="4"

for file in /cluster/projects/nn9623k/metapipe/3_read_cleaning/fastas/*_f1.fasta; do pre="$(basename $file _f1.fasta)"; echo $pre;  \
    vsearch --quiet --threads ${THREADS}  \
    --derep_fulllength $file  \
    --sizeout \
    --fasta_width 0 \
    --relabel_sha1  \
    --output ${pre}_dp.fasta 2>> ${pre}_dp.log; done;

mkdir derep_logs
mv *.log derep_logs

mkdir derep_samples
mv *_dp.fasta derep_samples

