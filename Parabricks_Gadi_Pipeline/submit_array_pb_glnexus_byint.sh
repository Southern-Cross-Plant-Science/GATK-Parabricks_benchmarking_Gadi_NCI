#!/bin/bash

source paths.sh

NSAMPLES=$(wc -l < "$SAMPLE_FILE")
NCHROMS=$(wc -l < "$CHROMOSOME_FILE")

#for INCLUDE_INT in NC_044371.1 NC_044375.1 NC_044372.1 NC_044373.1 NC_044374.1 NC_044377.1 NC_044378.1 NC_044379.1 NC_044376.1 NC_044370.1; do
for INCLUDE_INT in $(seq $NCHROMS); do
  
    SCRIPT_INT="${OUTPUT_DIR}/pb_glnexus_${JOB_NAME}.${INCLUDE_INT}.sh"
    cp pb_glnexus.sh $SCRIPT_INT

    # submit job per chromosome, generate script
    for i in $(seq $NSAMPLES); do
      INLINE="$(head -n ${i} ${INPUT_DIR}/${SAMPLE_FILE} | tail -n 1)"
      a=($(echo "$INLINE" | tr '\t' '\n'))
      SAMPLE="${a[1]}"
      RGID="${a[0]}"
      echo "--in-gvcf ${OUTPUT_DIR}/${REF}-${RGID}-${BWA}.g.vcf.gz  \\" >> $SCRIPT_INT
    done
    echo  "--tmp-dir ${OUTPUT_DIR}/tmp-${INCLUDE_INT} \\" >> $SCRIPT_INT
    echo  "--keep-tmp" >> $SCRIPT_INT

    cat $SCRIPT_INT bcf2vcfgz.sh > "${SCRIPT_INT}.tmp"
    rm $SCRIPT_INT
    mv "${SCRIPT_INT}.tmp" $SCRIPT_INT

    INCLUDE="$(head -n ${INCLUDE_INT} ${INPUT_DIR}/${CHROMOSOME_FILE} | tail -n 1)"

    echo "qsub  -v INCLUDE=${INCLUDE} -N pb_glnexus_${JOB_NAME}.${INCLUDE_INT} -o ${OUTPUT_DIR}/pb_glnexus_${JOB_NAME}.${INCLUDE_INT}.stdout -e ${OUTPUT_DIR}/pb_glnexus_${JOB_NAME}.${INCLUDE_INT}.stderr $SCRIPT_INT"
    qsub  "-v INCLUDE=${INCLUDE}"  -N "pb_glnexus_${JOB_NAME}.${INCLUDE_INT}" -o "${OUTPUT_DIR}/pb_glnexus_${JOB_NAME}.${INCLUDE_INT}.stdout" -e "${OUTPUT_DIR}/pb_glnexus_${JOB_NAME}.${INCLUDE_INT}.stderr" $SCRIPT_INT

done
