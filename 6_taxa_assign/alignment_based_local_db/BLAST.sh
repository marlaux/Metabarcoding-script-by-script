module --force purge
module load StdEnv
module load BLAST+/2.10.1-iimpi-2020a

FASTA="COI_Arthropoda_global_dp_2f_representatives.fas"
NCBI_DB="/cluster/shared/databases/blast/25-10-2019/nt"
#LOCAL_DB="Arthropoda_COI.uniq.fasta"
SIMILARITY_INT="0.9"
COVERAGE_INT="0.6"
HITS_PER_SUBJECT="1"
EVALUE="0.001"
THREADS="1"
PREFIX_IN="COI"
PREFIX_DB="Arthropoda"
TRY="megablast"
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
  -outfmt "6 qseqid pident stitle sseqid sscinames" >  ${PREFIX_IN}_${PREFIX_DB}_NT_blast.tab
