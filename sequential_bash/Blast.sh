

module --force purge
module load StdEnv
module load BLAST+/2.10.1-iimpi-2020a

#final query header edition
#sed -e '/^>/ s/;size=/_/' -e '/^>/ s/;$//'  Fragment1_all_samples_1f_representatives.fas > Fragment1_all_samples_2f_representatives.fas

FASTA1="training_set_global_dp_1f_representatives.fas"
FASTA2="training_set_global_dp_2f_representatives.fas"
NCBI_DB="/cluster/shared/databases/blast/25-10-2019/nt"
LOCAL_DB="Xyleborus_lineage_formated.fasta.uniq.fasta"
SIMILARITY_INT="95"
COVERAGE_INT="70"
HITS_PER_SUBJECT="1"
EVALUE="0.0001"
THREADS="8"
#SCRIPT_PATH=/bio/share_bio/utils/renato/QiimePipe
PREFIX_IN="training_set"
PREFIX_DB="Xyleborus"


sed -e '/^>/ s/;size=/_/' -e '/^>/ s/;$//' "${FASTA1}" > "${FASTA2}"

#REMOTE NCBI NT DATABASE SEARCH

#blastn -query ${FASTA} -task megablast -db $NCBI_DB -perc_identity $SIMILARITY_INT -qcov_hsp_perc $COVERAGE_INT -max_hsps $HITS_PER_SUBJECT -max_target_seqs $HITS_PER_SUBJECT -evalue $EVALUE -parse_deflines -num_threads $THREADS -outfmt "6 qseqid sscinames sseqid staxids stitle pident qcovs evalue" > ${PREFIX_IN}_NT_blast.log


###BLAST LOCAL DATABASE
makeblastdb -in $LOCAL_DB -dbtype nucl -parse_seqids
blastn -query $FASTA2 -task megablast -db $LOCAL_DB -num_threads $THREADS -perc_identity $SIMILARITY_INT -qcov_hsp_perc $COVERAGE_INT -max_hsps $HITS_PER_SUBJECT -max_target_seqs $HITS_PER_SUBJECT -parse_deflines -evalue $EVALUE -outfmt "6 qseqid pident stitle sseqid sscinames" >  ${PREFIX_IN}_${PREFIX_DB}_local_blast.tab

