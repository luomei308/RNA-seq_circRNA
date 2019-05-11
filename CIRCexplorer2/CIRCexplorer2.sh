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
    tophat2 -a 6 --microexon-search -m 2 -p 32 -G $index_path/hg38_kg.gtf -o $absoutdir/$Samplename $index_path/bowtie2_index $fastq_path/$Samplename"_1p_trim.fastq.gz" >> $absoutdir/$Samplename/$Samplename.mapping.logs	2>&1 	
    bamToFastq -i $absoutdir/$Samplename/unmapped.bam -fq $absoutdir/$Samplename/unmapped.fastq
	echo "complete mapping" $Samplename ":" `date` >> $absoutdir/benchmarks.log
	echo "start unmapping" $Samplename ":" `date` >> $absoutdir/benchmarks.log
    tophat2 -o $absoutdir/$Samplename/fusion -p 32 --fusion-search --keep-fasta-order --bowtie1 --no-coverage-search $index_path/bowtie1_index $absoutdir/$Samplename/unmapped.fastq >> $absoutdir/$Samplename/$Samplename.unmapped.logs 2>&1
    echo "complete unmapping" $Samplename ":" `date` >> $absoutdir/benchmarks.log
    ########## start parser #####################
    echo "start parser" $Samplename ":" `date` >> $absoutdir/benchmarks.log 
    CIRCexplorer2 parse -t TopHat-Fusion $absoutdir/$Samplename/fusion/accepted_hits.bam -b $absoutdir/$Samplename/fusion/$Samplename.back_spliced_junction.bed > $absoutdir/$Samplename/$Samplename.CIRCexplorer2_parse.log
    echo "complete parser" $Samplename ":" `date` >> $absoutdir/benchmarks.log
    ########## start annote #####################
    echo "start annote" $Samplename ":" `date` >> $absoutdir/benchmarks.log
    CIRCexplorer2 annotate -r $index_path/hg38_ref_all.txt -g $index_path/hg38.fa -b $absoutdir/$Samplename/fusion/$Samplename.back_spliced_junction.bed -o $absoutdir/$Samplename/fusion/$Samplename.circularRNA_known.txt > $absoutdir/$Samplename/$Samplename.CIRCexplorer2_annotate.log
    echo "complete annote" $Samplename ":" `date` >> $absoutdir/benchmarks.log
else
    ############# strat mapping ##################
    echo "start mapping" $Samplename ":" `date` >> $absoutdir/benchmarks.log
	tophat2 -a 6 --microexon-search -m 2 -p 32 -G $index_path/hg38_kg.gtf -o $absoutdir/$Samplename $index_path/bowtie2_index $fastq_path/$Samplename"_1p_trim.fastq.gz" $fastq_path/$Samplename"_2p_trim.fastq.gz" >> $absoutdir/$Samplename/$Samplename.mapping.logs	2>&1 
    bamToFastq -i $absoutdir/$Samplename/unmapped.bam -fq $absoutdir/$Samplename/unmapped.fastq
	echo "complete mapping" $Samplename ":" `date` >> $absoutdir/benchmarks.log
	echo "start unmapping" $Samplename ":" `date` >> $absoutdir/benchmarks.log
    tophat2 -o $absoutdir/$Samplename/fusion -p 32 --fusion-search --keep-fasta-order --bowtie1 --no-coverage-search $index_path/bowtie1_index $absoutdir/$Samplename/unmapped.fastq  >> $absoutdir/$Samplename/$Samplename.unmapped.logs 2>&1
    echo "complete unmapping" $Samplename ":" `date` >> $absoutdir/benchmarks.log
    ########## start parser #####################
    echo "start parser" $Samplename ":" `date` >> $absoutdir/benchmarks.log
    CIRCexplorer2 parse -t TopHat-Fusion $absoutdir/$Samplename/fusion/accepted_hits.bam -b $absoutdir/$Samplename/fusion/$Samplename.back_spliced_junction.bed > $absoutdir/$Samplename/$Samplename.CIRCexplorer2_parse.log 
    echo "complete parser" $Samplename ":" `date` >> $absoutdir/benchmarks.log
    ########## start annote #####################
	echo "start annote" $Samplename ":" `date` >> $absoutdir/benchmarks.log
    CIRCexplorer2 annotate -r $index_path/hg38_ref_all.txt -g $index_path/hg38.fa -b $absoutdir/$Samplename/$Samplename.fusion/$Samplename.back_spliced_junction.bed -o $absoutdir/$Samplename/fusion/$Samplename.circularRNA_known.txt > $absoutdir/$Samplename/$Samplename.CIRCexplorer2_annotate.log
    echo "complete annote" $Samplename ":" `date` >> $absoutdir/benchmarks.log
fi


