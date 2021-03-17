#!/bin/bash

# Script example for a normal MPI job on Saga #

#SBATCH --account=nn9623k
#SBATCH --job-name=Pear
#SBATCH --ntasks=1 ## Number of tasks (aka processes) to start: Pure mpi, one cpu per task
#SBATCH --cpus-per-task=8
#SBATCH --ntasks-per-node=8
#SBATCH --mem-per-cpu=500M	## Amount of memory per cpu 
#SBATCH --time=72:10:00 

## Setting variables and prepare runtime environment:

set -o errexit 
set -o nounset 

# Loading Software modules

module --quiet purge            # Restore loaded modules to the default
module load StdEnv
module load PEAR/0.9.11-GCCcore-9.3.0

## Prepare jobs, moving input files and making sure output is copied back

SCRIPT="merge_pear.sh"
INPUT_F="Lib1_R1_subsampled.fastq"
INPUT_R="Lib1_R2_subsampled.fastq"

# Prepare input files
cp ${INPUT_F} ${INPUT_R} ${SCRIPT} $SCRATCH
cd $SCRATCH

chmod 777 ${SCRIPT}


./${SCRIPT}

# Make sure output is copied back after job finishes
savefile Lib1_sub.assembled.fastq Lib1_sub.discarded.fastq Lib1_sub.unassembled.forward.fastq Lib1_sub.unassembled.reverse.fastq Lib1_R1_subsampled.fastq Lib1_R2_subsampled.fastq

exit 0

