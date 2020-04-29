###########   RNA-seq gene fusion Pipeline  ##########

workflow circRNA_finder_flow{
String index_path
File Sample_names
String absoutdir
String fastq_path
String type
String circRNA_finder_script
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
	circRNA_finder_script=circRNA_finder_script
	
	}
}

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
String circRNA_finder_script
command {
	docker run --user $EUID -v ${absoutdir}:/absoutdir -v ${fastq_path}:/fastq_path -v ${index_path}:/index_path -v ${circRNA_finder_script}:/circRNA_finder_script dockerluom/circ_find \
	bash /circRNA_finder_script/circRNA_finder.sh -t ${type} -s ${Samplename} -a /absoutdir -i /index_path -c /circRNA_finder_script -f /fastq_path
}
output {
    File results="${absoutdir}"
}

}
