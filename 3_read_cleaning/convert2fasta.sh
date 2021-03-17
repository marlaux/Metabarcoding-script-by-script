
module --force purge
module load StdEnv
module load VSEARCH/2.13.4-iccifort-2019.1.144-GCC-8.2.0-2.31.1

THREADS="4"


for file in *_trim3.fq; do pre="$(basename $file _trim3.fq)"; echo $pre; vsearch --fastq_filter $file --fastq_maxns 0 --threads ${THREADS} --fastaout ${pre}_f1.fasta; done;

mkdir format
mv *_trim3.fq format
mkdir fastas
mv *_f1.fasta fastas

