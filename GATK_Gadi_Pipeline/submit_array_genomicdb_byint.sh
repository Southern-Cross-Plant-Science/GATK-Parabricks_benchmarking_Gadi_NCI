#!/bin/bash

PATHS=paths.sh
source paths.sh

NSAMPLES=$(wc -l < "$SAMPLE_FILE")
NCHROMS=$(wc -l < "$CHROMOSOME_FILE")


FILEID="${OUTPUT_DIR}/"

# generate map file
for INCLUDE_INT in $(seq $NCHROMS); do
	INCLUDE1="$(head -n ${INCLUDE_INT} ${INPUT_DIR}/${CHROMOSOME_FILE} | tail -n 1)"
	INCLUDE="${INCLUDE1//[^[:ascii:]]/}"
	rm ${OUTPUT_DIR}/${INCLUDE}.txt
	touch ${OUTPUT_DIR}/${INCLUDE}.txt

	#SRR3294429.1    /scratch/wz54/lm0682/gatk-fastq2/hc-1g-byint-1-8-cs10-SRR3294429.1-NC_044370.1-bwa1.g.vcf.gz
	done_sample=()	
	for i in $(seq $NSAMPLES); do
		INLINE="$(head -n $i ${INPUT_DIR}/${SAMPLE_FILE} | tail -n 1)"
		a=($(echo "$INLINE" | tr '\t' '\n'))
		SAMPLE="${a[0]}"
		RGID="${a[1]}"

		if [[ " ${done_sample[*]} " =~ " ${a[0]} " ]]; then
		    echo "${a[0]} done"
		else
			IGVCFFILE="${FILEID}${REF}-${SAMPLE}-${INCLUDE}-${BWA}.g.vcf.gz"
			echo "${SAMPLE}	${IGVCFFILE}" >> ${OUTPUT_DIR}/${INCLUDE}.txt
			done_sample+=("${a[0]}")
		fi
	done
done

INCLUDE_INT=XL
INCLUDE=XL
rm ${OUTPUT_DIR}/${INCLUDE}.txt
touch ${OUTPUT_DIR}/${INCLUDE}.txt

#SRR3294429.1    /scratch/wz54/lm0682/gatk-fastq2/hc-1g-byint-1-8-cs10-SRR3294429.1-NC_044370.1-bwa1.g.vcf.gz
done_sample=()
for i in $(seq $NSAMPLES); do
	INLINE="$(head -n ${i} ${INPUT_DIR}/${SAMPLE_FILE} | tail -n 1)"
	a=($(echo "$INLINE" | tr '\t' '\n'))
	SAMPLE="${a[0]}"
	RGID="${a[1]}"

	if [[ " ${done_sample[*]} " =~ " ${a[0]} " ]]; then
	    echo "${a[0]} done"
	else
		IGVCFFILE="${FILEID}${REF}-${SAMPLE}-${INCLUDE_INT}-${BWA}.g.vcf.gz"
		echo "${SAMPLE}	${IGVCFFILE}" >> ${OUTPUT_DIR}/${INCLUDE}.txt
		done_sample+=("${a[0]}")
	fi
done



# submit import job per chromosome
for INCLUDE_INT in $(seq $NCHROMS); do
  #INCLUDE1="$(head -n ${INCLUDE_INT} ${INPUT_DIR}/${CHROMOSOME_FILE} | tail -n 1)"
  #INCLUDE="${INCLUDE1//[^[:ascii:]]/}"

  echo "qsub -v FILEID=${FILEID},INCLUDE_INT=${INCLUDE_INT} -N ${JOB_NAME}.${INCLUDE_INT}.gdb -o ${FILEID}${JOB_NAME}.${INCLUDE_INT}.gdb.stdout -e  ${FILEID}${JOB_NAME}.${INCLUDE_INT}.gdb.stderr  gatkdbimport.sh"
  qsub -v FILEID="${FILEID}",INCLUDE_INT="${INCLUDE_INT},PATHS=${PATHS}" -N ${JOB_NAME}.${INCLUDE_INT}.gdb -o "${FILEID}${JOB_NAME}.${INCLUDE_INT}.gdb.stdout" -e  "${FILEID}${JOB_NAME}.${INCLUDE_INT}.gdb.stderr"  gatkdbimport.sh
done

# for all unassembled contigs
INCLUDE_INT=XL
INCLUDE=XL
sleep 1
echo "qsub -v FILEID=${FILEID},INCLUDE_INT=${INCLUDE_INT} -N ${JOB_NAME}.${INCLUDE_INT}.gdb -o ${FILEID}${JOB_NAME}.${INCLUDE_INT}.gdb.stdout -e  ${FILEID}${JOB_NAME}.${INCLUDE_INT}.gdb.stderr  gatkdbimport.sh"
qsub -v FILEID="${FILEID}",INCLUDE_INT="${INCLUDE_INT},PATHS=${PATHS}" -N ${JOB_NAME}.${INCLUDE_INT}.gdb -o "${FILEID}${JOB_NAME}.${INCLUDE_INT}.gdb.stdout" -e  "${FILEID}${JOB_NAME}.${INCLUDE_INT}.gdb.stderr"  gatkdbimport.sh


