#/bin/bash
#module load cutadapt/1.18-foss-2018b-Python-3.6.6

#You can get your primers reverse complement in this website:
#http://arep.med.harvard.edu/labgc/adnan/projects/Utilities/revcomp.html

module --force purge
module load StdEnv
module load cutadapt/2.10-GCCcore-9.3.0-Python-3.8.2


PRIMER_F1="GCHCCHGAYATRGCHTTYCC"
PRIMER_R1="TCDGGRTGNCCRAARAAYCA"
PRIMER_F1_RC="GGRAADGCYATRTCDGGDGC"
PRIMER_R1_RC="TGRTTYTTYGGNCAYCCHGA"
MIN_F1=$(( ${#PRIMER_F1} * 2 / 3 ))
MIN_R1=$(( ${#PRIMER_R1} * 2 / 3 ))
MIN_LEN="50"
THREADS="4"

#CHECK AND EDIT THE ADDRESS FOR THE DEMULTIPLEXED SAMPLES.
#for sequential structure:
	#IF YOU ARE RUNNING SEQUENTIALLY IN AN UNIQUE FOLDER, USE:
#for file in demulti_linked/*_LA.fq;
for file in /cluster/projects/nn9623k/metapipe/2_demulti/demulti_linked/*_LA.fq; do pre="$(basename $file _LA.fq)"; echo $pre; cutadapt -j ${THREADS} -a file:Barcodes_LA3.fa -a file:Barcodes_LA1.fa -a file:Barcodes_LA2.fa --discard-untrimmed --minimum-length ${MIN_LEN} -o ${pre}_trim1.fq $file; done;


for f in *_trim1.fq; do pre="$(basename $f _trim1.fq)"; echo $pre; cutadapt -j ${THREADS} -a "^${PRIMER_F1}...${PRIMER_R1_RC}" -O "${MIN_F1}" -a "^${PRIMER_R1}...${PRIMER_F1_RC}" -O "${MIN_F1}" --minimum-length ${MIN_LEN} -o ${pre}_trim2.fq $f; done;

mkdir clipped
mv *.fq clipped/



