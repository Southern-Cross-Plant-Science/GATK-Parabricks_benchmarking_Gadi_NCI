

SAMPLE_FILE=""
JOB_NAME=""
REF=""
BWA=""
PATHS='paths.sh'

with open(PATHS) as fin:
	line=fin.readline()
	while line:
		line=line.strip()
		if line.startswith("SAMPLE_FILE="):
			SAMPLE_FILE=line.replace("SAMPLE_FILE=","").replace("\"","").replace("'","")
		elif line.startswith("JOB_NAME="):
			JOB_NAME=line.replace("JOB_NAME=","").replace("\"","").replace("'","")
		elif line.startswith("REF="):
			REF=line.replace("REF=","").replace("\"","").replace("'","")
		elif line.startswith("BWA="):
			BWA=line.replace("BWA=","").replace("\"","").replace("'","")
		line=fin.readline()

sms=dict()
with open(SAMPLE_FILE) as fin:
	line=fin.readline()
	while line:
		line=line.strip()
		cols=line.split()
		sm=cols[0]
		rg=cols[1]
		if sm in sms:
			sms[sm].append(rg)
		else:
			sms[sm]=[]
			sms[sm].append(rg)
		line=fin.readline()


import os
import os.path

os.system("mkdir " + JOB_NAME)

for sm in sms:
	if len(sms[sm])>1:
		with open(JOB_NAME+"/merge_bam_" + sm + ".tmp", "w") as outfile:
			outline=""
			rgs=sms[sm]
			for rg in rgs:
				outline+="I=${JOB_NAME}/${REF}-"+rg+"-${BWA}-rg-dup.bam \\\n"

			outline+="O=${JOB_NAME}/${REF}-"+sm+"-${BWA}-rg-dup.bam \\\n"
			#outline+=" USE_THREADING=true --CREATE_INDEX --MAX_RECORDS_IN_RAM 5000000 --REFERENCE_SEQUENCE ${REFERENCE_DIR}/${REF}.fna \n"
			#outline+=" USE_THREADING=true  --REFERENCE_SEQUENCE ${REFERENCE_DIR}/${REF}.fna \n"
			outfile.write(outline)

		os.system("cat merge_bams.pre " + JOB_NAME+"/merge_bam_" + sm + ".tmp > " + JOB_NAME+"/merge_bam_" + sm + ".sh" )
		print("qsub -N merge_bams." + sm + " -e " + JOB_NAME +"/merge_bams." + sm + ".stderr -o " + JOB_NAME +"/merge_bams." + sm + ".stdout" + JOB_NAME+"/merge_bam_" + sm + ".sh" )
		os.system("qsub -N merge_bams." + sm + " -e " + JOB_NAME +"/merge_bams." + sm + ".stderr -o " + JOB_NAME +"/merge_bams." + sm + ".stdout "  + JOB_NAME+"/merge_bam_" + sm + ".sh" )
		os.system("rm " + JOB_NAME+"/merge_bam_" + sm + ".tmp")
	else:
		rgs=sms[sm]
		if not os.path.isfile(JOB_NAME+ "/" +  REF + "-"+ sm +"-" + BWA + "-rg-dup.bam"):
			#print("ln -s " + REF + "-"+rgs[0]+"-" + BWA + "-rg-dup.bam  "	+ JOB_NAME+ "/" +  REF + "-"+ sm +"-" + BWA + "-rg-dup.bam")
			#os.system("ln -s " + REF + "-"+rgs[0]+"-" + BWA + "-rg-dup.bam  "	+ JOB_NAME+ "/" +  REF + "-"+ sm +"-" + BWA + "-rg-dup.bam")
			print("mv " + JOB_NAME+ "/" +  REF + "-"+rgs[0]+"-" + BWA + "-rg-dup.bam  "	+ JOB_NAME+ "/" +  REF + "-"+ sm +"-" + BWA + "-rg-dup.bam")
			os.system("mv " + JOB_NAME+ "/" + REF + "-"+rgs[0]+"-" + BWA + "-rg-dup.bam  "	+ JOB_NAME+ "/" +  REF + "-"+ sm +"-" + BWA + "-rg-dup.bam")
		




