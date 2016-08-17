#!/bin/bash
# ------------------------------------------------------------------
# [Charles VAN GOETHEM] gzip2leon
#          Convert fastq.gz to leon
# ------------------------------------------------------------------
VERSION=0.1.0
USAGE="Usage:	gzip2leon.sh -h -f <filename.fastq.gzip> -r <repertory>"
PWD_PROJECT=$(pwd)
PATH_LEON="/Users/adminbioinfo/Documents/Leon/leon/leon";

usage ()
{
	echo 'This script convert fastq.gz to fastq.leon';
	echo 'Usage :';
	echo '	* gzip2leon.sh -h	: show this help message';
	echo '';
	echo '	* gzip2leon.sh -f|--file <file.fastq.gz>	: convert the file.fastq.gz to file.fastq.leon';
	echo '	* gzip2leon.sh -r|--repertory <repertory>	: convert all fastq.gz into the repertory in fastq.leon (can be used with -f option)';
	exit
}

# --- Option processing --------------------------------------------

# Parse command line
while [ "$1" != "" ]; do
	case $1 in
		-f | --file )			shift
								filename=$1
								;;
		-r | --repertory )		shift
								repertory=$1
								;;
		-h | --help )			usage
								exit
								;;
		* )						usage
								exit 1
	esac
	shift
done

##### Control options
### First level : check if options are used
if [[ -z "$filename" ]] && [[ -z "$repertory" ]]
then
    usage
    exit
fi

### Second level : check if the files or repertory exists
if [[ ! -e "$filename" ]] && [[ ! -z "$filename" ]]
then
	echo "File : '$filename' does not exist !";
    usage
    exit
fi

if [[ ! -e "$repertory" ]] && [[ ! -z "$repertory" ]]
then
	echo "Repertory : '$repertory' does not exist !";
    usage
    exit
fi

### Third level : check if "filename" is a file and "repertory" is a repertory
if [[ ! -f "$filename" ]] && [[ ! -z "$filename" ]]
then
	echo "File : '$filename' is not a regular file !";
    usage
    exit
fi

if [[ ! -d "$repertory" ]] && [[ ! -z "$repertory" ]]
then
	echo "Repertory : '$repertory' is not a repertory !";
    usage
    exit
fi

### Bonus level : check if "filename" is with ".fastq.gz" extension
if [ ! ${filename: -9} == ".fastq.gz" ]
then
	echo "File : '$filename' is not a '.fastq.gz'";
    usage
    exit
fi
# -- Functions ---------------------------------------------------------

convert_file_test () { 
	echo "Conversion of file : '$1'";
	echo "gunzip $1";
	fileBase=$(basename "$1");
	fileBase="${fileBase%.*}"
	echo "$PATH_LEON -c -file $fileBase -lossless";
}
convert_file () { 
	echo "Conversion of file : '$1'";
	gunzip $1
	fileBase=$(basename "$1");
	fileBase="${fileBase%.*}"
	$PATH_LEON -c -file $fileBase -lossless
}

# -- Body ---------------------------------------------------------

if [[ ! -z "$repertory" ]]
then
	cd $repertory

	EXT=fastq.gz

	for i in *; do
		echo "########################################################"
		if [ "${i}" != "${i%.${EXT}}" ];then
			#convert_file_test $i
			convert_file $i
		fi
		echo ""
	done

	cd $PWD_PROJECT
fi

if [[ ! -z "$filename" ]]
then
	DIR=$(dirname "${filename}")
	
	cd $DIR
	
	#convert_file_test $filename
	convert_file $filename
	
	cd $PWD_PROJECT
fi


# -----------------------------------------------------------------





