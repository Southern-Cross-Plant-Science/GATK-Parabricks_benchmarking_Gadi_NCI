#!/bin/bash
 
THREADS=10
MEM=16

source paths_rna.sh

mkdir $OUTPUT_DIR


NSAMPLES=$(wc -l < "$SAMPLE_FILE")

for i in $(seq $NSAMPLES); do

  echo "qsub -v PBS_ARRAY_INDEX=$i,THREADS=$THREADS,MEM=$MEM,REF=$REF,SAMPLE_FILE=$SAMPLE_FILE -N ${JOB_NAME}.${i}.fq2gvcf  -o ${OUTPUT_DIR}/${JOB_NAME}.${i}.fq2gvcf.stdout -e  ${OUTPUT_DIR}/${JOB_NAME}.${i}.fq2gvcf.stderr  pb_rnafq2bam_bysm.sh"
  qsub -v PBS_ARRAY_INDEX=$i,THREADS=$THREADS,MEM=$MEM,REF=$REF,SAMPLE_FILE=$SAMPLE_FILE -N "${JOB_NAME}.${i}.fq2gvcf"  -o "${OUTPUT_DIR}/${JOB_NAME}.${i}.fq2gvcf.stdout" -e  "${OUTPUT_DIR}/${JOB_NAME}.${i}.fq2gvcf.stderr"  pb_rnafq2bam_bysm.sh

done
