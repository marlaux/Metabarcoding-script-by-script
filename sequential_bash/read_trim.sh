#/bin/bash

module --force purge
module load StdEnv
module load VSEARCH/2.13.4-iccifort-2019.1.144-GCC-8.2.0-2.31.1



THREADS="4"


# Discard sequences containing Ns, add expected error rates and convert to fasta
for file in /cluster/work/users/marlaux/metapipe/final_test_batch/clipped/*_trim2.fq; do pre="$(basename $file _trim2.fq)"; echo $pre; vsearch --quiet --threads ${THREADS} --fastq_filter $file --fastq_maxns 0 --relabel_sha1 --eeout --fastqout ${pre}_trim3b.fq; done;

