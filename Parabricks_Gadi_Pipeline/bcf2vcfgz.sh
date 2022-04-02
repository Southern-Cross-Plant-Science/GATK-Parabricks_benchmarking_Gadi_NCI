
echo "bcftools start"

module load bcftools
bcftools view --threads 5 -Oz -o "${OUTPUT_DIR}/${REF}-${INCLUDE}-${BWA}.vcf.gz"  "${OUTPUT_DIR}/${REF}-${INCLUDE}-${BWA}.bcf"

echo "bcftools done"

