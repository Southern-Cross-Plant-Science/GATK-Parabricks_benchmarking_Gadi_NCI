#!/bin/bash

##PBS -N genotypegvcf
### Output files
##PBS -o genotypegvcf.stdout
##PBS -e genotypegvcf.stderr
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
source paths.sh

INPUT_DIR=${PBS_O_WORKDIR}
OUTPUT_DIR=${INPUT_DIR}/${JOB_NAME}
IGVCFFILE="${OUTPUT_DIR}/${REF}-${INCLUDE_INT}-${BWA}.vcf.gz"

module load gatk/4.1.4.0/

gatk --java-options "-Xmx${MEM}g -Xms4g" \
       GenotypeGVCFs \
       --tmp-dir ${PBS_JOBFS}  \
       -R "${REFERENCE_DIR}/${REF}.fna" \
       -V "gendb://${OUTPUT_DIR}/gdb-${INCLUDE_INT}" \
       -O $IGVCFFILE \
       --heterozygosity $HETEROZYGOSITY \
       --indel-heterozygosity $INDEL_HETEROZYGOSITY

