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
MIN_R1=$(( ${#PRIMER_R1} * 1 / 2 ))
MIN_LEN="50"
THREADS="4"

#CHECK AND EDIT THE ADDRESS FOR THE DEMULTIPLEXED SAMPLES.
#for sequential structure:
        #IF YOU ARE RUNNING SEQUENTIALLY IN AN UNIQUE FOLDER, USE:
#for file in demulti_linked/*_LA.fq;

for i in /cluster/work/users/marlaux/GITHUB/METAPIPE/2_demulti/demulti_comb/*_1.fq; do pre="$(basename $i _1.fq)"; echo $pre; cutadapt -j ${THREADS} -a file:Barcodes_F.fa -A file:Barcodes_R.fa --discard-untrimmed --minimum-length ${MIN_LEN} -o ${pre}_trim1_1.fq -p ${pre}_trim1_2.fq $i_1.fq $i_2.fq; done;

for f in *_trim1_1.fq; do pre="$(basename $f _trim1_1.fq)"; echo $pre; cutadapt -j ${THREADS} -a "${PRIMER_F1}" -a "${PRIMER_R1}" -O ${MIN_F1} -A "${PRIMER_R1_RC}" -a "${PRIMER_R1_RC}" -O "${MIN_R1}" --minimum-length ${MIN_LEN} -o ${pre}_trim2_1.fq -p ${pre}_trim2_2.fq $f_trim1_1.fq $f_trim1_2.fq; done;

mkdir clipped
mv *.fq clipped
