#/bin/bash

TMP_FASTA=$(mktemp --tmpdir=".")
GLOBAL_DP=''
LENGTH=''
DIR=''

usage () {
        echo "##################################################"
	echo "Global dereplication, clustering using SWARM, formatting and chimera searching wrapped script."
        echo " "
        echo "Usage: ${0} [-l length] [-o output] [-p pwd]"
        echo "-l     expected amplicon lenght"
        echo "-o     output name 'my_project_marker'"
        echo "-p     complete path to dereplicated by samples directory (3_read_cleaning step, derep_sample)"
        echo "-h     print this help"
        echo " "
        echo "##################################################"
                1>&2; exit 1;

}

while getopts "l:o:p:h" option; do
        case $option in
        l) LENGTH="${OPTARG}"
                ;;
        o) GLOBAL_DP="${OPTARG}"
                ;;
        p) DIR="${OPTARG}"
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
module load VSEARCH/2.13.4-iccifort-2019.1.144-GCC-8.2.0-2.31.1

# Global dereplication
cat "${DIR}"/*.fasta > "${TMP_FASTA}"

# Global dereplication
vsearch --derep_fulllength "${TMP_FASTA}" \
        --sizein \
        --sizeout \
        --fasta_width 0 \
	--output "${GLOBAL_DP}.fas" > /dev/null

rm -f "${TMP_FASTA}"

module --force purge
module load StdEnv  
module load swarm/3.0.0-GCC-9.3.0

#clustering with SWARM
THREADS="4"
TMP_REPRESENTATIVES=$(mktemp --tmpdir=".")

swarm	\
    -d 1 -f -t ${THREADS} -z \
    -i "${GLOBAL_DP}.struct" \
    -s "${GLOBAL_DP}.stats" \
    -w ${TMP_REPRESENTATIVES} \
    -o "${GLOBAL_DP}.swarms" < "${GLOBAL_DP}.fas"

module --force purge
module load StdEnv
module load VSEARCH/2.13.4-iccifort-2019.1.144-GCC-8.2.0-2.31.1

# Sort representatives
vsearch	\
	--fasta_width 0 \
        --sortbysize ${TMP_REPRESENTATIVES} \
        --output "${GLOBAL_DP}_1f_representatives.fas"
rm ${TMP_REPRESENTATIVES}

# Chimera checking
REPRESENTATIVES="${GLOBAL_DP}_1f_representatives.fas"
UCHIME=${REPRESENTATIVES/.fas/.uchime}
vsearch 	\
	--uchime_denovo "${REPRESENTATIVES}" \
        --uchimeout "${UCHIME}"

FINAL=${REPRESENTATIVES/_1f_representatives.fas/_2f_representatives.fas}
sed -e '/^>/ s/;size=/_/' -e '/^>/ s/;$//' "${REPRESENTATIVES}" > "${FINAL}"


