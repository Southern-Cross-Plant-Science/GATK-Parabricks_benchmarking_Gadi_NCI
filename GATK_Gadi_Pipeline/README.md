# GATK_Gadi_Pipeline
GATK variant calling pipeline on Gadi NCI

# Genomic sequence variant-calling

This pipeline performs variant-calling using genomic resequencing reads.

## Steps
As the GATK variant calling involves parallelized and merging steps, the pipeline is divided into subtasks to efficiently use service units. Also for large samples, the complete  pipeline can take longer than 48 hrs (the default maximum wall time in Gadi). The major steps are:
1. Generate sorted, marked BAM files for each Fastq pairs (read group)

    1.1 alignment using BWA mem
  
    1.2 GATK AddOrReplaceReadGroups
  
    1.3 GATK SamSort
  
    1.4 GATK MarkDuplicatesSpark
  
2. Merge the BAM files for samples with multiple read groups, change to sample notation for single read groups

3. Joint genotyping per chromosome

    3.1 Generate GVCF file per chromosome using GATK HaplotypeCaller
    
    3.2 Import GVCF to GenomicsDB

    3.3 Generate VCF

4.  Merge per chromosome VCF into whole-genome VCF

## Required files

    chromosomes.intervals - list of accession IDs of the fully assembled chromosomes. All unassembled non-chromosome contigs/scaffolds are merged in a separate VCF
    
    samples - list of **trimmed** Fastq files in this format: Sample_name\tReadgroup_ID\tFastq1_path\tFastq2_path\t(Optional)Average size MB
    
    paths.sh - settings file to set project variables, user-specific and server-specific paths

|  paths.sh variable |     Description                                                                                                                                      |
|--------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|
|     JOB_NAME       |     job name, a job directory using this name will be created  |
| REFERENCE_DIR      | reference genome directory
|     REF            |     reference genome FASTA is in ${REFERENCE_DIR}/${REF}.fna                                                                               |
|     SAMPLE_FILE    |  <table><tr><td>list of samples, one read group per line, in this format: </td></tr><tr><td> sample_name\tread_group_id\tfastq1_path\tfastq2_path\n </td></tr><tr><td> For interleaved Fastq file, set fastq2_path to INT. ENTER at last line </td></tr></table> |
| CHROMOSOME_FILE |  list of chromosomes, one per line. Filename should end with .intervals. ENTER at last line  | 
| PICARD_PATH | path to picard.jar | 
| HETEROZYGOSITY | --heterozygozity parameter for HaplotypeCaller and GenotypeGVCFs |
| INDEL_HETEROZYGOSITY | --indel_heterozygozity parameter for HaplotypeCaller and GenotypeGVCFs |


samples-fastq5-test.txt is an example SAMPLE_FILE in the required format, with teh file locations in Gadi. These files are already trimmed to remove adapters.

In the benchmarking task we used all the accessions in genomic_reads_accessions.txt. Note that all downloaded FASTQs need to be trimmed before using into the pipeline, and the trimmed file locations are the ones included in SAMPLES_FILE.


## Scripts

The job submission scripts submit_array_*.sh submit an HPC job for each sample and chromosome iteration. This is recommended instead of using job arrays which is not supported in Gadi. The maximum number of simultaneous jobs is (N_chromosomes+1)x(N_fastqpairs) when using submit_array_gatk_hc_byint.sh

1. submit_array_gatkbam.sh  - is the job submission script to generate a BAM file for each Fastq pair. 

2. python merge_bams.py - Merge bam for the same sample from different read groups/fastq pairs, single read groups are renamed to sample names

3.1 submit_array_gatk_hc_byint.sh  - runs GATK HaplotypeCaller to generate the GVCF files from BAM for each sample and chromosome. 

3.2 submit_array_genomicdb_byint.sh - imports GVCF into GenonomicsDB for each chromosome. 

3.3 submit_array_genotypegvcf_byint.sh - performs joint genotyping using the GenonomicsDB database to generate the vcf.gz file for each chromosome. 

    Notes: 3.1, 3.2 and 3.3 could have been merged into one pipeline by moving these steps inside the chromosome loop. However for large number of samples or large sample size, each step can take long time to execute and may exceed the maximum wall time.

4. qsub merge_vcfs.sh - concatenates all chromosome + unassembled VCFs into a single VCF. The final output is the file ${JOB_NAME}/${REF}-${BWA}.vcf.gz


# RNA-Seq sequence variant-calling

This pipeline performs variant-calling using RNA-Seq paired-end read files. As required by differential expression studies, RNA-Seq reads usually comes in triplicates. This pipeline requires three read goups (3 Fastq pairs) per sample.

## Steps

1. Generate sorted, marked BAM files for each sample

    1.1 alignment using STAR 
  
    1.2 GATK SamSort
  
    1.3 GATK MarkDuplicatesSpark

    1.4 GATK SplitNCigar

Steps 2 and 3 are exactly the same was with genomic sequence variant-calling

2. Joint genotyping per chromosome

    2.1 Generate GVCF file per chromosome using GATK HaplotypeCaller
    
    2.2 Import GVCF to GenomicsDB and generate VCF using GenotypeGVCFs

3.  Merge per chromosome VCF into whole-genome VCF

## Required files

    chromosomes.intervals - list of accession IDs of the fully assembled chromosomes. All unassembled non-chromosome contigs/scaffolds are merged in a separate VCF
    samples - list of TRIMMED Fastq files in this format: Sample name\tRead group 1\tFastq1_1 path\tFastq2_1 path\tRead group 2\tFastq1_2 path\tFastq2_2 path\tRead group 3\tFastq1_3 path\tFastq2_3 path\n
    paths_rna.sh - settings file to set project variables, user-specific and server-specific paths

In addition the the variablles defined in paths.sh, these are are requuired in paths_rna.sh

|  paths_rna.sh variable |     Description                                                                                                                                      |
|--------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|
|     STAR_PATH       |  path to STAR executable  |
| STAR_GENOMEDIR      | STAR reference genome directory, generated using STAR --runMode genomeGenerate |

Note: Parabricks rna_fq2bam is compatible only to STAR version 2.7.1a. For benchmarking of GATK and Parabricks, version 2.7.1a should be used for both.

samples-rna-test.txt is an example SAMPLE_FILE in the required format, with the file locations in Gadi. These files are already trimmed to remove adapters.

In the benchmarking task we used all the accessions in rnaseq_accessions.txt. Note that all downloaded FASTQs need to be trimmed before using into the pipeline, and the trimmed file locations are the ones included in SAMPLES_FILE.


## Steps

1. submit_array_gatk_rna_fq2bam.sh

2.1 submit_array_gatk_rna_hc_byint.sh

2.2 submit_array_rna_genomicdb_byint.sh

3. qsub merge_rna_vcfs.sh

