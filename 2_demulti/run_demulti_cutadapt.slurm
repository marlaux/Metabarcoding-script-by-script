#!/bin/bash

#SBATCH --job-name=demulti
#SBATCH --time=72:00:00
#SBATCH --account=nn9813k
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=8G

set -o errexit
set -o nounset

#demultiplexing
#CHOOSE THE STRATEGY ACCORDING TO YOUR PRIMER DESIGN

module --quiet purge
module load StdEnv
module load cutadapt/2.10-GCCcore-9.3.0-Python-3.8.2

#./demulti_dual_index_ion.sh
./demulti_dual_index_linked.sh
#./demulti_dual_index_combinatorial.sh
#./demulti_unique_dual_index.sh



