#/bin/bash

#module load VSEARCH/2.9.1-foss-2018b
module --force purge
module load StdEnv
module load VSEARCH/2.13.4-iccifort-2019.1.144-GCC-8.2.0-2.31.1


FINAL_FASTA="my_samples_global_derep.fas"
TMP_FASTA=$(mktemp)
THREADS="4"

for file in fastas/*_f1.fasta; do pre="$(basename $file _f1.fasta)"; echo $pre; vsearch --quiet	--threads ${THREADS} --derep_fulllength $file --sizeout --fasta_width 0 --relabel_sha1 --output ${pre}_dp.fasta 2>> ${pre}_dp.log; done;

# Global dereplication

# Pool sequences
cat fastas/*_f1.fasta > "${TMP_FASTA}"

# Dereplicate (vsearch)
vsearch --derep_fulllength "${TMP_FASTA}" \
             --threads ${THREADS}	\
	     --sizein \
             --sizeout \
             --fasta_width 0 \
             --output "${FINAL_FASTA}" > /dev/null

rm -f "${TMP_FASTA}"

mkdir derep_logs
mv *.log derep_logs

mkdir derep_samples
mv *_dp.fasta derep_samples
