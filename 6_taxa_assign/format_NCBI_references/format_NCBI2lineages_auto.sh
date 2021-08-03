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
	echo "format of the original NCBI references sequences input:"
	echo "head NCBI_references.fasta"
	echo ">LC384553.1 Scutellaria orientalis genes for 18S rRNA and ITS1"
	echo "TGAACCATCGAGTCTTTGAACGCAAGT...TGCGCCCGAACCCATCAGGCCGAGGGCAC..."
	echo "the NCBI header will be formatted by this script."
	echo "This script needs the two embedded Perl scripts to run:"
        echo "format_NCBI2lineages_dups.pl and format_NCBI2lineages_edit.pl"
        echo "DO NOT EDIT THEM."
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

TMPr=$(mktemp --tmpdir=".")
TMPc=$(mktemp --tmpdir=".")
echo "References file: $REFERENCES"
echo "head NCBI_references.fasta:"
head "${$REFERENCES}" > "${TMPr}"
echo "$TMPr"
echo " "
echo "Total number of original NCBI downloaded sequences:"
grep -c "^>" $REFERENCES > "${TMPc}"
echo "$REFERENCES has $TMPc sequences."
echo " "
echo "Final formatted output filename: $PREFIX.uniq.fasta"

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

echo "Preparation check up:"
echo "You should have downloaded the nucl_gb.accession2taxid.gz, see README.format"
echo "type: wget https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz"
echo " "
echo "You also need taxdb.btd and taxdb.bti files"
echo "type: wget https://ftp.ncbi.nlm.nih.gov/blast/db/"
echo "and extract them, type: tar -xvf taxdb.tar.gz"
echo "make sure you have the latest script, copied from this page:"
echo "format_NCBI2lineages_edit.pl"
echo "format_NCBI2lineages_dups.pl"
echo " "

###extract accession code from NCBI references
echo "extracting accession code from NCBI references..."
echo " "
seqkit seq --quiet -n -i "${REFERENCES}" > "${TMP1}"
TMPa=$(mktemp --tmpdir=".")
TMPw=$(mktemp --tmpdir=".")
head -3 "${TMP1}" > "${TMPa}"
echo "$TMPa"
wc "${TMP1}" > "${TMPw}"
echo "A total of $TMPw accession codes were extracted."
echo "..."

###join accession + taxid
echo "Parsing accession to taxid..."
echo "this can take a long time (please use srun or run_format2lineage.slurm)"
echo "make sure that '--account=nn9813k' is your user project! Keep 16G memory."
echo "srun --ntasks=1 --mem-per-cpu=16G --time=01:55:00 --qos=devel --account=nn9813k --pty bash -i"
zcat nucl_gb.accession2taxid.gz | grep -w -f "${TMP1}" | cut -f 2,3 | tee "${TMP2}"
TMPt=$(mktemp --tmpdir=".")
TMPw2=$(mktemp --tmpdir=".")
head -3 "${TMP2}" > "${TMPt}"
wc "${TMP1}" > "${TMPw2}"
echo "$TMPt"
echo " "
echo "A total of $TMPw2 accession + taxids were joined."
echo "..."

####get lineage
####cat "${TMP2}" | taxonkit lineage -i 2 | sed 1d | cut -f 1,3 | tee "${TMP3}"
####lineage formatted to kingdom,phyla, class... as preferentially used by Phyloseq
cat "${TMP2}" | taxonkit lineage -i 2 | taxonkit reformat -i 3 | sed 1d | cut -f 1,4 | tee "${TMP3}"
TMPlin=$(mktemp --tmpdir=".")
TMPlin2=$(mktemp --tmpdir=".")
head -3 "${TMP3}" > "${TMPlin}"
echo "${TMPlin}"
echo " "
echo "The taxonomic lineage was added to a total of $TMPlin2 accession codes."
echo "..."

###change semicolon to pipe --> build tax table preference
sed 's/;/\|/g' "${TMP3}" > "${TMP4}"
TMPp=$(mktemp --tmpdir=".")
head -3 "${TMP4}" > "${TMPp}"
echo "${TMPp}"
echo "..."

###remove NCBI sequences header, leaving only accession code
sed '/^>/ s/ .*//' ${REFERENCES} > "${TMP5}"
TMPh=$(mktemp --tmpdir=".")
TMPw3=$(mktemp --tmpdir=".")
head "${TMP5}" > "${TMPh}"
grep -c "^>" "${TMP5}" > "${TMPw3}"
echo "reformatted NCBI sequences fasta:"
echo "${TMPh}"
echo "..."
echo "A total of $TMPw3 fasta headers were cleaned."
echo " "

#add a '+' sign in binomial species last lineage field from pipe separated lineage file
perl format_NCBI2lineages_edit.pl "${TMP4}"
TMPe=$(mktemp --tmpdir=".")
head -3 edit_lineage.out > "${TMPe}"
echo "final editing of NCBI lineage:"
echo "${TMPe}"
echo "..."

echo "joining the edited lineage file with the edited NCBI seq file,"
echo "creating the final fasta with lineage headers..."
echo " "
#this final commands join the final edited lineage file with the edited NCBI sequences file and create the first seq fasta with lineage headers
awk '/>/ {getline seq} {sub (">","",$0);print $0, seq}' "${TMP5}" | sort -k1 | join -1 1 -2 1 - <(sort -k1 edit_lineage.out) -o 1.1,2.2,1.2 | awk '{print ">"$1" "$2"\n"$3}' > "${TMP6}" 

module --force purge
module load StdEnv
module load BioPerl/1.7.2-GCCcore-8.2.0-Perl-5.28.1

#remove duplicates and linearize sequences
perl format_NCBI2lineages_dups.pl "${TMP6}"
seqkit seq --quiet -w 0 "uniq_sequences.fasta" > "${$prefix}.uniq.fasta"
TMPd=$(mktemp --tmpdir=".")
TMPw4=$(mktemp --tmpdir=".")
head -6 "${$prefix}.uniq.fasta" > "${TMPd}"
grep -c "^>" "${$prefix}.uniq.fasta" > "${TMPw4}"
echo "duplicates removed and sequences linearized:"
echo "${TMPd}"
echo "..."
echo "The final formatted references fasta has a total of $TMPw4 sequences."
echo " "
echo "SUMMARY:"
echo "The original $REFERENCES file has $TMPc sequences,"
echo "A total of $TMPw accession codes were extracted from the reference fasta,"
echo "A total of $TMPw2 accession + taxids were joined,"
echo "The taxonomic lineage was added to a total of $TMPlin2 accession codes,"
echo "A total of $TMPw3 fasta headers were cleaned to receive the lineages,"
echo "The final formatted references fasta with lineages has a total of $TMPw4 sequences."
echo " "
echo "CONGRATULATIONS! All format pipeline was succesfully performed."
#rm tmp*

