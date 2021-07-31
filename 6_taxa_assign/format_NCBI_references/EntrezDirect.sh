#!/bin/bash

DATABASE=''
TAXAID=''
QUERY=''
ORGANISM=''
DB_NAME=''
usage () {
        echo "##################################################"
        echo " "
        echo "Download reference sequences in fasta format."
        echo "Entrez Direct NCBI command line tools"
        echo " "
        echo "Usage: $0 [-d nuccore|protein] [-t taxaid] [-q query] [-o output]"
        echo " "
        echo "-d     NCBI database: 'nuccore' (nucleotide) or 'protein'"
        echo "-t     Taxa ID in the format txid85472"
	echo "-o     Name for the local database."
        echo "-q     Expected genomic target"
        echo "-h     Print this Help."
        echo " "
        echo "##################################################"
                1>&2; exit 1;
}
while getopts "d:q:t:o:h" option; do
        case $option in
        d) DATABASE="${OPTARG}"
                ;;
        t) TAXAID="${OPTARG}"
                ;;
        q) QUERY="${OPTARG}"
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

esearch -db ${DATABASE} -query "${TAXAID} [ORGN] AND ${QUERY}" | efetch -format fasta > "${DB_NAME}_esearch.fasta"


