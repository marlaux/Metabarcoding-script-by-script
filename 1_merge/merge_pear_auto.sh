#/bin/bash
module --quiet purge
module load StdEnv
module load PEAR/0.9.11-GCCcore-9.3.0

INPUT_F=''
INPUT_R=''
THREADS='1'
PVALUE='1'
OVERLAP='1'
OUTPUT=''
UNCALLED='0'
QUAL='20'


usage () {
        echo "##################################################"
        echo " "
	echo "Merging of paired end fastq files from Illumina sequencing using Pear."
	echo " "
        echo "Usage: ${0} [-f R1.fq] [-r R2.fq] [-o output] [-p 0.001] [-s 20] [-t 4]"
        echo "-f     R1.fastq original file"
        echo "-r     R2.fastq original file"
        echo "-o     output name for the assembled fastq file"
        echo "-p     p-value: statistical test for true assembly. Lower p-value means less possibility of overlapping by chance. Options are: 0.0001, 0.001, 0.01, 0.05 and 1.0"
        echo "-s     minimum overlap size."
        echo "-t     threads"
        echo "-h     print this help"
        echo " "
        echo "##################################################"
                1>&2; exit 1;

}

while getopts "f:r:o:p:s:t:h" option; do
        case $option in
        f) INPUT_F="${OPTARG}"
                ;;
        r) INPUT_R="${OPTARG}"
                ;;
        o) OUTPUT="${OPTARG}"
                ;;
        p) PVALUE="${OPTARG}"
               ;;
        s) OVERLAP="${OPTARG}"
               ;;
	t) THREADS="${OPTARG}"
               ;;
        h | *) usage
                exit 0
                ;;
        \?) echo "Invalid option: -$OPTARG"
                exit 1
                ;;
   esac
done

if [ -z "$INPUT_F" ] || [ -z "$INPUT_R" ] || [ -z "$OUTPUT" ] ; then
        echo 'Missing argument' >&2
        exit 1
fi

	pear -j ${THREADS}	\
		 -p ${PVALUE}	\
		 -v ${OVERLAP}	\
		 -q ${QUAL}	\
		 -u ${UNCALLED}	\
		 -f ${INPUT_F}	\
		 -r ${INPUT_R}	\
		 -o ${OUTPUT} 


