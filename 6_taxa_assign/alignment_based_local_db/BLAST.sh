module --force purge
module load StdEnv
module load BLAST+/2.10.1-iimpi-2020a

FASTA="COI_Arthropoda_global_dp_2f_representatives.fas"
NCBI_DB="/cluster/shared/databases/blast/latest/nt"
LOCAL_DB="Arthropoda_COI.uniq.fasta"
SIMILARITY_INT="0.9"
COVERAGE_INT="0.6"
HITS_PER_SUBJECT="1"
EVALUE="0.001"
THREADS="1"
OUT="Arthropoda_COI"
TASK="megablast"

###BLAST LOCAL DATABASE
#makeblastdb -in $LOCAL_DB -dbtype nucl -parse_seqids

blastn -query $FASTA \
  -task $TRY \
  -db $NCBI_DB \
  -num_threads $THREADS \
  -perc_identity $SIMILARITY_INT  \
  -qcov_hsp_perc $COVERAGE_INT  \
  -max_hsps $HITS_PER_SUBJECT \
  -max_target_seqs $HITS_PER_SUBJECT  \
  -parse_deflines \
  -evalue $EVALUE \
  -outfmt "6 qseqid pident stitle sseqid sscinames" >  ${OUT}_blast.tab
