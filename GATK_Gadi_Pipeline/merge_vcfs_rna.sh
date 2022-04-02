#!/bin/bash

#PBS -N merge_vcfs
### Output files
###PBS -o merge_vcfs.stdout
###PBS -e merge_vcfs.stderr
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

MEM=32
source paths_rna.sh

INPUT_DIR=${PBS_O_WORKDIR}
OUTPUT_DIR=${INPUT_DIR}/${JOB_NAME}

VCFFILE="${OUTPUT_DIR}/${REF}-${BWA}.vcf.list"

#java "-Xmx${MEM}g" -jar $PICARD_PATH MergeVcfs \
java "-Xmx${MEM}g" -jar $PICARD_PATH GatherVcfs \
          I=$VCFFILE \
          O="${OUTPUT_DIR}/${REF}-${BWA}.vcf.gz"


