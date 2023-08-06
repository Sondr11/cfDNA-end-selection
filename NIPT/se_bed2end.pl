#!/usr/bin/perl
#
# Author: Kun Sun @ SZBL (sunkun@szbl.ac.cn)
# Date  :

use strict;
use warnings;

if( $#ARGV < 0 ) {
	print STDERR "\nUsage: $0 <in.bed> [mapQ=0] \n\n";
	exit 2;
}

my $mapQ = (defined $ARGV[1]) ? $ARGV[1] : 0;

my ($left, $right) = ( 0, 0 );

if( $ARGV[0]=~/\.gz$/ ) {
	open IN, "zcat $ARGV[0] |" or die( "$!" );
} elsif($ARGV[0] =~ /\.bz2/ ){
	open IN, "bzip2 -cd $ARGV[0] |" or die( "$!" );
} else {
	open IN, "$ARGV[0]" or die( "$!" );
}

while( <IN> ) {
	chomp;
	my @l = split /\t/;	##chr1	10046	10143	31	+

	next unless $l[4]>=$mapQ;	## autosome only and mapQ filter;
	if( $l[5] eq "+" ) {
		print join("\t", $l[0], $l[1], $l[1]+1, $l[3], $l[4],"+"), "\n";
	} else {
		print join("\t", $l[0], $l[2]-1, $l[2], $l[3],$l[4], "-"), "\n";
	}
}
close IN;

