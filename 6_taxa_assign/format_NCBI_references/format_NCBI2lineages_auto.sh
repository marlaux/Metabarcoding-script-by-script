#!/bin/bash

REFERENCES=''
PREFIX=''

## Usage
usage () {
	echo "##################################################"
	echo " "
	echo "Format and include taxonomic lineage in reference"
	echo "sequences headers downloaded from NCBI taxonomy."
	echo "This script will generate a multifasta file which"
	echo "will be the input for makeblastdb to build your"
	echo "local database to run in BLAST."
	echo " "
        echo "Usage: $0 [-r fasta] [-p output_prefix]" 
	echo "-r     references_downloaded_fromNCBI.fasta"
	echo "-p     prefix to output filenames"
	echo "-h     Print this Help." 
	echo " "
	echo "##################################################"	
		1>&2; exit 1;
}

while getopts "r:p:h" option; do
        case $option in
	r) REFERENCES="${OPTARG}"
                ;;
	p) PREFIX=${OPTARG}
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

shift "$(( OPTIND - 1 ))"

if [ -z "$REFERENCES" ] || [ -z "$PREFIX" ] ; then
        echo 'Missing argument' >&2
        exit 1
fi

echo "References file: $REFERENCES"
echo "Formatted references: $PREFIX.uniq.fasta"

TMP1=$(mktemp --tmpdir=".")
TMP2=$(mktemp --tmpdir=".")
TMP3=$(mktemp --tmpdir=".")
TMP4=$(mktemp --tmpdir=".")
TMP5=$(mktemp --tmpdir=".")
TMP6=$(mktemp --tmpdir=".")
TMP7=$(mktemp --tmpdir=".")

module --force purge
module load StdEnv
module load SeqKit/0.11.0

seqkit seq --quiet -n -i "${REFERENCES}" > "${TMP1}"

echo "Parsing accession to taxid..."
zcat nucl_gb.accession2taxid.gz | grep -w -f "${TMP1}" | cut -f 2,3 | tee "${TMP2}"
cat "${TMP2}" | taxonkit lineage -i 2 | sed 1d | cut -f 1,3 | tee "${TMP3}"
cat "${TMP2}" | taxonkit lineage -i 2 | taxonkit reformat -i 3 | sed 1d | cut -f 1,4 | tee "${TMP3}"
sed 's/;/\|/g' "${TMP3}" > "${TMP4}"
sed '/^>/ s/ .*//' ${REFERENCES} > "${TMP5}"

seqkit seq --quiet -w 0 "${TMP5}" > "${TMP6}"

perl format_NCBI2lineages_edit.pl "${TMP4}"

awk '/>/ {getline seq} {sub (">","",$0);print $0, seq}' "${TMP6}" | sort -k1 | join -1 1 -2 1 - <(sort -k1 edit_lineage.out) -o 1.1,2.2,1.2 | awk '{print ">"$1" "$2"\n"$3}' > "${TMP7}" 

module --force purge
module load StdEnv
module load BioPerl/1.7.2-GCCcore-8.2.0-Perl-5.28.1

perl format_NCBI2lineages_dups.pl "${TMP7}" "${PREFIX}_lineage"

rm tmp*

