#!/usr/bin/perl
#
# Author: Kun Sun @ SZBL (sunkun@szbl.ac.cn)
#

use strict;
use warnings;

if( $#ARGV < 1 ) {
	print STDERR "\nUsage: $0 <bed.list> <chr.cnt>\n\n";
	exit 2;
}

my $min_control = 4;

my %category;
my $sum=0;
open IN, "$ARGV[0]" or die( "$!" );
while( <IN> ) {
	chomp;
	my @l = split /\t/;	##Sid,bed path,category
	if( $l[2] eq "control" || $l[2] eq "CONTROL" ){
		$category{$l[0]} = 0;
		$sum ++;
	} elsif ( $l[2] eq "testing" || $l[2] eq "TESTING" ) {
		$category{$l[0]} = 1;
	} else {
		print STDERR "WARNING: unknown category ($l[2]) for $l[0]! This sample will be ignored.\n";
	}
}
close IN;

if( $sum < $min_control ) {
	die("ERROR: Too few controls! At least $min_control are required!\n");
}

my @control;
my @testing;
my @Sid;
open IN, "$ARGV[1]" or die( "$!" );
while( <IN> ) {
        chomp;
	my @l = split /\t/;
	if( $category{$l[0]} == 0 ) {
		push @control, $l[3];
	} elsif($category{$l[0]} == 1 ) {
		push @Sid, $l[0];
		push @testing, $l[3];
	} else {
		## ignore this sample
	}
}
close IN;

my $mean  = mean(\@control);
my $stdev = stdev($mean, \@control);
print "Sid\tZ-score\n";

#print "$average\t$std_dev\n";
for my $j ( 0 .. $#Sid) {
	my $Zscore = ($testing[$j]-$mean)/$stdev;
	print "$Sid[$j]\t$Zscore\n";
}

sub mean {
	my $data = shift;
	die "Empty array" unless @$data;
	
	my $sum = 0;
	foreach ( @$data ) {
		$sum += $_;
	}
	
	return $sum / @$data;
}

sub stdev{
	my $m = shift;
	my $data = shift;

	die "Empty array" unless @$data;
	return 0 if @$data == 1;

	my $sqtotal = 0;
	foreach ( @$data ) {
		$sqtotal += ($m-$_) ** 2;
	}
	return sqrt($sqtotal / $#$data);
}

