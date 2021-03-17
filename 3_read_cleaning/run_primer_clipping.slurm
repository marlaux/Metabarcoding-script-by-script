#!/bin/bash

#SBATCH --job-name=cleanclip
#SBATCH --time=72:00:00
#SBATCH --account=nn9623k
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=4G


set -o errexit
set -o nounset

./tag_primer_clipping_part1.sh
#./tag_primer_clipping_part2.sh

###########################
#read_trim.sh
#extract_quality.sh
#convert2fasta.sh
