#/bin/bash

TMP_FASTA=$(mktemp --tmpdir=".")
GLOBAL_DP="COI_Arthropoda_global_dp.fas"
LENGTH=380 ###according to your expected amplicon lenght


module --force purge
module load StdEnv
module load VSEARCH/2.13.4-iccifort-2019.1.144-GCC-8.2.0-2.31.1

# Global dereplication
#cat /cluster/projects/nn9623k/metapipe/3_read_cleaning/dereplicated/3_read_cleaning/dereplicated/*.fasta > "${TMP_FASTA}"
cat /cluster/work/users/marlaux/GITHUB/METAPIPE/3_read_cleaning/dereplicated_bash/*_dp.fasta > "${TMP_FASTA}"

# Global dereplication
vsearch --derep_fulllength "${TMP_FASTA}" \
        --sizein \
        --sizeout \
        --fasta_width 0 \
        --output "${GLOBAL_DP}" > /dev/null

rm -f "${TMP_FASTA}"

module --force purge
module load StdEnv
module load swarm/3.0.0-GCC-9.3.0

#clustering with SWARM
THREADS="4"
TMP_REPRESENTATIVES=$(mktemp --tmpdir=".")

swarm   \
    -d 1 -f -t ${THREADS} -z \
    -i ${GLOBAL_DP/.fas/.struct} \
    -s ${GLOBAL_DP/.fas/.stats} \
    -w ${TMP_REPRESENTATIVES} \
    -o ${GLOBAL_DP/.fas/.swarms} < ${GLOBAL_DP}

module --force purge
module load StdEnv
module load VSEARCH/2.13.4-iccifort-2019.1.144-GCC-8.2.0-2.31.1

# Sort representatives
vsearch \
        --fasta_width 0 \
        --sortbysize ${TMP_REPRESENTATIVES} \
        --output ${GLOBAL_DP/.fas/_1f_representatives.fas}
rm ${TMP_REPRESENTATIVES}

# Chimera checking
REPRESENTATIVES=${GLOBAL_DP/.fas/_1f_representatives.fas}
UCHIME=${REPRESENTATIVES/.fas/.uchime}
vsearch         \
        --uchime_denovo "${REPRESENTATIVES}" \
        --uchimeout "${UCHIME}"

FINAL=${REPRESENTATIVES/_1f_representatives.fas/_2f_representatives.fas}
sed -e '/^>/ s/;size=/_/' -e '/^>/ s/;$//' "${REPRESENTATIVES}" > "${FINAL}"

