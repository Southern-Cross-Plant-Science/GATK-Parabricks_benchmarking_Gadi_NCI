#!/bin/bash
### Job name


#PBS -r y
###PBS -l ncpus=48
###PBS -l mem=64GB
###PBS -l ngpus=4

#PBS -q gpuvolta
#PBS -P wz54
#PBS -l walltime=6:00:00

#PBS -l storage=scratch/wz54+gdata/wz54
#PBS -l wd
#PBS -l jobfs=10GB


source paths.sh

INPUT_DIR=${PBS_O_WORKDIR}
OUTPUT_DIR="${INPUT_DIR}/${JOB_NAME}"

INLINE="$(head -n ${PBS_ARRAY_INDEX} ${INPUT_DIR}/${SAMPLE_FILE} | tail -n 1)"

a=($(echo "$INLINE" | tr '\t' '\n'))
echo "My array: ${a[@]}"

echo "VARIABLES"

#THREADS=48
#MEM=64
#REF='jlm'
#BWA='fq2bam'

SAMPLE="${a[0]}"
RGID="${a[1]}"
FASTQ1="${a[2]}"
FASTQ2="${a[3]}"
BAMFILE="${FILEID}${REF}-${RGID}-${BWA}.bam"
RGFILE="${FILEID}${REF}-${RGID}-${BWA}-rg.bam"
DUPFILE="${FILEID}${REF}-${RGID}-${BWA}-rg-dup.bam"
PBDUPFILE="${FILEID}${REF}-${RGID}-${BWA}-pbdup.bam"
SAMFILE="${FILEID}${REF}-${RGID}-${BWA}.sam"
GVCFFILE="${FILEID}${REF}-${RGID}-${BWA}.g.vcf.gz"
PBGVCFFILE="${FILEID}${REF}-${RGID}-${BWA}-pb.g.vcf.gz"
#echo $JOB_NAME
echo $PBDUPFILE
echo "${PBS_JOBFS}"
echo ${PBS_ARRAY_INDEX}
echo $SAMPLE
echo $RGID
echo ${PBS_JOBID}
echo 'FASTQ1 SIZE'
wc -c ${FASTQ1}
echo 'FASTQ2 SIZE'
wc -c ${FASTQ2}

module load singularity 
echo "FQ2BAM START"


# run fq2bam
date
if [ "${FASTQ2}" = "INT" ]; then
	echo "fq2bam interleaved ${FASTQ1} not supported in parabricks"
	exit
else
	echo "fq2bam paired ${FASTQ1}  ${FASTQ2}"
	${PARABRICKS_DIR}/pbrun  fq2bam --ref ${REFERENCE_DIR}/${REF}.fna  --in-fq $FASTQ1 $FASTQ2  "@RG\tID:${RGID}\tLB:${RGID}\tSM:${SAMPLE}\tPL:ILLUMINA\tPU:${RGID}"  --read-group-id-prefix ${RGID}  --read-group-sm ${SAMPLE} --read-group-lb ${RGID}  --read-group-pl "ILLUMINA" --out-bam ${PBDUPFILE} --out-duplicate-metrics "${PBDUPFILE}.metrics.txt"  --license-file ${PARABRICKS_DIR}/license.bin 
fi
 
cp $PBDUPFILE $OUTDIR
echo "BAM FILE"
wc -c $PBDUPFILE
echo 'MERGESAM START'

# run haplotypecaller
echo 'HAPCALLER START'
date
${PARABRICKS_DIR}/pbrun haplotypecaller --ref ${REFERENCE_DIR}/${REF}.fna --in-bam ${PBDUPFILE}   --out-variants ${PBGVCFFILE} --gvcf --license-file ${PARABRICKS_DIR}/license.bin 

echo 'GVCF FILE'
wc -c $PBGVCFFILE
date
cp $PBGVCFFILE $OUTDIR
echo "SUCCESS"
date

