#/bin/bash

TMP_FASTA=$(mktemp --tmpdir=".")
FINAL_FASTA="training_set_global_dp.fas"
LENGTH=380 ###according to your expected amplicon lenght
THREADS="4"

module --force purge
module load StdEnv
module load VSEARCH/2.13.4-iccifort-2019.1.144-GCC-8.2.0-2.31.1

# Global dereplication
# Pool sequences
cat dereplicated/*_dp.fasta > "${TMP_FASTA}"
#cat /cluster/projects/nn9623k/metapipe/3_read_cleaning/dereplicated/*.fasta > "${TMP_FASTA}"

	vsearch --derep_fulllength "${TMP_FASTA}" \
             --sizein \
             --sizeout \
             --fasta_width 0 \
	     --output "${FINAL_FASTA}" > /dev/null

#rm -f "${TMP_FASTA}"

module --force purge
module load StdEnv  
module load swarm/3.0.0-GCC-9.3.0

#SWARM=$(which swarm)
THREADS="4"
TMP_REPRESENTATIVES=$(mktemp --tmpdir=".")

swarm	\
    -d 1 -f -t ${THREADS} -z \
    -i ${FINAL_FASTA/.fas/.struct} \
    -s ${FINAL_FASTA/.fas/.stats} \
    -w ${TMP_REPRESENTATIVES} \
    -o ${FINAL_FASTA/.fas/.swarms} < ${FINAL_FASTA}

module --force purge
module load StdEnv
module load VSEARCH/2.13.4-iccifort-2019.1.144-GCC-8.2.0-2.31.1

# Sort representatives
#VSEARCH=$(which vsearch)
vsearch	\
	--fasta_width 0 \
        --sortbysize ${TMP_REPRESENTATIVES} \
        --output ${FINAL_FASTA/.fas/_1f_representatives.fas}
rm ${TMP_REPRESENTATIVES}

# Chimera checking
REPRESENTATIVES=${FINAL_FASTA/.fas/_1f_representatives.fas}
UCHIME=${REPRESENTATIVES/.fas/.uchime}
vsearch 	\
	--uchime_denovo "${REPRESENTATIVES}" \
        --uchimeout "${UCHIME}"

