TABLE="my_training_set_OTU_table_complete.tab"
FILTERED="${TABLE/.tab/_f1.tab}"
CUT2PHYLOSEQ="${FILTERED/_f1.tab/_f1_cut2phyloseq.tab}"
TARGET="Eukaryota"

#PRINT ALL FIELDS FILTERED
head -n 1 "${TABLE}" > "${FILTERED}"
grep "${TARGET}" "${TABLE}" | \
    awk '$7 == "N" && $9 <= 0.0002 && ($2 >= 3 || $8 >= 2)' >> "${FILTERED}"

awk '{ ratio = $2/$3; print $0, ratio }' my_samples_quality_file.qual > my_samples_quality_file.ee

#PRINT ONLY AMPLICON AND SAMPLES TO LOAD IN PHYLOSEQ:
cat "${FILTERED}" | cut -f 4,14- | sed 's/_dp//g' > "${CUT2PHYLOSEQ}"
