#!/bin/bash

INPUT_FILE=''
TARGET=''
THREADS='4'
MAXREJECTS='32'
IDENTITY='0.85'
ASSIGNMENTS=''
NULL="/dev/null"
TMP1=$(mktemp --tmpdir=".")
TMP2=$(mktemp --tmpdir=".")
DIR=''

## Usage
usage () {
	echo "##################################################"
        echo " "	
	echo "Usage: ${0} [-q query.fasta] [-d references.fasta] [-o output] [-p pwd]"
	echo "-q     OTUs fasta file, the output from clustering step"
	echo "-d     references sequences formatted"
	echo "-o     output name for the final assignments file."
	echo "-p     current work directory."
	echo "-h     print this help"
	echo " "
        echo "##################################################"
                1>&2; exit 1;

}

while getopts "q:d:o:p:h" option; do
        case $option in
        q) INPUT_FILE="${OPTARG}"
                ;;
        d) TARGET="${OPTARG}"
	        ;;
	o) ASSIGNMENTS="${OPTARG}"
		;;
	p) DIR="${OPTARG}"
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

## Check arguments
if [[ -z "${INPUT_FILE}" ]] ; then
        echo -e "You must specify a fasta file.\n" 1>&2
        usage
        exit 1
fi
if [[ -z "${TARGET}" ]] ; then
        echo -e "You must specify a target reference file.\n" 1>&2
        usage
        exit 1
fi
echo " "
echo "##############################################"
echo "Data load ok:"
echo "Query file: $INPUT_FILE"
echo " "
echo "Total sequences:" | grep -c "^>" "${INPUT_FILE}"
echo " " 
echo "##############################################"
echo "References file: $TARGET"
echo " "
echo "##############################################"

module --force purge
module load StdEnv
module load VSEARCH/2.13.4-iccifort-2019.1.144-GCC-8.2.0-2.31.1

sed '/^>/s/;size=/_/' "${INPUT_FILE}" > "${TMP1}"
sed '/^>/s/;$//' "${TMP1}" > "${TMP2}"

# compare environmental sequences to known reference sequences
vsearch --usearch_global "${TMP2}" --threads "${THREADS}" --dbmask none --qmask none --rowlen 0 --notrunclabels --userfields query+id1+target --maxaccepts 0 --maxrejects "${MAXREJECTS}" --top_hits_only --output_no_hits --db "${TARGET}" --id "${IDENTITY}" --iddef 1 --userout "hits.${ASSIGNMENTS}.hits" --log vsearch.log > "${NULL}" 2> "${NULL}"

module --force purge
module load StdEnv
module load Python/3.7.4-GCCcore-8.3.0

FINAL_FILE=${ASSIGNMENTS/.hits/.results}

python3 merge_script.py ${PWD}

for f in results.* ; do
    sort -k2,2nr -k1,1d ${f}
done > ../${FINAL_FILE}

#rm -f results.*
rm tmp*

exit 0
