#!/bin/bash
#SBATCH --job-name=cluster
#SBATCH --time=72:00:00
#SBATCH --account=nn9813k
#SBATCH --ntasks=8
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem-per-cpu=16G

set -o errexit
set -o nounset

./clustering_swarm_with_chim_filter_wrap.sh

#######################################################################
#STEPS SEPARATED:

#./global_dereplication.sh

#./clustering_swarm.sh

#./sort_representatives.sh

#./chimera_checking.sh

#######################################################################

