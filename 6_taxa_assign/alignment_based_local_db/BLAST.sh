module --force purge
module load StdEnv
module load BLAST+/2.10.1-iimpi-2020a

FASTA="my_training_set_global_dp_1f_representatives.fas"
NCBI_DB="/cluster/shared/databases/blast/25-10-2019/nt"
LOCAL_DB="Arthropoda_COI.uniq.fasta"
SIMILARITY_INT="90"
COVERAGE_INT="40"
HITS_PER_SUBJECT="1"
EVALUE="0.001"
THREADS="4"
PREFIX_IN="COI"
PREFIX_DB="Arthropoda"

###BLAST LOCAL DATABASE
makeblastdb -in $LOCAL_DB -dbtype nucl -parse_seqids

blastn -query $FASTA \
  -task megablast \
  -db $LOCAL_DB \
  -num_threads $THREADS \
  -perc_identity $SIMILARITY_INT  \
  -qcov_hsp_perc $COVERAGE_INT  \
  -max_hsps $HITS_PER_SUBJECT \
  -max_target_seqs $HITS_PER_SUBJECT  \
  -parse_deflines \
  -evalue $EVALUE \
  -outfmt "6 qseqid pident stitle sseqid sscinames" >  ${PREFIX_IN}_${PREFIX_DB}_local_blast.tab
  
###REMOTE NCBI NT DATABASE SEARCH
#blastn -query ${FASTA} 
       #-task megablast -db $NCBI_DB  \
       #-perc_identity $SIMILARITY_INT  \
       #-qcov_hsp_perc $COVERAGE_INT \
       #-max_hsps $HITS_PER_SUBJECT \
       #-max_target_seqs $HITS_PER_SUBJECT  \
       #-evalue $EVALUE \
       #-parse_deflines \
       #-num_threads $THREADS \
       #-outfmt "6 qseqid sscinames sseqid staxids stitle pident qcovs evalue" > ${PREFIX_IN}_NT_blast.log
