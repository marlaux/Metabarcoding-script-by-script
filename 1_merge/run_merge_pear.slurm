#!/bin/bash

#SBATCH --account=nn9813k
#SBATCH --job-name=Pear
#SBATCH --ntasks=8
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem-per-cpu=8G 
#SBATCH --time=72:00:00




set -o errexit 
set -o nounset 


./merge_pear.sh


exit 0
