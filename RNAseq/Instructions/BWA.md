#Using BWA for Mapping

##Resources

*Using guide made by Mike Covington located at [https://github.com/mfcovington/BIS180L-RNAseq](https://github.com/mfcovington/BIS180L-RNAseq)*

Documentation for tools used for mapping reads and visualizing alignments can be found online:

BWA: [http://bio-bwa.sourceforge.net/bwa.shtml](http://bio-bwa.sourceforge.net/bwa.shtml)

Samtools: [http://samtools.sourceforge.net/samtools.shtml](http://samtools.sourceforge.net/samtools.shtml)

###Required Files

- Download index file from [ftp://ftp.solgenomics.net/tomato_genome/annotation/ITAG2.4_release/ITAG2.4_cds.fasta](ftp://ftp.solgenomics.net/tomato_genome/annotation/ITAG2.4_release/ITAG2.4_cds.fasta)

- All files that have been sorted by barcode.
- `1.0.batch_mapping.pl`
- `1.1.BWA_RNAseq_mapping.pl`


##Mapping reads to an indexed reference

1. First we are building the index.  

        bwa index ITAG2.4_cds.fasta 

    There should now be five new versions of the file (.amb, .ann, .bwt, .pac, sa). 

2. Organize your files so that they are named how you would like them.  In my case, I am going to name each barcode.    For now I will just cancatfiles with the same library and rep all in one .fq file.  In order to name the libraries in order of their barcode, I wrote a script below:

    #!/usr/bin/env python
    #renameFiles.py
    #Ciera Martinez 
    #This script takes in a .csv file as a key on how to rename files in current directory.  

    import os
    import csv

    #open file
    with open('lane1Key.csv','rU') as csvfile:
            reader = csv.reader(csvfile, delimiter = ',')
            mydict = {rows[1]:rows[0] for rows in reader}

    # renaming
    for fileName in os.listdir( '.' ):
        newName = mydict.get(fileName) if mydict.get(fileName) else "empty" #can not read 'typeNone' from the keys that do not have matching files.
        list(newName)
        #print newName
        os.rename(fileName, newName)

4.  Now I need to concatenate all the reads from each specific library/rep into one file ie combine the lanes. I used this shell command to accomplish this.  I first make a key folder that contained empty names with all possible libraries.  

        mkdir libKey

        ls libFastaLane1 | while read FILE; do 
        touch "$FILE" 

    Then I moved all the .fq files in to libKey. `mv *.fq libKey`.  I repeated with each libFasta lane. `mv` all into libKey.  If there were repeat files they were overwritten.  Therefore I have a directory with all possible libraries so I could run the script below.

        #!/bin/bash
        #catFiles.sh
        #This program concatenates files of the same name in multiple directories into a new file in a new directory. This takes about 30 min. 

        ls libKey | while read FILE; do
          cat libFastaLane1/"$FILE" libFastaLane2/"$FILE" libFastaLane3/"$FILE" > libFastaAll/"$FILE"
        done


        #to append the A and B files to new files (with the same names) somewhere else.


3. Map reads in FASTQ file to FASTA reference.  Need `1.0.batch_mapping.pl` and `1.1.BWA_RNAseq_mapping.pl`.  Make sure you are specifying where you index is (from step 1) in 1.0.batch_mapping.pl script. Run the batch script whith the last argument being where your barcode files are.   

        perl 1.0.batch_mapping.pl location/of/fasta/files
    
    example

        perl 1.0.batch_mapping.pl mikeSplitter/

4. Now that I have all the files, I need to 1.)convert to .BAM files so I can view the reads on  genome viewer and 2.) have all the .SAM files in one directory to run `Sam2counts.R` (aashish R script to count genes). 

<hr/>

###1.) Convert to bam.  

Gave up.  Need to get this done.  For now I just made a .sh script that had all the commands (`toBam.sh`).

**Ideas to accomplish, but for some reason does not work.** Why? 
    
    ls . | while read FILE; do
      samtools view -Sb "$FILE" > "$FILE"
    done

###2.) Run sam2counts.R 






    



