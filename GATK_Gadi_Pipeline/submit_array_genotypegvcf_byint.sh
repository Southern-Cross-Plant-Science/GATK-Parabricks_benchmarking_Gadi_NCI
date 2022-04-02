#!/bin/bash

source paths.sh

NCHROMS=$(wc -l < "$CHROMOSOME_FILE")


VCFFILE="${OUTPUT_DIR}/${REF}-${BWA}.vcf.list"
rm $VCFFILE

touch $VCFFILE

# submit  genotypegvcf job per chromosome
for INCLUDE_INT in $(seq $NCHROMS); do
  INCLUDE="$(head -n ${INCLUDE_INT} ${INPUT_DIR}/${CHROMOSOME_FILE} | tail -n 1)"

  echo "qsub -v INCLUDE_INT=${INCLUDE} -N ${JOB_NAME}.${INCLUDE_INT}.genotype -o ${OUTPUT_DIR}/${JOB_NAME}.${INCLUDE_INT}.genotype.stdout -e  ${OUTPUT_DIR}/${JOB_NAME}.${INCLUDE_INT}.${INCLUDE}.genotype.stderr  genotypegvcf.sh"
  qsub -v INCLUDE_INT="${INCLUDE}" -N ${JOB_NAME}.${INCLUDE_INT}.genotype -o "${OUTPUT_DIR}/${JOB_NAME}.${INCLUDE_INT}.genotype.stdout" -e  "${OUTPUT_DIR}/${JOB_NAME}.${INCLUDE_INT}.${INCLUDE}.genotype.stderr"  genotypegvcf.sh

  IGVCFFILE="${OUTPUT_DIR}/${REF}-${INCLUDE}-${BWA}.vcf.gz"
  echo $IGVCFFILE >> $VCFFILE

done

# for all unassembled contigs
INCLUDE_INT=XL
INCLUDE=XL
sleep 1
echo "qsub -v INCLUDE_INT=${INCLUDE} -N ${JOB_NAME}.${INCLUDE_INT}.genotype -o ${OUTPUT_DIR}/${JOB_NAME}.${INCLUDE_INT}.genotype.stdout -e  ${OUTPUT_DIR}/${JOB_NAME}.${INCLUDE_INT}.genotype.stderr  genotypegvcf.sh"
qsub -v INCLUDE_INT="${INCLUDE}" -N ${JOB_NAME}.${INCLUDE_INT}.genotype -o "${OUTPUT_DIR}/${JOB_NAME}.${INCLUDE_INT}.genotype.stdout" -e  "${OUTPUT_DIR}/${JOB_NAME}.${INCLUDE_INT}.genotype.stderr"  genotypegvcf.sh


IGVCFFILE="${OUTPUT_DIR}/${REF}-${INCLUDE}-${BWA}.vcf.gz"
echo $IGVCFFILE >> $VCFFILE

