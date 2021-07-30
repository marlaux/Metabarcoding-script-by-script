#!/bin/bash

DATABASE=''
REFERENCES=''
TAXA=''
ORGANISM=''
DB_NAME=''

usage () {
        echo "##################################################"
        echo " "
        echo "Download reference sequences in fasta format."
        echo "Entrez Direct NCBI command line tools"
        echo " "
        echo "Usage: $0 [-d nuccore|protein] [-q gene] [-t taxa] [-o output]"
        echo " "
        echo "-d     NCBI database: 'nuccore' (nucleotide) or 'protein'"
        echo "-q     Entrez search terms: 'COI [gene]' or 'Internal transcribed spacer'"
        echo "-t     Expected taxonomic target: 'Arthropoda [ORGN]' or 'plants [ORGN]'"
        echo "-o     Name for the local database."
        echo "-h     Print this Help."
        echo " "
        echo "##################################################"
                1>&2; exit 1;
}
while getopts "d:q:t:o:h" option; do
        case $option in
        d) DATABASE="${OPTARG}"
                ;;
        q) REFERENCES="${OPTARG}"
                ;;
        t) TAXA="${OPTARG}"
                ;;
        o) DB_NAME=${OPTARG}
                ;;
        h | *) usage
                exit 0
                ;;
        \?) echo "Invalid option: -$OPTARG"
                exit 1
                                ;;
        : ) echo "Missing argument for -${OPTARG}" >&2
                exit 1
                ;;
   esac
done

esearch -db "${DATABASE}" -query " "${REFERENCES}" AND "${TAXA}" " | efetch -format fasta > "${DB_NAME}_esearch.fasta"
