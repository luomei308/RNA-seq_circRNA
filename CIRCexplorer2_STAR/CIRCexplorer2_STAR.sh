#!/bin/bash
OPTIND=1

usage() {
    cat <<EOF
Usage:bash $0 -t <type> -s <sample_name> -a <absoutdir> -i <index_path> -f <fastq_path>
        -t <string> RNA-seq sequencing type: single or paired.
        -s <string> sample name which mactches the fastq for mapping in scripts. 
		-a <string> absolute out path .
        -i <string> absolute index path.
        -f <string> absolute fastq path.        
EOF
    exit 1
}


while getopts :t:s:a:i:c:f: ARGS; do
	case $ARGS in
			t) type=$OPTARG ;;
			s) Samplename=$OPTARG ;;
			a) absoutdir=$OPTARG ;;
			i) index_path=$OPTARG ;;
			f) fastq_path=$OPTARG ;;
        *) usage ;;
    esac
done

mkdir -p $absoutdir/$Samplename
if [ ! -f "$absoutdir/benchmarks.log" ]; then 
	touch "$absoutdir/benchmarks.log" 
fi 


if [ "$type" == "single" ]; then
    ############# strat mapping ##################
    echo "start mapping" $Samplename ":" `date` >> $absoutdir/benchmarks.log
	STAR --chimSegmentMin 10 --runThreadN 32 --genomeDir $index_path --readFilesCommand gunzip -c --readFilesIn $fastq_path/$Samplename"_1p_trim.fastq.gz" --outFileNamePrefix $absoutdir/$Samplename/$Samplename >> $absoutdir/$Samplename/$Samplename.mapping.logs 2>&1 	
	echo "complete mapping" $Samplename ":" `date` >> $absoutdir/benchmarks.log	
    ########## start parser #####################
    echo "start parser" $Samplename ":" `date` >> $absoutdir/benchmarks.log 
	CIRCexplorer2 parse -t STAR $absoutdir/$Samplename/$Samplename.Chimeric.out.junction -b $absoutdir/$Samplename/back_spliced_junction.bed >$absoutdir/$Samplename/$Samplename.CIRCexplorer2_parse.log
	#sed -i 's/^/chr/g' $absoutdir/$Samplename/back_spliced_junction.bed
    echo "complete parser" $Samplename ":" `date` >> $absoutdir/benchmarks.log
    ########## start annote #####################
    echo "start annote" $Samplename ":" `date` >> $absoutdir/benchmarks.log
    CIRCexplorer2 annotate -r $index_path/hg38_ref_all.txt -g $index_path/hg38.fa -b $absoutdir/$Samplename/back_spliced_junction.bed -o $absoutdir/$Samplename/$Samplename.circularRNA_known.txt > $absoutdir/$Samplename/$Samplename.CIRCexplorer2_annotate.log
    echo "complete annote" $Samplename ":" `date` >> $absoutdir/benchmarks.log
else
    ############# strat mapping ##################
    echo "start mapping" $Samplename ":" `date` >> $absoutdir/benchmarks.log
	STAR --chimSegmentMin 10 --runThreadN 32--genomeDir $index_path --readFilesCommand gunzip -c --readFilesIn $fastq_path/$Samplename"_1p_trim.fastq.gz" $fastq_path/$Samplename"_2p_trim.fastq.gz" --outFileNamePrefix $absoutdir/$Samplename/$Samplename >> $absoutdir/$Samplename/$Samplename.mapping.logs	2>&1 
	echo "complete mapping" $Samplename ":" `date` >> $absoutdir/benchmarks.log
    ########## start parser #####################
    echo "start parser" $Samplename ":" `date` >> $absoutdir/benchmarks.log
	CIRCexplorer2 parse -t STAR $absoutdir/$Samplename/$Samplename.Chimeric.out.junction -b $absoutdir/$Samplename/back_spliced_junction.bed >$absoutdir/$Samplename/$Samplename.CIRCexplorer2_parse.log
	#sed -i 's/^/chr/g' $absoutdir/$Samplename/back_spliced_junction.bed
    echo "complete parser" $Samplename ":" `date` >> $absoutdir/benchmarks.log
    ########## start annote #####################
	echo "start annote" $Samplename ":" `date` >> $absoutdir/benchmarks.log
    CIRCexplorer2 annotate -r $index_path/hg38_ref_all.txt -g $index_path/hg38.fa -b $absoutdir/$Samplename/back_spliced_junction.bed -o $absoutdir/$Samplename/$Samplename.circularRNA_known.txt > $absoutdir/$Samplename/$Samplename.CIRCexplorer2_annotate.log
    echo "complete annote" $Samplename ":" `date` >> $absoutdir/benchmarks.log
fi


