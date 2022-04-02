#!/bin/bash
#SAMPLE_FILE='samples.txt'
SAMPLE_FILE='samples-fastq5-test.txt'
REF='cs10'
JOB_NAME="cs10-fastq5"
BWA='bwa1'
CHROMOSOME_FILE='cs10-chrom.intervals'
PBS_O_WORKDIR=./
INPUT_DIR=${PBS_O_WORKDIR}
OUTPUT_DIR="${INPUT_DIR}/${JOB_NAME}"

REFERENCE_DIR=/g/data/wz54/lm0682/reference-bwa1
PICARD_PATH=/g/data/wz54/lm0682/software/picard.2.22.4.jar

HETEROZYGOSITY=0.013
INDEL_HETEROZYGOSITY=0.0013

