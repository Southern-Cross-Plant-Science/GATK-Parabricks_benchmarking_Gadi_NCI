#!/bin/bash
### Job name
#PBS -N fq2bam4_24_64
### Output files
#PBS -o fq2bam4_24_64.stdout
#PBS -e fq2bam4_24_64.stderr

#PBS -r y
#PBS -l ncpus=1
####PBS -l mem=128GB
#PBS -l mem=32GB
####PBS -l ngpus=4
#PBS -q normal
#PBS -P wz54
#PBS -l walltime=6:00:00
### Number of nodes
###PBS -l nodes=4:compute#shared  # not supported

#PBS -l storage=scratch/wz54+gdata/wz54
#PBS -l wd
#PBS -l jobfs=10GB
#FILEID="-"

source paths_rna.sh

INPUT_DIR=${PBS_O_WORKDIR}
OUTPUT_DIR="${INPUT_DIR}/${JOB_NAME}"


INLINE="$(head -n ${PBS_ARRAY_INDEX} ${INPUT_DIR}/${SAMPLE_FILE} | tail -n 1)"
a=($(echo "$INLINE" | tr '\t' '\n'))
echo "My array:"

echo "VARIABLES"

SAMPLE="${a[0]}"
RGID_1="${a[1]}"
FASTQ1_1="${a[2]}"
FASTQ2_1="${a[3]}"
RGID_2="${a[4]}"
FASTQ1_2="${a[5]}"
FASTQ2_2="${a[6]}"
RGID_3="${a[7]}"
FASTQ1_3="${a[8]}"
FASTQ2_3="${a[9]}"


echo 'FASTQ1 SIZE'
wc -c ${FASTQ1_1}
wc -c ${FASTQ1_2}
wc -c ${FASTQ1_3}
echo 'FASTQ2 SIZE'
wc -c ${FASTQ2_1}
wc -c ${FASTQ2_2}
wc -c ${FASTQ2_3}


mkdir $OUTPUT_DIR

mkdir ${OUTPUT_DIR}/${SAMPLE}


${PARABRICKS_DIR}/pbrun rna_fq2bam --in-fq $FASTQ1_1  $FASTQ2_1  "@RG\tID:${RGID_1}\tLB:${RGID_1}\tPL:ILLUMINA\tSM:${SAMPLE}\tPU:${RGID_1}"  \
  --in-fq $FASTQ1_2  $FASTQ2_2  "@RG\tID:${RGID_2}\tLB:${RGID_2}\tPL:ILLUMINA\tSM:${SAMPLE}\tPU:${RGID_2}"  \
  --in-fq $FASTQ1_3  $FASTQ2_3  "@RG\tID:${RGID_3}\tLB:${RGID_3}\tPL:ILLUMINA\tSM:${SAMPLE}\tPU:${RGID_3}"  \
  --genome-lib-dir ${STAR_GENOMEDIR}  --output-dir ${OUTPUT_DIR}/${SAMPLE}/ --out-bam ${OUTPUT_DIR}/${SAMPLE}/${REF}-${SAMPLE}.bam  \
  --two-pass-mode Basic --out-reads-unmapped Fastx --read-files-command "gunzip -c" ${REF}.fna  --num-threads $THREADS --out-sam-mode Full  \
  --license-file ${PARABRICKS_DIR}/license.bin 


${PARABRICKS_DIR}/pbrun haplotypecaller --ref ${REFERENCE_DIR}/${REF}.fna --in-bam ${OUTPUT_DIR}/${SAMPLE}/${REF}-${SAMPLE}.bam \
    --out-variants ${OUTPUT_DIR}/${SAMPLE}/${REF}-${SAMPLE}.g.vcf.gz --gvcf --license-file ${PARABRICKS_DIR}/license.bin 

