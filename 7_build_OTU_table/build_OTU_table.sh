

module load Python/2.7.15-GCCcore-8.2.0

FASTA="my_training_set_global_dp.fas"
SCRIPT="OTU_contingency_table.py"
STATS="${FASTA/.fas/.stats}"
SWARMS="${FASTA/.fas/.swarms}"
REPRESENTATIVES="${FASTA/.fas/_1f_representatives.fas}"
UCHIME="${FASTA/.fas/_1f_representatives.uchime}"
ASSIGNMENTS="Blast_results_formatted2OTUtable.tab"
QUALITY="my_training_set_quality_file.qual"
OTU_TABLE="my_training_set_OTU_table_complete.tab"

python \
    "${SCRIPT}" \
    "${REPRESENTATIVES}" \
    "${STATS}" \
    "${SWARMS}" \
    "${UCHIME}" \
    "${QUALITY}" \
    "${ASSIGNMENTS}" \
    /cluster/projects/nn9623k/metapipe/3_read_cleaning/dereplicated/*_dp.fasta > "${OTU_TABLE}"



