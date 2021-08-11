#!/bin/bash

#SBATCH --job-name=cleanclip
#SBATCH --time=72:00:00
#SBATCH --account=nn9813k
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=16G


set -o errexit
set -o nounset

./tag_primer_clipping_wrap1.sh 
#./tag_primer_clipping_wrap2.sh

###########################
#read_trim.sh
#extract_quality.sh
#convert2fasta.sh
