# Recompressed fastq on LEON

## Why ?

Generally biological data issue from NGS are compressed with gzip.
With the emergence of NGS new problems appear as the stockage of data.
[LEON](https://github.com/GATB/leon) is a new algorithm developed for the compression of fastQ.
Indeed, LEON show greats performances compare to gzip (see : [here](https://github.com/Char-Al/bench_leon)).

## What ?

This script was developed to recompressed fastq, already compressed with gzip, with LEON.
I dont recommend to use this to do both in the same time (even if it could).

## Usage

This script convert fastq.gz to fastq.leon and reverse.

Usage : gzip2leon.sh

* Mandatory arguments :
	* `-f|--file <file.fastq.gz>`	: convert the file.fastq.gz to file.fastq.leon (can be used with -d option)
	* `-d|--directory <directory>`	: convert all fastq.gz into the directory in fastq.leon (can be used with -f option)
	* `-r|--recovery	<file.leon or directory>` : If you want recover fastq from file.leon (can be used with others option but it is not recommended)
* Optional arguments :
	* `-p|--path_of_leon </Path/of/leon>`	: If you need to change the path of leon (default : "/Users/adminbioinfo/Documents/Leon/leon/leon")
	* `-l|--lossy`	: If you want to launch LEON in lossy mode (default : false)
	* `-u|--unkeep`	: If you dont want to keep initial gzip (default : false)
* General arguments
	* `-h`	: show this help message and exit
	* `-t`	: test mode (dont execute command just print them)

---

## References

* Benoit, G. et al. [Reference-free compression of high throughput sequencing data with a probabilistic de Bruijn graph](http://www.biomedcentral.com/1471-2105/16/288) BMC bioinformatics 16, 288. issn: 1471-2105 (2015).
