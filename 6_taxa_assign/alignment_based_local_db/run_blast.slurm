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


#./blasting_options.sh -f my_query.fasta -d NT -s 0.97 -c 0.6 -t 1 -o my_query_NT
./BLAST.sh


exit 0
