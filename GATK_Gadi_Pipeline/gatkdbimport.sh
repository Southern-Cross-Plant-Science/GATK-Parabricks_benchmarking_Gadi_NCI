#!/bin/bash

##PBS -N dbimport-NC_044371-1
### Output files
##PBS -o dbimport-NC_044371-1.stdout
##PBS -e dbimport-NC_044371-1.stderr
#PBS -r y
#PBS -l ncpus=1
#PBS -l mem=32GB
#PBS -q normal
#PBS -P wz54
#PBS -l walltime=48:00:00
### Number of nodes
###PBS -l nodes=4:compute#shared  # not supported

#PBS -l storage=scratch/wz54+gdata/wz54
#PBS -l wd
#PBS -l jobfs=20GB

source paths.sh

INPUT_DIR=${PBS_O_WORKDIR}
OUTPUT_DIR=${INPUT_DIR}/${JOB_NAME}

THREADS=1
MEM=32

module load gatk/4.1.4.0/


if [ "$INCLUDE_INT" = "XL" ]; then
	rm -rf "${OUTPUT_DIR}/gdb-${INCLUDE_INT}"
	gatk --java-options "-Xmx${MEM}g -Xms4g" \
	       GenomicsDBImport \
	       -XL $CHROMOSOME_FILE \
	       --genomicsdb-workspace-path "${OUTPUT_DIR}/gdb-${INCLUDE_INT}" \
	       --sample-name-map "${OUTPUT_DIR}/${INCLUDE_INT}.txt"
else
	INCLUDE_INT="$(head -n ${INCLUDE_INT} ${INPUT_DIR}/${CHROMOSOME_FILE} | tail -n 1)"
	rm -rf "${OUTPUT_DIR}/gdb-${INCLUDE_INT}"
	gatk --java-options "-Xmx${MEM}g -Xms4g" \
	       GenomicsDBImport \
	       -L $INCLUDE_INT \
	       --genomicsdb-workspace-path "${OUTPUT_DIR}/gdb-${INCLUDE_INT}" \
	       --sample-name-map "${OUTPUT_DIR}/${INCLUDE_INT}.txt"
fi
