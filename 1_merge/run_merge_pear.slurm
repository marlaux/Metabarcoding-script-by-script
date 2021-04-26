#!/bin/bash

#SBATCH --account=nn9813k
#SBATCH --job-name=Pear
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=4G 
#SBATCH --time=72:00:00




set -o errexit 
set -o nounset 


./merge_pear.sh


exit 0
