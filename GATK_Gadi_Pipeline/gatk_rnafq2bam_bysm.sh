#!/bin/bash
### Job name
#PBS -N fq2bam4_24_64
### Output files
#PBS -o fq2bam4_24_64.stdout
#PBS -e fq2bam4_24_64.stderr

#PBS -r y
#PBS -l ncpus=1
####PBS -l mem=128GB
#PBS -l mem=16GB
####PBS -l ngpus=4
#PBS -q normal
#PBS -P wz54
#PBS -l walltime=48:00:00
### Number of nodes
###PBS -l nodes=4:compute#shared  # not supported

#PBS -l storage=scratch/wz54+gdata/wz54
#PBS -l wd
#PBS -l jobfs=10GB


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


mkdir ${OUTPUT_DIR}/${SAMPLE}

echo "START"
date

module load gatk

if [ ! -f "${OUTPUT_DIR}/${SAMPLE}/Aligned.sortedByCoord.out.markdup.bam" ]; then

if [ ! -f "${OUTPUT_DIR}/${SAMPLE}/Aligned.sortedByCoord.out.samsort.bam" ]; then

if [ ! -f "${OUTPUT_DIR}/${SAMPLE}/Aligned.sortedByCoord.out.bam" ]; then

${STAR_PATH} --runThreadN ${THREADS} --genomeDir $STAR_GENOMEDIR \
--readFilesIn ${FASTQ1_1},${FASTQ1_2},${FASTQ1_3}  ${FASTQ2_1},${FASTQ2_2},${FASTQ2_3} \
--readFilesCommand gunzip -c \
--outFileNamePrefix "${OUTPUT_DIR}/${SAMPLE}/" \
--outSAMattrRGline ID:${RGID_1} LB:${RGID_1} PL:ILLUMINA PU:${RGID_1} SM:$SAMPLE , ID:${RGID_2} LB:${RGID_2} PL:ILLUMINA PU:${RGID_2} SM:$SAMPLE , ID:${RGID_3} LB:${RGID_3} PL:ILLUMINA PU:${RGID_3} SM:$SAMPLE \
--outSAMtype BAM SortedByCoordinate --outReadsUnmapped Fastx --outSAMunmapped Within --outSAMattributes NH HI NM MD AS
 
echo "STAR"
date

fi

# AddOrReplaceReadGroups not required since read groups were assigned in STAR --outSAMattrRGline
#java "-Xmx${MEM}g" -jar /g/data/wz54/lm0682/software/picard.2.22.4.jar  AddOrReplaceReadGroups I= ${OUTPUT_DIR}/Aligned.sortedByCoord.out.samsort.bam  O=outstar_${RGID}/Aligned.sortedByCoord.out.samsort2.bam  RGID=$RGID RGLB=$RGID RGPL=ILLUMINA RGPU=$RGID RGSM=$SAMPLE MAX_RECORDS_IN_RAM=null


module load samtools
samtools sort -@ $THREADS  -O bam -o ${OUTPUT_DIR}/${SAMPLE}/Aligned.sortedByCoord.out.samsort.bam ${OUTPUT_DIR}/${SAMPLE}/Aligned.sortedByCoord.out.bam

echo "sort"
date

fi

rm -rf ${OUTPUT_DIR}/${SAMPLE}/Aligned.sortedByCoord.out.markdup.bam*

gatk --java-options "-Xmx${MEM}g" MarkDuplicatesSpark \
     -I ${OUTPUT_DIR}/${SAMPLE}/Aligned.sortedByCoord.out.samsort.bam  \
     -O ${OUTPUT_DIR}/${SAMPLE}/Aligned.sortedByCoord.out.markdup.bam  \
     -M ${OUTPUT_DIR}/${SAMPLE}/marked_dup_metrics.txt

echo "MarkDuplicatesSpark"
date

fi

REF_FASTA="${REFERENCE_DIR}/${REF}.fna"

gatk  --java-options "-Xmx${MEM}g" SplitNCigarReads \
      -R $REF_FASTA \
      -I ${OUTPUT_DIR}/${SAMPLE}/Aligned.sortedByCoord.out.markdup.bam \
      -O ${OUTPUT_DIR}/${SAMPLE}/Aligned.sortedByCoord.out.splitncigar.bam \

echo "SplitNCigarReads"
date


#gatk --java-options "-Xmx${MEM}g" HaplotypeCaller  \
#   -R $REF_FASTA \
#   -I ${OUTPUT_DIR}/${SAMPLE}/Aligned.sortedByCoord.out.splitncigar.bam \
#   -O ${OUTPUT_DIR}/${SAMPLE}/${REF}-${SAMPLE}.g.vcf.gz \
#   -ERC GVCF

echo "HaplotypeCaller"
date


if [ -f "${OUTPUT_DIR}/${SAMPLE}/${REF}-${SAMPLE}.g.vcf.gz.tbi" ]; then
    rm ${OUTPUT_DIR}/${SAMPLE}/Aligned.sortedByCoord.out.markdup.bam
    rm ${OUTPUT_DIR}/${SAMPLE}/Aligned.sortedByCoord.out.samsort.bam 
    rm ${OUTPUT_DIR}/${SAMPLE}/Aligned.sortedByCoord.out.bam
fi
