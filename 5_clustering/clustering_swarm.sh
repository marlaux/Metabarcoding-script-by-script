#/bin/bash

module --force purge
module load StdEnv
module load swarm/3.0.0-GCC-9.3.0

#COPY HERE THE GLOBAL DEREP FASTA FILE FROM 4_DEREPLICATE FOLDER
THREADS="1"
FINAL_FASTA="my_training_set_global_dp.fas"
swarm     \
    -d 1 -f -t ${THREADS} -z \
    -i ${FINAL_FASTA/.fas/.struct} \
    -s ${FINAL_FASTA/.fas/.stats} \
    -w ${FINAL_FASTA/.fas/_1f_representatives.fas} \
    -o ${FINAL_FASTA/.fas/.swarms} < ${FINAL_FASTA}

