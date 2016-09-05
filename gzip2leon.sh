#!/bin/bash
# ------------------------------------------------------------------
# [Charles VAN GOETHEM] gzip2leon
#          Convert fastq.gz to leon
# ------------------------------------------------------------------
VERSION=0.1.0
USAGE="Usage:	gzip2leon.sh -h -f <filename.fastq.gzip> -r <directory>"
PWD_PROJECT=$(pwd)
PATH_LEON="/Users/adminbioinfo/Documents/Leon/leon/leon";
RED='\033[1;31m';
WARNING='\033[1;33m';
PINKUNICORN='\033[0;35m';
NC='\033[0m'; # No Color

usage ()
{
	echo 'This script convert fastq.gz to fastq.leon and reverse.';
	echo 'Usage : gzip2leon.sh';
	echo '	Mandatory arguments :';
	echo '		* -f|--file <file.fastq.gz>	: convert the file.fastq.gz to file.fastq.leon (can be used with -d option)';
	echo '		* -d|--directory <directory>	: convert all fastq.gz into the directory in fastq.leon (can be used with -f option)';
	echo '		* -r|--recovery	<file.leon or directory> : If you want recover fastq from file.leon (can be used with others option but it is not recommended)';
	echo '';
	echo '	Optional arguments :';
	echo '		* -p|--path_of_leon </Path/of/leon>	: If you need to change the path of leon (default : "/Users/adminbioinfo/Documents/Leon/leon/leon")';
	echo '		* -l|--lossy	: If you want to launch LEON in lossy mode (default : false)';
	echo '		* -u|--unkeep	: If you dont want to keep initial gzip (default : false)';
	echo '';
	echo '	General arguments';
	echo '		* -h	: show this help message and exit';
	echo '		* -t	: test mode (dont execute command just print them)';
	echo '';
	exit
}

# --- Option processing --------------------------------------------
filename=""
directory=""
recovery=""
lossy=true
unkeep=true
testMode=false

# Parse command line
while [ "$1" != "" ]; do
	case $1 in
		-f | --file )			shift
								filename=$1
								;;
		-d | --directory )		shift
								directory=$1
								;;
		-r | --recovery )		shift
								recovery=$1
								;;
		-p | --path_of_leon )	shift
								PATH_LEON=$1
								;;
		-l | --lossy )			lossy=false
								;;
		-u | --unkeep )			unkeep=false
								;;
		-t | --test )			testMode=true
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
if [[ -z "$filename" ]] && [[ -z "$directory" ]] && [[ -z "$recovery" ]]
then
    usage
    exit
fi


### Second level : check if the files or directory exists
if [[ ! -e "$filename" ]] && [[ ! -z "$filename" ]]
then
	echo "${RED}File : '$filename' does not exist !${NC}";
    usage
    exit
fi

if [[ ! -e "$directory" ]] && [[ ! -z "$directory" ]]
then
	echo "${RED}Directory : '$directory' does not exist !${NC}";
    usage
    exit
fi

### Third level : check if "filename" is a file and "directory" is a directory
if [[ ! -f "$filename" ]] && [[ ! -z "$filename" ]]
then
	echo "${RED}File : '$filename' is not a regular file !${NC}";
    usage
    exit
fi

if [[ ! -d "$directory" ]] && [[ ! -z "$directory" ]]
then
	echo "${RED}Directory : '$directory' is not a directory !${NC}";
    usage
    exit
fi

### Bonus level : check if "filename" is with ".fastq.gz" extension
if [ ! ${filename: -9} == ".fastq.gz" ]
then
	echo "${RED}File : '$filename' is not a '.fastq.gz'${NC}";
    usage
    exit
fi

### Unicorn level : check 'recovery'
if [[ ! -d "$recovery" ]] && [[ ! -z "$recovery" ]]
then
	if [[ ! -f "$recovery" ]]
	then
		echo "${RED}'$recovery' is not a file or a repertory !${NC}"
		usage
		exit
	fi
fi
if [[ -f "$recovery" ]]
then
	if [ ! ${recovery: -5} == ".leon" ]
	then
		echo "${RED}File : '$recovery' is not a '.leon'${NC}";
    	usage
    	exit
    fi
    DIR=$(dirname "${recovery}");
    BASE_NAME=$(basename "$recovery");
	BASE_NAME="${BASE_NAME%.*}";
	if [[ ! -f "$DIR/$BASE_NAME.qual" ]]
	then
		echo "${RED}File : '$DIR/$BASE_NAME.qual' does not exist or is not a regular file.${NC}";
    	usage
    	exit
	fi
