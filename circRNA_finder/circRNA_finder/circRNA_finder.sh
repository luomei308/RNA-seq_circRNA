#!/bin/bash
OPTIND=1

usage() {
    cat <<EOF
Usage:bash $0 -t <type> -s <sample_name> -a <absoutdir> -i <index_path> -c <find_circ_scripts> -f <fastq_path>
        -t <string> RNA-seq sequencing type: single or paired.
        -s <string> sample name which mactches the fastq for mapping in scripts. 
		-a <string> absolute out path .
        -i <string> absolute index path.
        -c <string> find_circ scripts absolute path.
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
			c) circRNA_finder_scripts=$OPTARG ;;
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
    perl $circRNA_finder_scripts/runStar.pl --inFile1 $fastq_path/$Samplename"_1p_trim.fastq.gz" --genomeDir $index_path --outPrefix $absoutdir/$Samplename/$Samplename >> $absoutdir/$Samplename/$Samplename.mapping.log 2>&1 
    echo "complete mapping" $Samplename ":" `date` >> $absoutdir/benchmarks.log
    ########## start postProcessStarAlignment #####################
	echo "start postProcessStarAlignment" $Samplename ":" `date` >> $absoutdir/benchmarks.log
    perl $circRNA_finder_scripts/postProcessStarAlignment.pl --starDir $absoutdir/$Samplename/$Samplename --minLen 200 --outDir $absoutdir/$Samplename/$Samplename
    echo "complete postProcessStarAlignment" $Samplename ":" `date` >> $absoutdir/benchmarks.log
else
    ############# strat mapping ##################
    echo "start mapping" $Samplename ":" `date` >> $absoutdir/benchmarks.log
	perl $circRNA_finder_scripts/runStar.pl --inFile1 $fastq_path/$Samplename"_1p_trim.fastq.gz" --inFile2 $fastq_path/$Samplename"_2p_trim.fastq.gz" --genomeDir $index_path --outPrefix $absoutdir/$Samplename/$Samplename >> $absoutdir/$Samplename/$Samplename.mapping.log 2>&1
    echo "complete mapping" $Samplename ":" `date` >> $absoutdir/benchmarks.log
    ########## start postProcessStarAlignment #####################
	echo "start postProcessStarAlignment" $Samplename ":" `date` >> $absoutdir/benchmarks.log
    perl $circRNA_finder_scripts/postProcessStarAlignment.pl --starDir $absoutdir/$Samplename/$Samplename --minLen 200 --outDir $absoutdir/$Samplename/$Samplename
    echo "complete postProcessStarAlignment" $Samplename ":" `date` >> $absoutdir/benchmarks.log
fi
