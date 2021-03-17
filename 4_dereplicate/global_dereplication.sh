TMP_FASTA=$(mktemp --tmpdir=".")
FINAL_FASTA="my_samples_global_derep.fas"


module --force purge
module load StdEnv
module load VSEARCH/2.13.4-iccifort-2019.1.144-GCC-8.2.0-2.31.1

# Pool sequences
cat /cluster/projects/nn9623k/metapipe/3_read_cleaning/dereplicated/*.fasta > "${TMP_FASTA}"

# Dereplicate (vsearch)
        vsearch --derep_fulllength "${TMP_FASTA}" \
             --sizein \
             --sizeout \
             --fasta_width 0 \
             --output "${FINAL_FASTA}" > /dev/null

rm -f "${TMP_FASTA}"
