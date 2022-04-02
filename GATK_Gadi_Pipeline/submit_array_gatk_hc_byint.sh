#!/bin/bash

source paths.sh


THREADS=4 #--native-pair-hmm-threads 
MEM=8 #Xmx


NSAMPLES=$(wc -l < "$SAMPLE_FILE")
NCHROMS=$(wc -l < "$CHROMOSOME_FILE")

done_sample=()
for i in $(seq $NSAMPLES); do
  # submit job per chromosome per sample

  INLINE="$(head -n ${i} ${INPUT_DIR}/${SAMPLE_FILE} | tail -n 1)"
  a=($(echo "$INLINE" | tr '\t' '\n'))
  if [[ " ${done_sample[*]} " =~ " ${a[0]} " ]]; then
  #if "${a[0]}" in "${done_sample[@]}"; then
    echo "${a[0]} done"
  else

    #for INCLUDE_INT in NC_044371.1 NC_044375.1 NC_044372.1 NC_044373.1 NC_044374.1 NC_044377.1 NC_044378.1 NC_044379.1 NC_044376.1 NC_044370.1; do
    for INCLUDE_INT in $(seq $NCHROMS); do
    	echo "qsub -v PBS_ARRAY_INDEX=$i,FILEID=${OUTPUT_DIR}/,INCLUDE_INT=${INCLUDE_INT},MEM=$MEM,THREADS=$THREADS,REF=$REF,PATHS=paths.sh -l ncpus=${THREADS},mem=${MEM}g -N ${JOB_NAME}.${i}.${INCLUDE_INT}.hc -o ${OUTPUT_DIR}/${JOB_NAME}.${i}.${INCLUDE_INT}.hc.stdout -e  ${OUTPUT_DIR}/${JOB_NAME}.${i}.${INCLUDE_INT}.hc.stderr  hc_byint.sh"
  	  qsub -v PBS_ARRAY_INDEX=$i,FILEID="${OUTPUT_DIR}/",INCLUDE_INT="${INCLUDE_INT},MEM=$MEM,THREADS=$THREADS,REF=$REF,PATHS=paths.sh" -l "ncpus=${THREADS},mem=${MEM}g" -N ${JOB_NAME}.${i}.${INCLUDE_INT}.hc -o "${OUTPUT_DIR}/${JOB_NAME}.${i}.${INCLUDE_INT}.hc.stdout" -e  "${OUTPUT_DIR}/${JOB_NAME}.${i}.${INCLUDE_INT}.hc.stderr"  hc_byint.sh
    done

    # for all unassembled contigs
    INCLUDE_INT=XL
    echo "qsub -v PBS_ARRAY_INDEX=$i,FILEID=${OUTPUT_DIR}/,INCLUDE_INT=${INCLUDE_INT},MEM=$MEM,THREADS=$THREADS,REF=$REF,PATHS=paths.sh -l ncpus=${THREADS},mem=${MEM}g -N ${JOB_NAME}.${i}.${INCLUDE_INT}.hc -o ${OUTPUT_DIR}/${JOB_NAME}.${i}.${INCLUDE_INT}.hc.stdout -e  ${OUTPUT_DIR}/${JOB_NAME}.${i}.${INCLUDE_INT}.hc.stderr  hc_byint.sh"
    qsub -v PBS_ARRAY_INDEX=$i,FILEID="${OUTPUT_DIR}/",INCLUDE_INT="${INCLUDE_INT},MEM=$MEM,THREADS=$THREADS,REF=$REF,PATHS=paths.sh" -l "ncpus=${THREADS},mem=${MEM}g" -N ${JOB_NAME}.${i}.${INCLUDE_INT}.hc -o "${OUTPUT_DIR}/${JOB_NAME}.${i}.${INCLUDE_INT}.hc.stdout" -e  "${OUTPUT_DIR}/${JOB_NAME}.${i}.${INCLUDE_INT}.hc.stderr"  hc_byint.sh
    done_sample+=("${a[0]}")
  fi

done
