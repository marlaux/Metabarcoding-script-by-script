#/bin/bash

#Method adapted from the following reference: https://github.com/frederic-mahe/stampa.git
module --force purge
module load StdEnv
module load cutadapt/2.10-GCCcore-9.3.0-Python-3.8.2

# Define variables and output file
#URL="http://www.barcodinglife.org/data/datarelease/NewPackages"
#VERSION="6.50"
TARGET="iBOL_phase_6.50_COI.tsv.zip"
INPUT=${TARGET/.zip/}
PRIMER_F="GCHCCHGAYATRGCHTTYCC"
PRIMER_R="TCDGGRTGNCCRAARAAYCA"
PRIMER_NAMES="primersX"
FINAL_FASTA="bold_${PRIMER_NAMES}.fasta"
LOG=${FINAL_FASTA/.fasta/.log}
CUTADAPT=$(which cutadapt)

unzip ${TARGET}

# Prepare fasta file, modify headers and trim primers
awk 'BEGIN {FS = "\t"}
     {if (NR > 1) {
          print ">"$5"@"$9"|"$10"|"$11"|"$12"|"$13"|"$14"|"$15"\n"$31
         }
     }' ${INPUT} | \
    sed -r 's/\|\|/|missing|/g
            s/ [:[:alnum:]]+$//
            s/\|\|/|missing|/
            s/ /_/ ; s/@/ /' | \
    ${CUTADAPT} --discard-untrimmed -g "${PRIMER_F}" - 2> "${LOG}" | \
    ${CUTADAPT} -a "${PRIMER_R}" - 2>> "${LOG}" > "${FINAL_FASTA}"
