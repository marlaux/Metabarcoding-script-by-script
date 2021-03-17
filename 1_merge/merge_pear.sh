#/bin/bash
module --quiet purge
module load StdEnv
module load PEAR/0.9.11-GCCcore-9.3.0



INPUT_F="Lib1_R1_subsampled.fastq"
INPUT_R="Lib1_R2_subsampled.fastq"
THREADS="4"
PVALUE="0.001"  #Specify  a p-value for the statistical test
OVERLAP="20"      #Specify the minimum overlap size.
QUAL="20"      #uality  score  threshold for trimming the low quality 
UNCALLED="0"	#do not allow N's
OUTPUT="training_set"

	pear -j ${THREADS}	\
		 -p ${PVALUE}	\
		 -v ${OVERLAP}	\
		 -q ${QUAL}	\
		 -u ${UNCALLED}	\
		 -f ${INPUT_F}	\
		 -r ${INPUT_R}	\
		 -o ${OUTPUT} 


