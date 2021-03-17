


DATABASE="Xyleborus_genus.fasta"
FORMATTED_DB="my_reference_lineage_formated.fasta"


module --force purge
module load StdEnv
module load SeqKit/0.11.0

#extract accession
seqkit seq -n -i "${DATABASE}" | tee my_reference.acc

#extract accession -> taxid
zcat nucl_gb.accession2taxid.gz | grep -w -f my_reference.acc | cut -f 2,3 | tee my_reference.acc2taxid

#get lineage
cat my_reference.acc2taxid | taxonkit lineage -i 2 | sed 1d | cut -f 1,3 | tee my_reference.acc2taxid2lineage

#get lineage in format 'kingdom,phylum...species'
cat my_reference.acc2taxid | taxonkit lineage -i 2 | taxonkit reformat -i 3 | sed 1d | cut -f 1,4 | tee my_reference.acc2taxid2lineage

#pipe as delimiter
sed 's/;/\|/g' my_reference.acc2taxid2lineage > my_reference.acc2taxid2lineage2

#clean fasta header
sed '/^>/ s/ .*//' ${DATABASE} > my_reference_acc.fasta

#linearize fasta
seqkit seq -w 0 my_reference_acc.fasta > my_reference_acc_ed1.fasta

#FINAL HEADER FORMAT
perl edit_lineage.pl

awk '/>/ {getline seq} {sub (">","",$0);print $0, seq}' my_reference_acc_ed1.fasta | sort -k1 | join -1 1 -2 1 - <(sort -k1 final_formated_reference_header.txt) -o 1.1,2.2,1.2 | awk '{print ">"$1" "$2"\n"$3}' > ${FORMATTED_DB} 

module --force purge
module load StdEnv
module load BioPerl/1.7.2-GCCcore-8.2.0-Perl-5.28.1

#remove duplicates
perl remove_dups.pl


##PRIMER CUT, NOT FINISHED
#sequences lowercase
#awk '/^>/ {print($0)}; /^[^>]/ {print(tolower($0))}' Fragment1_acc_ed2.fasta > Fragment1_lineage_formated.fasta

#./references_primer_cut.sh








