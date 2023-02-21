#/bin/bash

TAGS=''
PRIMER_F=''
PRIMER_R=''
PREFIX=''
DIR=''
PRIMER_F_RC=''
PRIMER_R_RC=''
MIN_F=$(( ${#PRIMER_F} * 2 / 3 ))
MIN_R=$(( ${#PRIMER_R} * 2 / 3 ))
MIN_LEN=''
EE=''

usage () {
        echo "##################################################"
        echo "TAGS AND PRIMERS CLIPPING"
        echo "##################################################"
	echo "get your primer's reverse complement in this website:"
	echo "http://arep.med.harvard.edu/labgc/adnan/projects/Utilities/revcomp.html"
	echo " "
        echo "Usage: ${0} [-b tags file] [-F 5' primer 'Forward'] [-R 3' primer 'Reverse'] [-f revcom 5' primer] [-r revcom 3' primer] [-e 0.1] [-p prefix] [-l amplicon min length] [-d path to demultiplexed samples]"
        echo "-b     barcodes/tags mapping file (used in demultiplexing step)"
        echo "-F     5' primer (forward direction, like in your primers design file)"
        echo "-R     3' primer (forward direction)"
        echo "-f     5' primer reverse complement"
        echo "-r     3' primer reverse complement"
	echo "-e     maximum error rate (the same used for demultiplexing)"
	echo "Error rate: allowed errors/adapter or primer length. 2 errors in a 12 bp tag = 2/12 = 0.17"
	echo "4 errors in a 26bp degenerated primer = 4/26 = 0.16, 2 errors in a 20bp primer = 0.1 (Cutadapt default)."
        echo "-p     PREFIX to quality file (it MUST be the SAME prefix throughout the ENTIRE PIPELINE)"
        echo "-l     minimum length for the final amplicon"
        echo "-d     path to demultiplexed samples directory. Use pwd."
        echo "-h     print this help"
        echo " "
        echo "##################################################"
                1>&2; exit 1;

}
while getopts "b:F:R:f:r:e:p:d:l:h" option; do
        case $option in
        b) TAGS="${OPTARG}"
                ;;
        F) PRIMER_F="${OPTARG}"
                ;;
        R) PRIMER_R="${OPTARG}"
                ;;
        f) PRIMER_F_RC="${OPTARG}"
                ;;
        r) PRIMER_R_RC="${OPTARG}"
                ;;
	e) EE="${OPTARG}"
		;;
        p) PREFIX="${OPTARG}"
                ;;
        d) DIR="${OPTARG}"
                ;;
        l) MIN_LEN="${OPTARG}"
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

mkdir -p clip_out
mkdir -p clip_out/tag_clip
for file in "${DIR}"/*_LA.fq; do LA="$(basename $file _LA.fq)"; cutadapt -j 8 --quiet -e $EE -a file:Tags_LA1.fa -a file:Tags_LA2.fa -a file:Tags_LA3.fa --action=trim --trim-n --max-n 0 --minimum-length $MIN_LEN -o ${LA}_trim1.fq $file; done;

for f in *_trim1.fq; do trim1="$(basename $f _trim1.fq)"; cutadapt -j 8 --quiet -e $EE -a "${PRIMER_F}...${PRIMER_R_RC}" -O $MIN_F -a "${PRIMER_R}...${PRIMER_F_RC}" -O $MIN_R --action=trim --minimum-length $MIN_LEN -o ${trim1}_trim2.fq $f; done;
mv *_trim1.fq clip_out/tag_clip

module --force purge
module load StdEnv
module load VSEARCH/2.13.4-iccifort-2019.1.144-GCC-8.2.0-2.31.1

mkdir -p clip_out/primer_clip
# Discard sequences containing Ns, add expected error rates and convert to fasta
for j in *_trim2.fq; do trim2="$(basename $j _trim2.fq)"; vsearch --quiet --fastq_filter $j --relabel_sha1 --fastq_qmax 45 --eeout --fastq_maxns 0 --fastqout ${trim2}_trim3.fq; done;
mv *_trim2.fq clip_out/primer_clip

mkdir -p clip_out/trimming
for k in *_trim3.fq; do trim3a="$(basename $k _trim3.fq)"; vsearch --quiet --fastq_filter $k --xee --fastaout ${trim3a}_trim3.fasta; done;

#quality file
# Discard quality lines, extract hash, expected error rates and read length
QUALITY_FILE=${PREFIX}.qual
TMP_QUAL=$(mktemp --tmpdir=".")
for q in *_trim3.fq; do \
        sed 'n;n;N;d' $q | \
        awk 'BEGIN {FS = "[;=]"}
           {if (/^@/) {printf "%s\t%s\t", $1, $3} else {print length($1)}}' | \
        tr -d "@" >> "${TMP_QUAL}"
done < "${TAGS}"
# Produce the final quality file
sort -k3,3n -k1,1d -k2,2n $TMP_QUAL  | \
   uniq --check-chars=40 > "${QUALITY_FILE}"
rm $TMP_QUAL
mv *_trim3.fq clip_out/trimming

mkdir dereplicated
for p in *_trim3.fasta; do trim3b="$(basename $p _trim3.fasta)"; vsearch --quiet --derep_fulllength $p --sizeout --fasta_width 0 --output ${trim3b}_dp.fasta; done;
rm *_trim3.fasta
mv *_dp.fasta dereplicated



