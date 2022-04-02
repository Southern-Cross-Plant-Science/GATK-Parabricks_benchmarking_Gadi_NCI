
def get_stdout_info(fname):
	info=dict()
	with open(fname) as fin:
		line=fin.readline()
		while line:
			line=line.strip()
			if line.startswith("Exit Status:"):
				info['EXIT']=line.replace("Exit Status:","").strip()
			elif line.startswith("Service Units:"):
				info['SU']=line.replace("Service Units:","").strip()
			elif line.startswith("NCPUs Requested:"):
				cols=line.replace("NCPUs Requested:","").replace("NCPUs Used:","").strip().split()
				info['NCPUreq']=cols[0]
				info['NCPU']=cols[1]
			elif line.startswith("CPU Time Used:"):
				info['CPUTIME']=line.replace("CPU Time Used:","").strip()
			elif line.startswith("Memory Requested:"):
				cols=line.replace("Memory Requested:","").replace("Memory Used:","").strip().split()
				info['MEMORYreq']=cols[0]
				info['MEMORY']=cols[1]
			elif line.startswith("Walltime requested:"):
				cols=line.replace("Walltime requested:","").replace("Walltime Used:","").strip().split()
				info['WALLTIMEreq']=cols[0]
				info['WALLTIME']=cols[1]
			elif line.startswith("JobFS requested:"):
				cols=line.replace("JobFS requested:","").replace("JobFS Used:","").strip().split()
				info['JOBFSreq']=cols[0]
				info['JOBFS']=cols[1]
			line=fin.readline()
	return info




#======================================================================================
#                  Resource Usage on 2021-12-12 13:21:47:
#   Job Id:             32703092.gadi-pbs
#   Project:            wz54
#   Exit Status:        2
#   Service Units:      0.01
#   NCPUs Requested:    4                      NCPUs Used: 4
#                                           CPU Time Used: 00:00:06
#   Memory Requested:   8.0GB                 Memory Used: 358.79MB
#   Walltime requested: 48:00:00            Walltime Used: 00:00:03
#   JobFS requested:    20.0GB                 JobFS used: 0B
#======================================================================================

def time2secs(tstr):
	#print('tstr' + "=" + tstr)
	walltimes=tstr.split(":")
	wallsecs=int(walltimes[0])*3600+int(walltimes[1])*60+int(walltimes[2])
	return wallsecs

import os.path

jobname=""
sample_file=""
chrom_file=""
with open('paths.sh') as fin:
	line=fin.readline()
	while line:
		line=line.strip()
		if line.startswith("JOB_NAME="):
			jobname=line.replace("JOB_NAME=","").replace("\"","").replace("'","").strip()
		elif line.startswith("SAMPLE_FILE="):
			sample_file=line.replace("SAMPLE_FILE=","").replace("\"","").replace("'","").strip()
		elif line.startswith("CHROMOSOME_FILE="):
			chrom_file=line.replace("CHROMOSOME_FILE=","").replace("\"","").replace("'","").strip()
		line=fin.readline().strip()

sample2rg=dict()
with open(sample_file) as fin:
	line=fin.readline()
	while line:
		cols=line.strip().split()
		sm=cols[0]
		rg=cols[1]
		if sm in sample2rg:
			sample2rg[sm].append(rg)
		else:
			sample2rg[sm]=[]
			sample2rg[sm].append(rg)
		line=fin.readline().strip()

