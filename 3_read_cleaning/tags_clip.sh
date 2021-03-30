#/bin/bash

MIN_LEN="80"
THREADS="1"


usage () {
        echo "##################################################"
        echo " "
	echo "Remove tags from demultiplexed sample files, without 3'-5' specific orientation."
	echo "The tags mapping file must be in tab separated text file, with 3 columns:"
	echo "Sample1	ACGT	ACGT"
        echo "Sample2   ACGT    ACGT"
	echo "..."
	echo "Usage: $0 [-m mapping file] [-l int] [-t threads]"
	echo "-p     complete directory where the demultiplexed samples are"
        echo "-b     mapping_file_tab_3fields.txt"
        echo "-l     minimum length after trimming"
        echo "-t     number of threads"
        echo " "
        echo "##################################################"
                1>&2; exit 1;
}

while getopts "p:b:l:t:h" option; do
        case $option in
	p) DIR=${OPTARG}
                ;;	
	b) TAGS=${OPTARG}
                ;;
	l) MIN_LEN="${OPTARG}"
                ;;
	t) THREADS=${OPTARG}
                ;;
	h | *) usage
                exit 0
                ;;
        \?) echo "Invalid option: -$OPTARG"
                exit 1
                ;;
        : ) echo "Missing argument for -${OPTARG}" >&2
                exit 1
                ;;
   esac
done


module --force purge
module load StdEnv
module load cutadapt/2.10-GCCcore-9.3.0-Python-3.8.2

cat ${TAGS} | cut -f 1,2 | awk '{print ">"$1"\n"$2}' > "${TMP1}"
cat ${TAGS} | cut -f 1,2 | tr ACGTacgt TGCAtgca | rev | awk '{print ">"$2"\n"$1}' > "${TMP2}"
cat ${TAGS} | cut -f 1,3 | awk '{print ">"$1"\n"$2}' > "${TMP3}"
cat ${TAGS} | cut -f 1,3 | tr ACGTacgt TGCAtgca | rev | awk '{print ">"$2"\n"$1}' > "${TMP4}"

for file in ${DIR}/*.fq; do pre="$(basename $file .fq)"; echo $pre; cutadapt --quiet -j ${THREADS} --no-indels -b file:${TMP1} -b file:${TMP2} -b file:${TMP3} -b file:${TMP4} --discard-untrimmed --minimum-length ${MIN_LEN} $file > ${pre}_tags_clip.fq; done;

mkdir tags_clipped
mv *_tags_clip.fq tags_clipped/



