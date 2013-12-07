###############################################
#
# Parse custom knowledge-base format into MAF-like format
# Single line per gene-variant & therapeutic context
#
# Author: Olga Nikolova
# E-mail: olga.nikolova@gmail.com
###############################################

#!/usr/bin/perl

use strict;
#use warnings;
use Data::Dumper;

my $fin = shift();
my $cancerType = (split('\.', $fin))[0];
my $fout = $cancerType.".maf.tsv";

open INF, "<$fin" or die "Cannot open input file $fin...\n";
open OUTF, ">>$fout" or die "Cannot open output file $fout...\n";

# write header to file
my $line="";
($line=<INF>) =~ s/\"//g;
my @tmp = split("\t", $line);
print OUTF "Cancer type\t".join("\t", @tmp[0..9])."\n";

# parse each line
while ($line=<INF>) {
    chomp($line);
    my @cells = split(/\t/, $line);
    
    my $n = scalar @cells;
    my $nsets = $n/5 - 1; # we will skip the first and the last 5 columns 
    # get base which will repeat for the remaining 5-ples of columns
    my $base = $cancerType."\t".join("\t", @cells[0..4]);
    $base =~ s/\"//g;
    if($cells[0] eq "PTEN"){print($base."\n");}
  
    if($base !~ /^\NA+$/){
      for(my $idx=1; $idx < $nsets; $idx++){
      	my $start = $idx*5;
      	my $end = $idx*5 + 4;
      	my $check = join("", @cells[$start..$end]);
    	$check =~ s/\"//g;
	chomp($check);
      	if($check ne "" && $check !~ /^\s*NA{1,5}\s*/){ 
		my @thercon = split(",", $cells[$start+1]);
		foreach(@thercon) {
			#print($cells[$start+1]."\n");
		        $_ =~ s/^\s+|\s+$//g;      
			my $add = join("\t", $cells[$start], $_, @cells[$start+2..$end]);
      			$add =~ s/\"//g;
      			print OUTF "$base\t$add\n";
		}
      	}
    }
  }
}
close INF;
close OUTF;
