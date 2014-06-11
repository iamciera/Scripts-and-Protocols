#!/usr/bin/perl -w 
use File::Basename;

my $basename = basename($ARGV[0],(".fq"));

my $db = "./ITAG2.3_cdna";

print "mkdir $basename\n";
system("mkdir $basename");

#[-t 4] number threads 
#[-k 1] maximum edit distance in the seed
#[-l 25] Take the first INT subsequence as seed. If INT is larger than the query sequence, seeding will be disabled. For long reads, this option is typically ranged from 25 to 35 for ‘-k 2’. [inf]
#[-n 0.04] Maximum edit distance if the value is INT, or the fraction of missing alignments given 2% uniform base error rate if FLOAT. In the latter case, the maximum edit distance is automatically chosen for different read lengths. [0.04]
#[-e 15] Maximum number of gap extensions, -1 for k-difference mode (disallowing long gaps) [-1]
#[-i 10] Disallow an indel within INT bp towards the ends [5]

print "bwa aln -t 4 -k 1 -l 25 -n 0.04 -e 15 -i 10 $db $ARGV[0] > $basename/$basename.sai\n";
system("bwa aln -t 4 -k 1 -l 25 -n 0.04 -e 15 -i 10 $db $ARGV[0] > $basename/$basename.sai");

print "bwa samse -n 0  $db $basename/$basename.sai $ARGV[0] > $basename/$basename.sam\n";
system("bwa samse -n 0 $db $basename/$basename.sai $ARGV[0] > $basename/$basename.sam");

#######################################################################################################################################
