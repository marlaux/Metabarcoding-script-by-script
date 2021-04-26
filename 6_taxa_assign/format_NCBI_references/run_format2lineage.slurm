#!/bin/bash

#SBATCH --account=nn9813k
#SBATCH --job-name=Entrez/format
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=8G
#SBATCH --time=72:00:00




set -o errexit
set -o nounset


#./format_NCBI2lineages_auto.sh -r Arthropoda_COI_esearch.fasta -p Arthropoda_COI
./EntrezDirect2slurm.sh


exit 0
