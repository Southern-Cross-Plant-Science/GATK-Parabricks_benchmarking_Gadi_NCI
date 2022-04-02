#!/bin/bash
SAMPLE_FILE='samples-rna-test.txt'
REF='cs10'
#JOB_NAME="cs10-rna-gatk-271a"
JOB_NAME="cs10-rna-gatk-b"
BWA='star'
CHROMOSOME_FILE='cs10-chrom.intervals'

PBS_O_WORKDIR=./
INPUT_DIR=${PBS_O_WORKDIR}
OUTPUT_DIR="${INPUT_DIR}/${JOB_NAME}"

REFERENCE_DIR=/g/data/wz54/lm0682/reference-bwa1
PICARD_PATH=/g/data/wz54/lm0682/software/picard.2.22.4.jar

HETEROZYGOSITY=0.013
INDEL_HETEROZYGOSITY=0.0013

# for Parabricks
#PARABRICKS_DIR=/scratch/wz54/software/parabricks-build	# version 3.1
PARABRICKS_DIR=/g/data/wz54/containers/parabricks/parabricks_v3.5.0	# version 3.5

STAR_PATH=/g/data/wz54/lm0682/software/STAR-2.7.1a/source/STAR # version 2.7.1a, compatible with Parabricks rna_fq2bam
STAR_GENOMEDIR=/home/600/lm0682/myproject/fastq-11/${REF}_idx_271	# for STAR version 2.7.1, compatible with Parabricks rna_fq2bam

#STAR_PATH=/g/data/wz54/lm0682/software/STAR/source/STAR  # version 2.7.9a
#STAR_GENOMEDIR=/home/600/lm0682/myproject/fastq-11/${REF}_idx

