###########   RNA-seq gene cirRNA Pipeline  ##########

workflow  CIRCexplorer2_flow{
String index_path
File Sample_names
String absoutdir
String fastq_path
String type
String CIRCexplorer2_script
Array[Array[String]] inputSamples = read_tsv(Sample_names)

################# CALL ##################
call step_one{
    input:absoutdir=absoutdir
}

scatter (Samplename in inputSamples){

call step_two{
    input:Samplename=Samplename[0],
        fastq_path=fastq_path,
	index_path=index_path,
	absoutdir=absoutdir,
	type=type,
	CIRCexplorer2_script=CIRCexplorer2_script
	
	}
}

#call step_three{
 #   input:absoutdir=absoutdir,
#	mRIN_script_path=mRIN_script_path,
#	config=step_two.config
	
}

#}

##############  TASKS  ################
#############  mkdir    ############
task step_one{

String absoutdir
command {
         if [ ! -d "${absoutdir}" ]; then mkdir ${absoutdir};fi && \
	 if [ ! -f "${absoutdir}/benchmarks.log" ]; then touch ${absoutdir}/benchmarks.log ;fi
}
output {
    File results="${absoutdir}"
}

}
############# processing one    ############
task step_two{

String Samplename
String fastq_path
String index_path
String absoutdir
String type
String CIRCexplorer2_script
command {
	docker run --user $EUID -v ${absoutdir}:/absoutdir -v ${fastq_path}:/fastq_path -v ${index_path}:/index_path -v ${CIRCexplorer2_script}:/CIRCexplorer2_script dockerluom/circ_find \
	bash /CIRCexplorer2_script/CIRCexplorer2_STAR.sh -t ${type} -s ${Samplename} -a /absoutdir -i /index_path -f /fastq_path
}
output {
    File results="${absoutdir}"
}

}
