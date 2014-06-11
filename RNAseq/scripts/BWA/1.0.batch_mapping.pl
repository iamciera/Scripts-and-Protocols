#!/usr/bin/perl -w
use strict;
use File::Basename;

my $dir = $ARGV[0];

my @files = <$ARGV[0]*.fq>;

foreach my $file (@files){
	print "1.1.BWA_RNAseq_mapping.pl $file\n";
	`perl ./1.1.BWA_RNAseq_mapping.pl $file `;
}	
exit;
