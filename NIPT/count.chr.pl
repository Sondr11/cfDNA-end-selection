#!/usr/bin/perl
#
# Author: Kun Sun @ SZBL (sunkun@szbl.ac.cn)
#

use strict;
use warnings;

if( $#ARGV < 0 ) {
	print STDERR "\nUsage: $0 <in.bed[.gz|.bz2]> <sid> [min.qual=30]\n\n";
	exit 2;
}

my $sid = $ARGV[1];
my $minQual = $ARGV[2] || 30;

if( $ARGV[0] =~ /\.bz2/ ) {
	open IN, "bzip2 -cd $ARGV[0] |" or die( "$!" );
} elsif ( $ARGV[0] =~ /\.gz$/ ) {
	open IN, "zcat $ARGV[0] |" or die( "$!" );
} else {
	open IN, "$ARGV[0]" or die( "$!" );
}

my $lowrisk = 0;
my $chr21 = 0;

while( <IN> ) {
	chomp;
	my @l = split /\t/;	## chr start end rid mapQ extra
	next if $l[4] < $minQual;
	next unless $l[0] =~ /^chr\d+$/;
	++ $lowrisk unless $l[0] eq 'chr13' || $l[0] eq 'chr18' || $l[0] eq 'chr21';
	++ $chr21 if $l[0] eq 'chr21';
}
close IN;

print join( "\t", $sid, $lowrisk, $chr21, $chr21/($lowrisk+$chr21)*100 ), "\n";

