#!/bin/bash
 

NGPU=4
THREADS=48	# should be 12xNGPU
MEM=64

source paths.sh

mkdir $OUTPUT_DIR

NSAMPLES=$(wc -l < "$SAMPLE_FILE")
for i in $(seq $NSAMPLES); do
  qsub -v PBS_ARRAY_INDEX=$i,FILEID="${OUTPUT_DIR}/",THREADS=$THREADS,MEM=$MEM,REF=$REF,SAMPLE_FILE=$SAMPLE_FILE -N $JOB_NAME.${i}.fq2gvcf -l "mem=${MEM}gb,ncpu=${THREADS},ngpu=${NGPU}" -o "${OUTPUT_DIR}/${JOB_NAME}.${i}.fq2gvcf.stdout" -e  "${OUTPUT_DIR}/${JOB_NAME}.${i}.fq2gvcf.stderr"  pb_fq2gvcf.sh
done
