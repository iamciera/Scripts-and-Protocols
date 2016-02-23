

#Illumina data preprocessing for in-line barcoded (not indexed) data 

##Packages

[http://comailab.genomecenter.ucdavis.edu/index.php/Barcoded_data_preparation_tools](http://comailab.genomecenter.ucdavis.edu/index.php/Barcoded_data_preparation_tools)

Information about the settings and usage can be found in the text file of the scripts themselves.  The settings used here are generally used in the Sinha Lab.

###fastQC 

Already installed on the Maloof instance.  Documention can be found at [http://www.bioinformatics.babraham.ac.uk/projects/fastqc/INSTALL.txt](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/INSTALL.txt).

###fastx

####Installing

You will also require [fastx_toolkit](http://hannonlab.cshl.edu/fastx_toolkit/download.html), from the [Hannon Lab](http://hannonlab.cshl.edu/). For the iPlant Atmosphere environment download the 64 bit linux version. Pre-compiled binaries available for: Linux (64 bit).  Followed directions on page and put the folder in my scripts folder. 

[pkg-config guide](http://people.freedesktop.org/~dbn/pkg-config-guide.html)
The primary use of pkg-config is to provide the necessary details for compiling and linking a program to a library.

Download pre-compiled binaries, put them in /usr/local/bin
	
	$ mkdir fastx_bin
	$ cd fastx_bin
	$ wget http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2
	$ tar -xjf fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2
	$ sudo cp ./bin/* /usr/local/bin
	
##Preprocessing

The files come in .gz format so first you need to unzip them in your working folder.  `gunzip` replaces the original zipped file with the unzipped to save space.

	$ gunzip *.gz #10 min

The files then need to be concatenated into a single file  .fq or .fastq.

	$ cat *.fq > MyLane.fq #10 min

At this point you have all of the reads before quality filtering.  To do comparisons on total vs. filtered reads, run fastQC on Mylane.fq now.  FastQC basically puts together information on your reads for you in a tidy html file with graphs and everything.  Later we will do the same after quality filtering to get an understanding of what sort of effects quality filtering had on our reads. 

	fastqc MyLane.fq  #~20 min

Trim sequences and reject based on low quality scores (quality score and length may be adjusted as per requirement).

	$ python trimFastqQuality.py 20 35 MyLane.fq QualFiltered.fq # Time takes around ~2 hours per lane

Now run FastQC on QualFiltered.fq and compare the total reads to the  unfiltered read file.

Remove sequences containing “N” nucleotides.

	$ python read_N_remover.py QualFiltered.fq  Nremoved.fq #15 minutes

Remove adapter contamination sequences

	$ python adapterEffectRemover.py 41 Nremoved.fq AdaptersRemoved.fq b #10 min

	$ python adapterEffectRemover.py 41 Nremoved.fq AdaptersRemoved.fq b #cieras specifics 

FastQC on AdaptersRemoved.fq file.

	fastqc AdaptersRemoved.fq #~20 min

##Barcode Splitting

###1. Fastx

Barcode splitting, use this command string. It will generate separate files for each barcode with a name formatted like this Prefix_BarCodeID.suffix   It requires a text Barcode file in addition to the script.  The BCfile.txt should be formatted as two columns separated by a tab, the first column being the barcode ID and the second being the barcode sequence. Ie. 
Barcode1	ATAGG
Barcode2	GCTAT

	$ cat AdaptersRemoved.fq | perl fastx_barcode_splitter.pl --bcfile BCfile.txt --bol --exact --prefix Split_ --suffix ".fq" # time = ~ > 5 hours

Make a subfolder “BCRemoved” to place all the newly generated barcode-trimmed files into it.

	$ mkdir BCRemoved

To count number of reads for each barcode-trimmed fq file: Use the following command line in BCRemoved directory (@HS is the matching pattern at the beginning of 1st line of each illlumina Hi-seq reads). ```-c``` is the count option in grep.  This will make a text file calle Barcode_Counts.txt. For some reason there may be problems when copying and pasting this, so type it out to be safe. 

	$ grep –c “@HS” ./*.fq > Barcode_Counts.txt

##Trim Barcodes

Remove the portion of the reads containing the barcode so that the reads can be mapped. This will apply the function to all .fq files in the working folder and place the output in ./BCRemoved

	$ for n in ./*.fq; do ~/lcm/scripts/bin/fastx_trimmer -f 5 -Q 33 -i $n -o ./BCRemoved/$n; done

## 2. Mike Covington 

### Mike's way

You first need to switch the  columns of your BCfile.txt, because mike's program needs them a different way. Ie.

ATAGG	Barcode1	
GCTAT	Barcode2	

Copy the BCfile so you don't auctually fuck it up.

	cp BCfile1.txt BCfiletest.txt

	awk '{ print $2 "\t" $1}' BCfiletest.txt > BCfile2.txt #switches the columns

Get the scripts

    git clone https://github.com/mfcovington/auto_barcode.git

Download Perl dependency

	cpanm --sudo Text/Table.pm

Run code 

    barcode_split_trim.pl [options] --barcode barcode.file IN.FASTQ

example:

    ~/lcm/scripts/auto_barcode/barcode_split_trim.pl --barcode ../BCfile2.txt --list ../AdaptersRemoved.fq





