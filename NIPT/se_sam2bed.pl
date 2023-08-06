#!/usr/bin/perl

#
# Author : Ahfyth
#

use strict;
use warnings;

if( $#ARGV < 0 ) {
	print STDERR "\nUsage: $0 <input.SE.[bs]am> [output.bed=stdout] [min.Qual=0] [frag.size=200]\n";
	print STDERR "\nThis program is designed to translate the Single-End DNA-Seq SAM file to bed file.\n\n";
	exit 1;
}

my $minQual = $ARGV[2] || 0;
my $fs = $ARGV[3] || 200;

my $o = $ARGV[1] || '/dev/stdout';
open OUT, ">$o" or die( "$!" );

my %chrcount;

if( $ARGV[0] =~ /\.bam$/ ) {
	open IN, "samtools view $ARGV[0] |" or die( "$!" );
} else {
	open IN, "$ARGV[0]" or die( "$!" );
}
while( <IN> ) {
	my @l = split /\t/;	##SRR1045842.157 0 chr3 164603272 255 36M * 0 0 CCTCATTTGT
	next if $l[4] < $minQual;
	next if $l[2] =~ /^chrM/; ## always discard chrM; but keeps HBV, Lambda, and EBV
	my $pos = $l[3];
	my $chr = $l[2];
	++ $chrcount{$chr};

	if( $l[1] & 0x10 ) {	## reverse strand
		## SAM format records the leftmost position so I need to calculate the rightmost
		## position of this read then deduce the left position of the fragment
		my $readsize = get_read_size_from_CIGAR( $l[5] );
		if( $readsize == 0 ) {
#			print STDERR "Error: Unknown CIGAR '$l[5]' for read '$l[0]', Skip!\n";
			next;
		}
		my $rightmost= $pos + $readsize - 1;
		my $leftmost = $rightmost - $fs;
		print OUT "$chr\t$leftmost\t$rightmost\t$l[0]\t$l[4]\t-\n";
	} else {	## forward strand
		print OUT "$chr\t", $pos-1, "\t", $pos-1+$fs, "\t$l[0]\t$l[4]\t+\n";
	}
}
close IN;

close OUT;

## chr count
foreach my $chr ( sort keys %chrcount ) {
	print STDERR join("\t", $chr, $chrcount{$chr}), "\n";
}


## CIGARs could contain I for insertion and D for deletions
sub get_read_size_from_CIGAR {
	my $CIGAR = shift;
    my $cs = length( $CIGAR );
	my ( $i, $j );
	my $size = 0;
    for( $i=0, $j=0; $i!=$cs; ++$i) {
		my $char = substr( $CIGAR, $i, 1 );
        if( $char =~ /\d/ ) {   # digital
			$j *= 10;
			$j += $char;
        } else { #MUST be M, I, or D
			if( $char eq 'M' ) { # match or mismatch, keep
				$size += $j;
			} elsif ( $char eq 'I' ) { # insertion, ignore
				# do nothing
			} elsif ( $char eq 'D' ) { # deletion, add place holders
				$size += $j;
			} else {	# unsupported CIGAR element
				return 0;
			}
			$j = 0;
		}
    }

	return $size;
}

