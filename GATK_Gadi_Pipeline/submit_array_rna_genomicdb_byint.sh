#!/bin/bash

source paths_rna.sh

NSAMPLES=$(wc -l < "$SAMPLE_FILE")
NCHROMS=$(wc -l < "$CHROMOSOME_FILE")


FILEID="${OUTPUT_DIR}/"



# generate map file
#INCLUDE='sample-gvcf-map'
#rm ${OUTPUT_DIR}/${INCLUDE}.txt
#touch ${OUTPUT_DIR}/${INCLUDE}.txt

#SRR3294429.1    /scratch/wz54/lm0682/gatk-fastq2/hc-1g-byint-1-8-cs10-SRR3294429.1-NC_044370.1-bwa1.g.vcf.gz
#for i in $(seq $NSAMPLES); do
#	INLINE="$(head -n $i ${INPUT_DIR}/${SAMPLE_FILE} | tail -n 1)"
#	a=($(echo "$INLINE" | tr '\t' '\n'))
#	SAMPLE="${a[0]}"
#	IGVCFFILE="${FILEID}${SAMPLE}/${REF}-${SAMPLE}.g.vcf.gz"
#	echo "${SAMPLE}	${IGVCFFILE}" >> ${OUTPUT_DIR}/${INCLUDE}.txt
#done

# list file for genotypevcf
VCFFILE="${OUTPUT_DIR}/${REF}-${BWA}.vcf.list"
rm $VCFFILE
touch $VCFFILE

# create symlink per chromosome
for INCLUDE_INT in $(seq $NCHROMS); do
	INCLUDE="$(head -n ${INCLUDE_INT} ${INPUT_DIR}/${CHROMOSOME_FILE} | tail -n 1)"
	#rm ${OUTPUT_DIR}/${INCLUDE}.txt 
	#ln -s sample-gvcf-map.txt ${OUTPUT_DIR}/${INCLUDE}.txt 
	rm ${OUTPUT_DIR}/${INCLUDE}.txt
	touch ${OUTPUT_DIR}/${INCLUDE}.txt
	for i in $(seq $NSAMPLES); do
		INLINE="$(head -n $i ${INPUT_DIR}/${SAMPLE_FILE} | tail -n 1)"
		a=($(echo "$INLINE" | tr '\t' '\n'))
		SAMPLE="${a[0]}"
		IGVCFFILE="${FILEID}${SAMPLE}/${REF}-${SAMPLE}-${INCLUDE}-${BWA}.g.vcf.gz"
		echo "${SAMPLE}	${IGVCFFILE}" >> ${OUTPUT_DIR}/${INCLUDE}.txt
	done

	IGVCFFILE="${OUTPUT_DIR}/${REF}-${INCLUDE}.vcf.gz"	
  	echo $IGVCFFILE >> $VCFFILE
done

INCLUDE=XL
#rm ${OUTPUT_DIR}/${INCLUDE}.txt 
#ln -s sample-gvcf-map.txt ${OUTPUT_DIR}/${INCLUDE}.txt 
rm ${OUTPUT_DIR}/${INCLUDE}.txt
touch ${OUTPUT_DIR}/${INCLUDE}.txt
for i in $(seq $NSAMPLES); do
	INLINE="$(head -n $i ${INPUT_DIR}/${SAMPLE_FILE} | tail -n 1)"
	a=($(echo "$INLINE" | tr '\t' '\n'))
	SAMPLE="${a[0]}"
	IGVCFFILE="${FILEID}${SAMPLE}/${REF}-${SAMPLE}-${INCLUDE}-${BWA}.g.vcf.gz"
	echo "${SAMPLE}	${IGVCFFILE}" >> ${OUTPUT_DIR}/${INCLUDE}.txt
done


IGVCFFILE="${OUTPUT_DIR}/${REF}-${INCLUDE}.vcf.gz"	
echo $IGVCFFILE >> $VCFFILE




# submit import job per chromosome
for INCLUDE_INT in $(seq $NCHROMS); do
  echo "qsub -v FILEID=${FILEID},INCLUDE_INT=${INCLUDE_INT} -N ${JOB_NAME}.${INCLUDE_INT}.gdb -o ${FILEID}${JOB_NAME}.${INCLUDE_INT}.gdb.stdout -e  ${FILEID}${JOB_NAME}.${INCLUDE_INT}.gdb.stderr  gatk_rna_dbimportgenotypegvcf_byint.sh"
  qsub -v FILEID="${FILEID}",INCLUDE_INT="${INCLUDE_INT}" -N ${JOB_NAME}.${INCLUDE_INT}.gdb -o "${FILEID}${JOB_NAME}.${INCLUDE_INT}.gdb.stdout" -e  "${FILEID}${JOB_NAME}.${INCLUDE_INT}.gdb.stderr"  gatk_rna_dbimportgenotypegvcf_byint.sh
done

# for all unassembled contigs
INCLUDE_INT=XL
INCLUDE=XL
sleep 1
echo "qsub -v FILEID=${FILEID},INCLUDE_INT=${INCLUDE_INT} -N ${JOB_NAME}.${INCLUDE_INT}.gdb -o ${FILEID}${JOB_NAME}.${INCLUDE_INT}.gdb.stdout -e  ${FILEID}${JOB_NAME}.${INCLUDE_INT}.gdb.stderr  gatk_rna_dbimportgenotypegvcf_byint.sh"
qsub -v FILEID="${FILEID}",INCLUDE_INT="${INCLUDE_INT}" -N ${JOB_NAME}.${INCLUDE_INT}.gdb -o "${FILEID}${JOB_NAME}.${INCLUDE_INT}.gdb.stdout" -e  "${FILEID}${JOB_NAME}.${INCLUDE_INT}.gdb.stderr"  gatk_rna_dbimportgenotypegvcf_byint.sh

