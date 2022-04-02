# Parabricks_Gadi_Pipeline
Parabricks variant calling pipelines on Gadi NCI

# Genomic sequence variant-calling

This pipeline performs variant-calling using genomic resequencing reads.

## Steps

1. Generate GVCF from Fastq for each fastq pair

  1.1 pbrun fq2bam
  
  1.2 pbrun haplotypecaller
  
2. Generate VCF for each chromosome using glnexus

3. Merge all chromosomes into whole-genome VCF


## Required files

    chromosomes.intervals - list of accession IDs of the fully assembled chromosomes. All unassembled non-chromosome contigs/scaffolds are merged in a separate VCF
    samples - list of **trimmed** Fastq files in this format: Sample name\tRead Group ID\tFastq1 path\tFastq2 path\tAverage size MB (optional)
    paths.sh - settings file to set project variables, user-specific and server-specific paths

|  paths.sh variable |     Description                                                                                                                                      |
|--------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|
|     JOB_NAME       |     job name, a job directory using this name will be created  |
| REFERENCE_DIR      | reference genome directory
|     REF            |     reference genome FASTA is in ${REFERENCE_DIR}/${REF}.fna                                                                               |
|     SAMPLE_FILE    |  <table><tr><td>list of samples, one read group per line, in this format: </td></tr><tr><td> sample_name\tread_group_id\tfastq1_path\tfastq2_path\n </td></tr><tr><td> For interleaved Fastq file, set fastq2_path to INT </td></tr></table> |
| CHROMOSOME_FILE |  list of chromosomes, one per line. Filename should end with .intervals  | 
| PICARD_PATH | path to picard.jar | 
| PARABRICKS_DIR | Parabricks directory | 

samples-fastq5-test.txt is an example SAMPLE_FILE in the required format, with teh file locations in Gadi. These files are already trimmed to remove adapters.

In the benchmarking task we used all the accessions in genomic_reads_accessions.txt. Note that all downloaded FASTQs need to be trimmed before using into the pipeline, and the trimmed file locations are the ones included in SAMPLES_FILE.



## Scripts

1. submit_array_pb.sh - is the job submission script to generate a g.vcf.gz file for each Fastq pair. 

2. submit_array_pb_glnexus_byint.sh - runs glnexus to generate the bcf, and converted to vcf.gz files for each chromosome. 

3. qsub merge_vcf.sh -  concatenates all chromosome + unassembled VCFs into a single VCF. The final output is the file ${JOB_NAME}/${REF}-${BWA}.vcf.gz


# RNS-Seq sequence variant-calling

This pipeline performs variant-calling using RNA-Seq paired-end read files. As required by differential expression studies, RNA-Seq reads usually comes in triplicates. This pipeline requires three read goups (3 Fastq pairs) per sample.

## Steps

1. Generate GVCF from Fastq for each fastq pair

  1.1 pbrun rna_fq2bam
  
  1.2 pbrun haplotypecaller
  
Note: steps 2 and 3 are exactly the same as with genomic variant-calling described above

2. Generate VCF for each chromosome using glnexus

3. Merge all chromosomes into whole-genome VCF


## Required files

    chromosomes.intervals - list of accession IDs of the fully assembled chromosomes. All unassembled non-chromosome contigs/scaffolds are merged in a separate VCF
    samples - list of TRIMMED Fastq files in this format: Sample name\tRead group 1\tFastq1_1 path\tFastq2_1 path\tRead group 2\tFastq1_2 path\tFastq2_2 path\tRead group 3\tFastq1_3 path\tFastq2_3 path\n
    paths_rna.sh - settings file to set project variables, user-specific and server-specific paths

In addition the the variablles defined in paths.sh, these are are requuired in paths_rna.sh

|  paths_rna.sh variable |     Description                                                                                                                                      |
|--------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| STAR_GENOMEDIR      | STAR reference genome directory, generated using STAR --runMode genomeGenerate |

Note: Parabricks rna_fq2bam is compatible only to STAR version 2.7.1a. 

samples-rna-test.txt is an example SAMPLE_FILE in the required format, with the file locations in Gadi. These files are already trimmed to remove adapters.

In the benchmarking task we used all the accessions in rnaseq_accessions.txt. Note that all downloaded FASTQs need to be trimmed before using into the pipeline, and the trimmed file locations are the ones included in SAMPLES_FILE.


## Steps

1. submit_array_pb_rna_fq2bam.sh


