#!/bin/bash

#PBS -r y
#PBS -l ncpus=10
#PBS -l mem=16GB
#PBS -q normal
#PBS -P wz54
#PBS -l walltime=12:00:00

#PBS -l storage=scratch/wz54+gdata/wz54
#PBS -l wd
#PBS -l jobfs=30GB

#source paths.sh
source ${PATHS}

INPUT_DIR=${PBS_O_WORKDIR}
OUTPUT_DIR="${INPUT_DIR}/${JOB_NAME}"


INLINE="$(head -n ${PBS_ARRAY_INDEX} ${INPUT_DIR}/${SAMPLE_FILE} | tail -n 1)"

a=($(echo "$INLINE" | tr '\t' '\n'))
echo "My array: ${a[@]}"

echo "VARIABLES"

###THREADS=10
###MEM=16
###REF='cs10'
#BWA='bwa1'
SAMPLE="${a[0]}"
RGID="${a[1]}"
FASTQ1="${a[2]}"
FASTQ2="${a[3]}"
BAMFILE="${FILEID}${REF}-${RGID}-${BWA}.bam"
RGFILE="${FILEID}${REF}-${RGID}-${BWA}-rg.bam"
DUPFILE="${FILEID}${REF}-${RGID}-${BWA}-rg-dup.bam"

echo "${PBS_JOBFS}"
echo ${PBS_ARRAY_INDEX}
echo $SAMPLE
echo $RGID
echo ${PBS_JOBID}
echo 'FASTQ1 SIZE'
wc -c ${FASTQ1}
echo 'FASTQ2 SIZE'
wc -c ${FASTQ2}

module load bwa/0.7.17
module load gatk/4.1.4.0/
module load samtools/1.10

THREADM1=$(($THREADS-1))


# create marked-duplicate bam
if [ ! -f "$DUPFILE.bai" ]; then

	
	# create sorted bam
	if [ ! -f "$RGFILE" ]; then


		if [ "${FASTQ2}" = "INT" ]; then
			echo "bwa mem interleaved ${FASTQ1}"
			bwa mem -p -t $THREADS  -K 10000000 -r "@RG\tID:${RGID}\tLB:${RGID}\tSM:${SAMPLE}\tPL:ILLUMINA"    "${REFERENCE_DIR}/${REF}.fna" $FASTQ1 | samtools view -@ $THREADSM1 -1 -S -b -o  $BAMFILE -  
		else
			echo "bwa mem paired ${FASTQ1}  ${FASTQ2}"
			bwa mem -t $THREADS  -K 10000000 -r "@RG\tID:${RGID}\tLB:${RGID}\tSM:${SAMPLE}\tPL:ILLUMINA"    "${REFERENCE_DIR}/${REF}.fna" $FASTQ1 $FASTQ2  | samtools view -@ $THREADSM1 -1 -S -b -o  $BAMFILE -  
		fi
		 
		wc -c $BAMFILE
		#cp $BAMFILE $OUTDIR

		echo 'ADDGROUP START'
		date
		java "-Xmx${MEM}g" -jar $PICARD_PATH  AddOrReplaceReadGroups I=$BAMFILE  O="${BAMFILE}.2"  RGID=$RGID RGLB=$RGID RGPL=ILLUMINA RGPU=$RGID RGSM=$SAMPLE
		#cp $BAMFILE $OUTDIR
		echo 'BAM FILE'
		wc -c "${BAMFILE}.2"

		gatk SortSam --java-options "-Xmx${MEM}g" -I="${BAMFILE}.2" -O=$RGFILE --SORT_ORDER=coordinate --TMP_DIR=${PBS_JOBFS}
		#cp $RGFILE $OUTDIR
		wc -c $RGFILE
	fi


	echo 'MARKDUP START'
	date

	gatk MarkDuplicatesSpark -I $RGFILE  -O  $DUPFILE  -M  ${DUPFILE}.metrics.txt  --conf "spark.executor.cores=${THREADS}" --conf "spark.local.dir=${PBS_JOBFS}"

	# clean intermediate files
	if [ -f "$DUPFILE.bai" ]; then
		rm "${BAMFILE}.2" 
		rm  $RGFILE
		rm  $BAMFILE 
	fi
	#cp $DUPFILE $OUTDIR
	echo 'MERGESAM START'
	echo 'HAPCALLER'
	date

fi



