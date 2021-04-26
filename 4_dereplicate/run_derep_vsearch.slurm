#!/bin/bash

#SBATCH --job-name=clip
#SBATCH --time=72:00:00
#SBATCH --account=nn9813k
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=4G


set -o errexit
set -o nounset


./derep_sample_global.sh

##################################
#./dereplicate_by_sample.sh
#./global_dereplication.sh
