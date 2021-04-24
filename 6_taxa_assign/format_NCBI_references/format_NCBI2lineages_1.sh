#!/bin/bash

REFERENCES="Teleostei_12S_teste.fasta"
PREFIX="Teleostei_12S"

module --force purge
module load StdEnv
module load SeqKit/0.11.0

#extract accession
seqkit seq --quiet -n -i "${REFERENCES}" > "${PREFIX}_reference.acc"

#extract accession -> taxid
echo "Parsing accession to taxid..."
zcat nucl_gb.accession2taxid.gz | grep -w -f "${PREFIX}_reference.acc" | cut -f 2,3 | tee "${PREFIX}_reference.acc2taxid"

#get lineage
cat "${PREFIX}_reference.acc2taxid" | taxonkit lineage -i 2 | sed 1d | cut -f 1,3 | tee "${PREFIX}_reference.acc2taxid2lineage"

#get lineage in format 'kingdom,phylum...species'
cat "${PREFIX}_reference.acc2taxid" | taxonkit lineage -i 2 | taxonkit reformat -i 3 | sed 1d | cut -f 1,4 | tee "${PREFIX}_reference.acc2taxid2lineage"

#pipe as delimiter
sed 's/;/\|/g' "${PREFIX}_reference.acc2taxid2lineage" > "${PREFIX}_reference.acc2taxid2lineage2"

#clean fasta header
sed '/^>/ s/ .*//' ${REFERENCES} > "${PREFIX}_reference_acc.fasta"

#linearize fasta
seqkit seq --quiet -w 0 "${PREFIX}_reference_acc.fasta" > "${PREFIX}_reference_acc_ed1.fasta"

#FINAL HEADER FORMAT
perl edit_lineage.pl "${PREFIX}_reference.acc2taxid2lineage2"

awk '/>/ {getline seq} {sub (">","",$0);print $0, seq}' "${PREFIX}_reference_acc_ed1.fasta" | sort -k1 | join -1 1 -2 1 - <(sort -k1 edit_lineage.out) -o 1.1,2.2,1.2 | awk '{print ">"$1" "$2"\n"$3}' > "${PREFIX}_lineage.fasta" 

module --force purge
module load StdEnv
module load BioPerl/1.7.2-GCCcore-8.2.0-Perl-5.28.1

#remove duplicates
perl remove_dups.pl "${PREFIX}_lineage.fasta" "${PREFIX}"

mkdir format_out
mv "${PREFIX}"* format_out
rm edit_lineage.out








