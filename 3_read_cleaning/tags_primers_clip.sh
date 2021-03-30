#/bin/bash
#module load cutadapt/1.18-foss-2018b-Python-3.6.6

#You can get your primers reverse complement in this website:
#http://arep.med.harvard.edu/labgc/adnan/projects/Utilities/revcomp.html

echo "#############################################"
echo " "
echo "REMOVES TAGS AND PRIMERS IN DUAL INDEX LINKED"
echo "MODE IN THE PROPER ORIENTATION"
echo " "
echo "#############################################"

module --force purge
module load StdEnv
module load cutadapt/2.10-GCCcore-9.3.0-Python-3.8.2


PRIMER_F1="GCHCCHGAYATRGCHTTYCC"
PRIMER_R1="TCDGGRTGNCCRAARAAYCA"
PRIMER_F1_RC="GGRAADGCYATRTCDGGDGC"
PRIMER_R1_RC="TGRTTYTTYGGNCAYCCHGA"
DIRECTORY="/cluster/work/users/marlaux/GITHUB/METAPIPE/2_demulti/demulti_linked"
SUFFIX="_LAb.fq"
TAGS1="Barcodes_LA1.fa"
TAGS2="Barcodes_LA2.fa"
TAGS3="Barcodes_LA3.fa"
MIN_F1=$(( ${#PRIMER_F1} * 2 / 3 ))
MIN_R1=$(( ${#PRIMER_R1} * 2 / 3 ))
MIN_LEN="50"
THREADS="4"
TMP1=$(mktemp --tmpdir=".")


mkdir clipped

for file in ${DIRECTORY}/*${SUFFIX}; do pre="$(basename $file ${SUFFIX})"; echo $pre; \
	cutadapt --quiet -j ${THREADS} \
	-a file:${TAGS3} -a file:${TAGS2} -a file:${TAGS1}	\
	--discard-untrimmed \
	--minimum-length ${MIN_LEN} 	\
	$file > ${TMP1}; 
	cutadapt --quiet -j ${THREADS}	\
	-a "^${PRIMER_F1}...${PRIMER_R1_RC}" -O ${MIN_F1} \
	-a "^${PRIMER_R1}...${PRIMER_F1_RC}" -O ${MIN_F1} \
	--minimum-length ${MIN_LEN}	\
	${TMP1} > ${pre}_clip.fq 2> ${pre}.log; \
	rm ${TMP1}; mv ${pre}_clip.fq ${pre}.log clipped/
done;





