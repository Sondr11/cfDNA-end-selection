#!/usr/bin/perl
#
# Author : Ahfyth (sunkun@szbl.ac.cn)
# Version: Dec 2019
#

use strict;
use warnings;

if( $#ARGV < 2 ) {
	print STDERR "\nUsage: $0 <input.pe.[bs]am> <output.bed[.gz]> [min.qual=0] [autosomal.only=0]\n\n",
				 "This program is designed to translate the Paired-End DNA-Seq SAM file to bed file.\n",
				 "Note that the SAM/BAM file donot need to be pos-sorted but MUST contain the mate information.\n\n";
	exit 2;
}

my $minqual  = $ARGV[2] || 0;
my $autoONLY = $ARGV[3] || 0;

if( $ARGV[0] =~ /bam$/ ) {
	open IN, "samtools view -@ 4 $ARGV[0] |" or die("$!");
} else {
	open IN, "$ARGV[0]" or die( "$!" );
}

my $outbed = $ARGV[1];
if( $outbed =~ /\.gz$/ ) {
	open OUT, "| gzip >$outbed" or die( "$!" );
} else {
	open OUT, ">$outbed" or die( "$!" );
}

my ($chr, $pos, $strand);
my @l;
my $all = 0;
while( <IN> ) {
	@l = split /\t/;
	if( $l[6] ne "=" ) {
		print STDERR "ERROR: Read $l[0] does not contain the mate information!\n";
		next;
	}
	my $mate = $l[8];	## QNAME FLAG RNAME POS MAPQ CIGAR RNEXT PNEXT TLEN SEQ QUAL EXTRA-MARKS
	next if $mate<=0 || $l[4]<$minqual;
	next if $l[2]=~/^chrM/;	## always discard chrM; BUT keep HBV, Lambda, EBV/E.coli
	next if $autoONLY && $l[2]!~/^chr\d+$/;

	## For BWA result
#	next unless $l[1] & 0x02;       ## the fragment is propoerly mapped to the reference genome
#	next if     $l[1] & 0x100;      ## discard secondary alignment
#	next unless $l[4] >= $minqual;  ## high quality mapping
#	next unless $l[6] eq '=';		## properly mapped pair
#	my $mate = $l[8];
#	next if $mate <= 0;

	$chr = $l[2];
	$pos = $l[3]-1;
	$strand = ($l[1] & 0x40) ? '+' : '-';
	## for the left-most read:
	## if it is the first template, then it is read1 and the fragment should be on watson chain
	## otherwise it is read2 and the fragment should be on crick chain
	## for sorted BAM files, you cannot ensure the order of READ1 and READ2,
	## therefore need to check this flag while NOT 0x10 for strand
	print OUT join("\t", $chr, $pos, $pos+$mate, $l[0], $l[4], $strand), "\n";
}
close IN;

close OUT;