fi
# -- Functions ---------------------------------------------------------

convert_file_test () {
	echo "Conversion of file : '$1'";

	### UNZIP
	CMD_GUNZIP="gunzip $1"
	if $2;
	then
		CMD_GUNZIP="$CMD_GUNZIP -k"
	fi
	echo "$CMD_GUNZIP"

	### LEON
	fileBase=$(basename "$1");
	fileBase="${fileBase%.*}";
	CMD_LEON="$PATH_LEON -c -file $fileBase";
	if $3;
	then
		CMD_LEON="$CMD_LEON -lossless"
	fi
	echo "$CMD_LEON"

	### DELETE FASTQ
	echo "rm $fileBase"
}
convert_file () {
	echo "Conversion of file : '$1'";

	### UNZIP
	CMD_GUNZIP="gunzip $1"
	if $2;
	then
		CMD_GUNZIP="$CMD_GUNZIP -k"
	fi
	$CMD_GUNZIP

	### LEON
	fileBase=$(basename "$1");
	fileBase="${fileBase%.*}";
	CMD_LEON="$PATH_LEON -c -file $fileBase";
	if $3;
	then
		CMD_LEON="$CMD_LEON -lossless";
	fi
	$CMD_LEON

	### DELETE FASTQ
	rm $fileBase
}

recovery_fastq_test () {
	BASE_NAME=$(basename "$1");
	BASE_NAME="${BASE_NAME%.*}";
	echo "$BASE_NAME"

	echo "Recovery fastq from : $1";
	CMD_RECOVERY="$PATH_LEON -file $1 -d";
	echo "$CMD_RECOVERY";

	echo "rm $BASE_NAME.qual $BASE_NAME.leon";
	echo "mv $BASE_NAME.d $BASE_NAME";
	echo "gzip $BASE_NAME";
}
recovery_fastq () {
	BASE_NAME=$(basename "$1");
	BASE_NAME="${BASE_NAME%.*}";

	echo "Recovery fastq from : $1";
	CMD_RECOVERY="$PATH_LEON -file $1 -d";
	$CMD_RECOVERY

	rm $BASE_NAME.qual $BASE_NAME.leon
	mv $BASE_NAME.d $BASE_NAME
	gzip $BASE_NAME
}


# -- Body ---------------------------------------------------------

if [[ ! -z "$directory" ]]
then
	cd $directory

	EXT=fastq.gz

	for i in *; do
		if [ "${i}" != "${i%.${EXT}}" ];then
			echo "########################################################"
				if $testMode; then
					convert_file_test $i $unkeep $lossy
				else
					convert_file $i $unkeep $lossy
				fi
			echo ""
		fi
	done

	cd $PWD_PROJECT
fi

if [[ ! -z "$filename" ]]
then
	DIR=$(dirname "${filename}")

	cd $DIR

	if $testMode; then
		echo "lossy $lossy	; unkeep $unkeep"
		convert_file_test $filename $unkeep $lossy
	else
		convert_file $filename $unkeep $lossy
	fi

	cd $PWD_PROJECT
fi



########################################################
##### RECOVERY MODE

if [[ ! -z "$recovery" ]]
then
	if [[ -f "$recovery" ]]
	then
		DIR=$(dirname "${recovery}")

		cd $DIR

		if $testMode; then
			recovery_fastq_test $i
		else
			recovery_fastq $i
		fi

		cd $PWD_PROJECT
	fi
	if [[ -d "$recovery" ]]
	then
		cd $recovery
		EXT=leon

		for i in *; do
			if [ "${i}" != "${i%.${EXT}}" ];then
				echo "########################################################"
				BASE_NAME=$(basename "$i");
				BASE_NAME="${BASE_NAME%.*}";
				if [[ ! -f "$BASE_NAME.qual" ]]
				then
					echo "${WARNING}WARNING : Found '$BASE_NAME.leon' but not '$BASE_NAME.qual'. File ignored !${NC}";
					#usage
					continue
				fi

				if $testMode; then
					recovery_fastq_test $i
				else
					recovery_fastq $i
				fi

			fi
			echo ""
		done

		cd $PWD_PROJECT
	fi
fi

# -----------------------------------------------------------------
