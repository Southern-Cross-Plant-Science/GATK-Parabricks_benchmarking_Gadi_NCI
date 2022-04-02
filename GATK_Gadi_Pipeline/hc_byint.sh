#!/bin/bash

#PBS -r y
#PBS -l ncpus=1
###PBS -l mem=8GB
#PBS -q normal
#PBS -P wz54
#PBS -l walltime=48:00:00
### Number of nodes
###PBS -l nodes=4:compute#shared  # not supported

#PBS -l storage=scratch/wz54+gdata/wz54
#PBS -l wd
#PBS -l jobfs=20GB



source ${PATHS}

INPUT_DIR=${PBS_O_WORKDIR}
OUTPUT_DIR="${INPUT_DIR}/${JOB_NAME}"

INLINE="$(head -n ${PBS_ARRAY_INDEX} ${INPUT_DIR}/${SAMPLE_FILE} | tail -n 1)"

a=($(echo "$INLINE" | tr '\t' '\n'))
echo "My array: ${a[@]}"
echo "VARIABLES"


SAMPLE="${a[0]}"
RGID="${a[1]}"
FASTQ1="${a[2]}"
FASTQ2="${a[3]}"

if [ "$PATHS" = "paths.sh" ]; then
	DUPFILE="${FILEID}${REF}-${SAMPLE}-${BWA}-rg-dup.bam"	
else
	# paths_rna.sh
	DUPFILE="${FILEID}Aligned.sortedByCoord.out.splitncigar.bam"	
fi


#DUPFILE="${FILEID}${REF}-${SAMPLE}-${BWA}-rg-dup.bam"
#GVCFFILE="${FILEID}${REF}-${SAMPLE}-${BWA}.g.vcf.gz"

echo "${PBS_JOBFS}"
echo ${PBS_ARRAY_INDEX}
echo $SAMPLE
echo $RGID
echo ${PBS_JOBID}
echo 'FASTQ1 SIZE'
wc -c ${FASTQ1}
echo 'FASTQ2 SIZE'
wc -c ${FASTQ2}

module load gatk/4.1.4.0/


if [ "$INCLUDE_INT" = "XL" ]; then
	IGVCFFILE="${FILEID}${REF}-${SAMPLE}-${INCLUDE_INT}-${BWA}.g.vcf.gz"
	echo "running HC -XL ${CHROMOSOME_FILE}"
	# contig names are hardcoded for now, GATK HaplotypeCaller can supposedly accept a file list but I can't make it work
	# call variants except the contigs defined in -XL
	gatk --java-options "-Djava.io.tmpdir=${PBS_JOBFS}  -Xmx${MEM}g" HaplotypeCaller  --tmp-dir ${PBS_JOBFS}  --native-pair-hmm-threads ${THREADS}  -R ${REFERENCE_DIR}/${REF}.fna -I $DUPFILE  -O $IGVCFFILE -ERC GVCF --heterozygosity $HETEROZYGOSITY --indel-heterozygosity $INDEL_HETEROZYGOSITY -XL $CHROMOSOME_FILE

else
	INCLUDE="$(head -n ${INCLUDE_INT} ${INPUT_DIR}/${CHROMOSOME_FILE} | tail -n 1)"
	IGVCFFILE="${FILEID}${REF}-${SAMPLE}-${INCLUDE}-${BWA}.g.vcf.gz"
	echo "running HC -L ${INCLUDE}"
	# call vaiants only on contigs defined in -L
    gatk --java-options "-Djava.io.tmpdir=${PBS_JOBFS}  -Xmx${MEM}g" HaplotypeCaller --tmp-dir ${PBS_JOBFS}  -R  ${REFERENCE_DIR}/${REF}.fna -I $DUPFILE  -O $IGVCFFILE -ERC GVCF --heterozygosity $HETEROZYGOSITY --indel-heterozygosity $INDEL_HETEROZYGOSITY -L "$INCLUDE"

fi

