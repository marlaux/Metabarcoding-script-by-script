#/bin/bash

TMP_FASTA=$(mktemp --tmpdir=".")
GLOBAL_DP="ITS_Illumina_Uniplant_global_dp.fas"
LENGTH=400 ###according to your expected amplicon lenght


module --force purge
module load StdEnv
module load VSEARCH/2.13.4-iccifort-2019.1.144-GCC-8.2.0-2.31.1

# Global dereplication
cat /cluster/projects/nn9813k/metapipe/ITS/ITS_illumina/dereplicated_bash/*_dp.fasta > "${TMP_FASTA}"

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
THREADS="8"
TMP_REPRESENTATIVES=$(mktemp --tmpdir=".")

swarm   \
    -d 1 -f -t ${THREADS} -z \
    -i ${GLOBAL_DP/_global_dp.fas/.struct} \
    -s ${GLOBAL_DP/_global_dp.fas/.stats} \
    -w ${TMP_REPRESENTATIVES} \
    -o ${GLOBAL_DP/_global_dp.fas/.swarms} < ${GLOBAL_DP}

module --force purge
module load StdEnv
module load VSEARCH/2.13.4-iccifort-2019.1.144-GCC-8.2.0-2.31.1

# Sort clustering representatives
vsearch \
        --fasta_width 0 \
        --sortbysize ${TMP_REPRESENTATIVES} \
        --output ${GLOBAL_DP/_global_dp.fas/_1f_representatives.fas}
rm ${TMP_REPRESENTATIVES}

# Chimera checking
REPRESENTATIVES="ITS_Illumina_Uniplant_1f_representatives.fas"
UCHIME=${REPRESENTATIVES/.fas/.uchime}
BORDER=${REPRESENTATIVES/.fas/.borderline_chimeras}
CHIMERAS=${REPRESENTATIVES/.fas/.chimeras}
NOCHIMERAS=${REPRESENTATIVES/.fas/_nonchimeras.fasta}
CHIM_ALIGNS=${REPRESENTATIVES/.fas/_chimeras_alignments}

vsearch         \
        --uchime_denovo "${REPRESENTATIVES}" \
        --borderline "${BORDER}"        \
        --chimeras "${CHIMERAS}"        \
        --abskew 2      \
        --uchimealns "${CHIM_ALIGNS}"   \
        --fasta_score   \
        --nonchimeras "${NOCHIMERAS}"   \
        --sizeout       \
        --uchimeout "${UCHIME}"

#General abundance editing
FINAL=${REPRESENTATIVES/_1f_representatives.fas/_2f_representatives.fas}
sed -e '/^>/ s/;size=/_/' -e '/^>/ s/;$//' "${REPRESENTATIVES}" > "${FINAL}"

#nonchimeras sorting with renaming
TMP_REPRESENTATIVES2=$(mktemp --tmpdir=".")
vsearch \
        --sortbysize ${NOCHIMERAS} \
        --sizeout       \
        --output ${TMP_REPRESENTATIVES3}

FINAL2=${NOCHIMERAS/_nonchimeras.fasta/_nonchimeras_sorted.fasta}
sed -e '/^>/ s/;size=/_/' -e '/^>/ s/;$//' "${TMP_REPRESENTATIVES2}" > "${FINAL2}"

#####rm ${TMP_REPRESENTATIVES}
rm ${TMP_REPRESENTATIVES}
rm ${TMP_REPRESENTATIVES2}
