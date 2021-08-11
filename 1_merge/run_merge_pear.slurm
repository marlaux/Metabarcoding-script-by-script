#!/bin/bash

#SBATCH --account=nn9813k
#SBATCH --job-name=Pear
#SBATCH --ntasks=8
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem-per-cpu=8G 
#SBATCH --time=72:00:00

module --quiet purge
module load StdEnv
module load PEAR/0.9.11-GCCcore-9.3.0

set -o errexit 
set -o nounset 


./merge_pear.sh
#or
#./merge_pear_auto.sh -f R1.fq -r R2.fq -o output -p 0.001 -s 20 -t 8

exit 0
