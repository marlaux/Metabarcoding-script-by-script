#!/bin/bash

#SBATCH --job-name=OTUtable
#SBATCH --time=72:00:00
#SBATCH --account=nn9623k
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=8G


set -o errexit
set -o nounset


./build_OTU_table.sh


