#/bin/bash

PRIMER_F1=''
PRIMER_R1=''
PRIMER_F1_RC=''
PRIMER_R1_RC=''
MIN_LEN=''
THREADS=''
TAGS=''
QUAL="fastq_quality_file"
DIR=''
EE=''

usage () {
        echo "##################################################"
        echo " "
        echo "Remove tags and primers from demultiplexed sample files and processes a series of format and cleaning steps, generating the quality file necessary for clustering, the fasta converted sample files and dereplicated by sample files.."
	echo " "
	echo "You can get your primers reverse complement in this website:"
	echo "http://arep.med.harvard.edu/labgc/adnan/projects/Utilities/revcomp.html"
	echo " "
        echo "Usage: $0 [-F primerF] [-R primerR] [-f RCprimerF] [-r RCprimerR] [-l 50] [-p pwd] [-e 0.2] [-b barcode.txt] [-q name] [-t threads]"
        echo "-F     paste your primerF"
        echo "-R     paste your primerR"
        echo "-f     paste your reverse complement primerF"
        echo "-r     paste your reverse complement primerR"
        echo "-l     minimum length after trimming"
	echo "-p     complete directory where the demultiplexed samples are"
	echo "-e     maximum error rate allowed, higher more flexible"
	echo "-b     barcodes.txt, the original mapping file used as input for perl preparing_tags_LCPI.pl script."
	echo "-t     number of threads"
        echo "-h     Print this Help"
        echo " "
        echo "##################################################"
                1>&2; exit 1;
}

while getopts "F:R:f:r:l:p:e:b:t:h" option; do
        case $option in
        F) PRIMER_F1="${OPTARG}"
                ;;
        R) PRIMER_R1=${OPTARG}
                ;;
        f) PRIMER_F1_RC="${OPTARG}"
                ;;
        r) PRIMER_R1_RC=${OPTARG}
                ;;
        l) MIN_LEN="${OPTARG}"
                ;;
        p) DIR=${OPTARG}
                ;;
        e) EE=${OPTARG}
                ;;
        b) TAGS=${OPTARG}
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

TMP1=$(mktemp --tmpdir=".")
TMP2=$(mktemp --tmpdir=".")
TMP3=$(mktemp --tmpdir=".")
TMP4=$(mktemp --tmpdir=".")
TMP5=$(mktemp --tmpdir=".")

cat ${TAGS} | cut -f 1,2 | awk '{print ">"$1"\n"$2}' > "${TMP1}"
cat ${TAGS} | cut -f 1,2 | tr ACGTacgt TGCAtgca | rev | awk '{print ">"$2"\n"$1}' > "${TMP2}"
cat ${TAGS} | cut -f 1,3 | awk '{print ">"$1"\n"$2}' > "${TMP3}"
cat ${TAGS} | cut -f 1,3 | tr ACGTacgt TGCAtgca | rev | awk '{print ">"$2"\n"$1}' > "${TMP4}"

module --force purge
module load StdEnv
module load cutadapt/2.10-GCCcore-9.3.0-Python-3.8.2

for file in ${DIR}/*.fq; do pre="$(basename $file .fq)"; echo $pre; cutadapt --quiet -j ${THREADS} --no-indels -b file:${TMP1} -b file:${TMP2} -b file:${TMP3} -b file:${TMP4} -b ${PRIMER_F1} -b ${PRIMER_R1} -b ${PRIMER_F1_RC} -b ${PRIMER_R1_RC} -e ${EE} --discard-untrimmed --minimum-length ${MIN_LEN} $file > ${pre}_clip.fq; done;

module --force purge
module load StdEnv
module load VSEARCH/2.13.4-iccifort-2019.1.144-GCC-8.2.0-2.31.1

for file in *_clip.fq; do pre="$(basename $file _clip.fq)"; vsearch --quiet --threads ${THREADS} --fastq_filter $file --fastq_maxns 0 --relabel_sha1 --eeout --fastaout ${pre}_f1.fasta --fastqout ${pre}_f1.fq; done;

for f in *_f1.fq; do pre="$(basename $f _f1.fq)"; echo $pre; \
        sed 'n;n;N;d' $f | \
        awk 'BEGIN {FS = "[;=]"}
           {if (/^@/) {printf "%s\t%s\t", $1, $3} else {print length($1)}}' | \
        tr -d "@" >> "${TMP5}"
done < "${TAGS}"

sort -k3,3n -k1,1d -k2,2n "${TMP5}" | uniq --check-chars=40 > ${QUAL}.qual

for file in *_f1.fasta; do pre="$(basename $file _f1.fasta)"; echo $pre; vsearch --quiet --derep_fulllength $file --sizeout --fasta_width 0 --relabel_sha1 --output ${pre}_dp.fasta; done;

mkdir clipped
mv *_clip.fq clipped/

mkdir fastas
mv *_f1.fasta fastas

mkdir derep_sample
mv *_dp.fasta derep_sample

rm *_f1.fq

rm ${TMP1} ${TMP2} ${TMP3} ${TMP4} ${TMP5}
