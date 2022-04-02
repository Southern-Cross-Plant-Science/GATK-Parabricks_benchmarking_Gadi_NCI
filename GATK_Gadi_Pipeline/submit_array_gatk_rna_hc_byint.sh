#!/bin/bash

PATHS=paths_rna.sh

source "$PATHS"


THREADS=4 #--native-pair-hmm-threads 
MEM=8 #Xmx
WALLTIME=48:00:00

echo  SAMPLE_FILE=$SAMPLE_FILE
echo  CHROMOSOME_FILE=$CHROMOSOME_FILE

NSAMPLES=$(wc -l < "$SAMPLE_FILE")
NCHROMS=$(wc -l < "$CHROMOSOME_FILE")

for i in $(seq $NSAMPLES); do
#i=4

  INLINE="$(head -n ${i} ${INPUT_DIR}/${SAMPLE_FILE} | tail -n 1)"

  echo INLINE=$INLINE

  a=($(echo "$INLINE" | tr '\t' '\n'))
  SAMPLE="${a[0]}"
  FILEID="${OUTPUT_DIR}/${SAMPLE}/"

  ln -s Aligned.sortedByCoord.out.splitncigar.bam "${FILEID}${REF}-${SAMPLE}-${BWA}-rg-dup.bam"
  ln -s Aligned.sortedByCoord.out.splitncigar.bai "${FILEID}${REF}-${SAMPLE}-${BWA}-rg-dup.bam.bai"

  # submit job per chromosome per sample

  #for INCLUDE_INT in NC_044371.1 NC_044375.1 NC_044372.1 NC_044373.1 NC_044374.1 NC_044377.1 NC_044378.1 NC_044379.1 NC_044376.1 NC_044370.1; do
  for INCLUDE_INT in $(seq $NCHROMS); do
  	echo "qsub -v PBS_ARRAY_INDEX=$i,FILEID=${OUTPUT_DIR}/${SAMPLE}/,INCLUDE_INT=${INCLUDE_INT},MEM=$MEM,THREADS=$THREADS,REF=$REF,PATHS=${PATHS} -l ncpus=${THREADS},mem=${MEM}g,walltime=${WALLTIME} -N ${JOB_NAME}.${i}.${INCLUDE_INT}.hc -o ${OUTPUT_DIR}/${JOB_NAME}.${i}.${INCLUDE_INT}.hc.stdout -e  ${OUTPUT_DIR}/${JOB_NAME}.${i}.${INCLUDE_INT}.hc.stderr  hc_byint.sh"
	  qsub -v PBS_ARRAY_INDEX=$i,FILEID="${OUTPUT_DIR}/${SAMPLE}/",INCLUDE_INT="${INCLUDE_INT},MEM=$MEM,THREADS=$THREADS,REF=$REF,PATHS=${PATHS}" -l ncpus=${THREADS},mem=${MEM}g,walltime=${WALLTIME} -N ${JOB_NAME}.${i}.${INCLUDE_INT}.hc -o "${OUTPUT_DIR}/${JOB_NAME}.${i}.${INCLUDE_INT}.hc.stdout" -e  "${OUTPUT_DIR}/${JOB_NAME}.${i}.${INCLUDE_INT}.hc.stderr"  hc_byint.sh
  done

  # for all unassembled contigs
  INCLUDE_INT=XL
  echo "qsub -v PBS_ARRAY_INDEX=$i,FILEID=${OUTPUT_DIR}/${SAMPLE}/,INCLUDE_INT=${INCLUDE_INT},MEM=$MEM,THREADS=$THREADS,REF=$REF,PATHS=${PATHS} -l ncpus=${THREADS},mem=${MEM}g,walltime=${WALLTIME} -N ${JOB_NAME}.${i}.${INCLUDE_INT}.hc -o ${OUTPUT_DIR}/${JOB_NAME}.${i}.${INCLUDE_INT}.hc.stdout -e  ${OUTPUT_DIR}/${JOB_NAME}.${i}.${INCLUDE_INT}.hc.stderr  hc_byint.sh"
  qsub -v PBS_ARRAY_INDEX=$i,FILEID="${OUTPUT_DIR}/${SAMPLE}/",INCLUDE_INT="${INCLUDE_INT},MEM=$MEM,THREADS=$THREADS,REF=$REF,PATHS=${PATHS}" -l ncpus=${THREADS},mem=${MEM}g,walltime=${WALLTIME} -N ${JOB_NAME}.${i}.${INCLUDE_INT}.hc -o "${OUTPUT_DIR}/${JOB_NAME}.${i}.${INCLUDE_INT}.hc.stdout" -e  "${OUTPUT_DIR}/${JOB_NAME}.${i}.${INCLUDE_INT}.hc.stderr"  hc_byint.sh

done
