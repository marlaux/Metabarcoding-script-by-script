#!/bin/bash

#SBATCH --job-name=cluster
#SBATCH --time=72:00:00
#SBATCH --account=nn9813k
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=4G


set -o errexit
set -o nounset




./clustering_swarm_complete.sh

#######################################################################
#STEPS SEPARATED:

#./global_dereplication.sh

#./clustering_swarm.sh

#./sort_representatives.sh

#./chimera_checking.sh

#######################################################################

