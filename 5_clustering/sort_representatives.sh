#/bin/bash

module --force purge
module load StdEnv
module load VSEARCH/2.13.4-iccifort-2019.1.144-GCC-8.2.0-2.31.1

# Sort representatives
FINAL_FASTA="my_samples_global_derep.fas"
REPRESENTATIVES_1f=${FINAL_FASTA/.fas/_1f_representatives.fas}
vsearch    \
        --fasta_width 0 \
        --sortbysize ${REPRESENTATIVES_1f} \
        --output ${FINAL_FASTA/.fas/_rep_sorted.fas}
rm ${REPRESENTATIVES_1f}

