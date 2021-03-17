#/bin/bash

module --force purge
module load StdEnv
module load VSEARCH/2.13.4-iccifort-2019.1.144-GCC-8.2.0-2.31.1

# Chimera checking
FINAL_FASTA="my_samples_global_derep.fas"
REPRESENTATIVES=${FINAL_FASTA/.fas/_1f_representatives.fas}
UCHIME=${REPRESENTATIVES/.fas/.uchime}
vsearch    \
        --uchime_denovo "${REPRESENTATIVES}" \
        --uchimeout "${UCHIME}"

