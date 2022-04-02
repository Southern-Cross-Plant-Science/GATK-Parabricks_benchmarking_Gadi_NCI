#!/bin/bash
 
THREADS=10
MEM=16

PATHS=paths.sh

source ${PATHS}
mkdir $OUTPUT_DIR


NSAMPLES=$(wc -l < "$SAMPLE_FILE")

for i in $(seq $NSAMPLES); do
  echo "qsub -v PBS_ARRAY_INDEX=$i,FILEID=${OUTPUT_DIR}/,THREADS=$THREADS,MEM=$MEM,REF=$REF,SAMPLE_FILE=$SAMPLE_FILE,PATHS=${PATHS} -l ncpus=${THREADS},mem=${MEM}g -N ${JOB_NAME}.${i}.bam -o ${OUTPUT_DIR}/${JOB_NAME}.${i}.bam.stdout -e  ${OUTPUT_DIR}/${JOB_NAME}.${i}.bam.stderr  bwadup.sh"
  qsub -v PBS_ARRAY_INDEX=$i,FILEID="${OUTPUT_DIR}/",THREADS=$THREADS,MEM=$MEM,REF=$REF,SAMPLE_FILE=$SAMPLE_FILE,PATHS=${PATHS} -l "ncpus=${THREADS},mem=${MEM}g" -N "${JOB_NAME}.${i}.bam"  -o "${OUTPUT_DIR}/${JOB_NAME}.${i}.bam.stdout" -e  "${OUTPUT_DIR}/${JOB_NAME}.${i}.bam.stderr"  bwadup.sh
done
