#/bin/bash

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
MIN_LEN="30"

#CHECK AND EDIT THE ADDRESS FOR THE DEMULTIPLEXED SAMPLES.
#for sequential structure:
	#IF YOU ARE RUNNING SEQUENTIALLY IN AN UNIQUE FOLDER, USE:
#for file in demulti_linked/*_LA.fq;
for file in /cluster/projects/nn9813k/metapipe/ITS/demulti_linked/*_LA.fq; do pre="$(basename $file _LA.fq)"; echo $pre; cutadapt --quiet -a file:Barcodes_LA1.fa -a file:Barcodes_LA2.fa -a file:Barcodes_LA3.fa --action trim --trim-n --max-n 0 --minimum-length ${MIN_LEN} -o ${pre}_trim1.fq --untrimmed-output ${pre}_bad_trim1.fq $file; done;
mkdir adapter_clip
mkdir adapter_clip/BAD
mv *_bad_trim1.fq adapter_clip/BAD
mv *_trim1.fq adapter_clip

for f in /adapter_clip/*_trim1.fq; do pre="$(basename $f _trim1.fq)"; echo $pre; cutadapt --quiet -a "${PRIMER_F1}...${PRIMER_R1_RC}" -O "${MIN_F1}" -a "${PRIMER_R1}...${PRIMER_F1_RC}" -O "${MIN_F1}" --action=trim --minimum-length ${MIN_LEN} -o ${pre}_trim2.fq --untrimmed-output ${pre}_bad_trim2.fq $f; done;
mkdir primer_clip
mkdir primer_clip/BAD
mv *_bad_trim2.fq primer_clip/BAD
mv *_trim2.fq primer_clip/