sm2info=dict()	
NCPUreqhc=1
NCPUreqbam=1
with open(sample_file) as fin:
	line=fin.readline()
	isample=0
	while line:
		isample+=1
		cols=line.strip().split()
		sm=cols[0]
		info_bam=get_stdout_info(jobname + "/" + jobname + "." + str(isample) + ".bam.stdout")
		info_bam['FASTQGZ_AVGSIZE']=cols[4]
		NCPUreqbam=int(info_bam['NCPUreq'])
		if time2secs(info_bam['WALLTIME'])>0:
			info_bam['%CPU_BAM'] =time2secs(info_bam['CPUTIME'])/(NCPUreqbam*time2secs(info_bam['WALLTIME']))

		total_su_hc=0
		total_cputimesec_hc=0
		max_walltimesec_hc=0
		total_walltimesec_hc=0
		with open(chrom_file) as fin2:
			line2=fin2.readline()
			ichrom=0
			while line2:
				ichrom+=1
				if os.path.isfile(jobname + "/" + jobname + "." + str(isample) + "." + str(ichrom) + ".hc.stdout"):
					info_bam_2=get_stdout_info(jobname + "/" + jobname + "." + str(isample) + "." + str(ichrom) + ".hc.stdout")
					total_su_hc+=float(info_bam_2['SU'])
					total_cputimesec_hc=time2secs(info_bam_2['CPUTIME'])
					NCPUreqhc=int(info_bam['NCPUreq'])
					wt=time2secs(info_bam_2['WALLTIME'])
					total_walltimesec_hc+=wt
					if wt>max_walltimesec_hc:
						max_walltimesec_hc=wt
				line2=fin2.readline().strip()


		if os.path.isfile(jobname + "/" + jobname + "." + str(isample) + ".XL.hc.stdout"):
			info_bam_2=get_stdout_info(jobname + "/" + jobname + "." + str(isample) + ".XL.hc.stdout")
			total_su_hc+=float(info_bam_2['SU'])
			total_cputimesec_hc=time2secs(info_bam_2['CPUTIME'])
			wt=time2secs(info_bam_2['WALLTIME'])
			total_walltimesec_hc+=wt
			if wt>max_walltimesec_hc:
				max_walltimesec_hc=wt

		if total_walltimesec_hc>0:
			info_bam['WALLTIMESEC_MAX_HC']=max_walltimesec_hc
			info_bam['WALLTIMESEC_TOTAL_HC']=total_walltimesec_hc
			info_bam['CPUTIMESEC_TOTAL_HC']=total_cputimesec_hc
			info_bam['SU_TOTAL_HC']=total_su_hc
			info_bam['%CPU_HC']=total_cputimesec_hc/(NCPUreqhc*total_walltimesec_hc)
			
			if len(sample2rg[sm])>1:
				if sm in sm2info:
					sm2info[sm].append(info_bam)
				else:
					sm2info[sm]=[]
					sm2info[sm].append(info_bam)
			else:
				print(str(info_bam))

		line=fin.readline().strip()


print('multi RGs samples')
for sm in sm2info:
	infos=sm2info[sm]
	su_total=0
	cpu_total=0
	walltime_total=0
	fqmb_total=0
	info_hc=dict()
	for info in infos:
		walltime_total+=info['WALLTIMESEC_TOTAL_HC']
		cpu_total+=info['CPUTIMESEC_TOTAL_HC']
		su_total+=info['SU_TOTAL_HC']
		fqmb_total+=float(info['FASTQGZ_AVGSIZE'].replace("MB","").strip())
	info_hc['FASTQGZ_AVGSIZE']=fqmb_total
	info_hc['WALLTIMESEC_TOTAL_HC']=walltime_total
	info_hc['CPUTIMESEC_TOTAL_HC']=cpu_total
	info_hc['SU_TOTAL_HC']=su_total
	info_hc['%CPU']=cpu_total/(NCPUreqhc*walltime_total)
	print(info_hc)



su_gdb_total=0
su_genotype_total=0

with open(chrom_file) as fin2:
	line2=fin2.readline()
	ichrom=0
	while line2:
		chrom=line2.strip()
		ichrom+=1
		info_bam_2=get_stdout_info(jobname + "/" + jobname + "." + str(ichrom) + ".gdb.stdout")
		info_bam_3=get_stdout_info(jobname + "/" + jobname + "." + str(ichrom) + ".genotype.stdout")
		su_gdb_total+=float(info_bam_2['SU'])
		su_genotype_total+=float(info_bam_3['SU'])

		line2=fin2.readline().strip()


info_bam_2=get_stdout_info(jobname + "/" + jobname + ".XL.gdb.stdout")
info_bam_3=get_stdout_info(jobname + "/" + jobname + ".XL.genotype.stdout")
su_gdb_total+=float(info_bam_2['SU'])
su_genotype_total+=float(info_bam_3['SU'])

print('su_gdb_total=' + str(su_gdb_total))

print('su_genotype_total=' + str(su_genotype_total))

