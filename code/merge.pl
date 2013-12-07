###############################################
#
# Infer annotation for CCLE and Sanger using
# a merge file (provided by Rodrigo D) as key
# and the maf-like formated knowledge base
#
# Author: Olga Nikolova
# E-mail: olga.nikolova@gmail.com
###############################################
#!/usr/bin/perl

use strict;
#use warnings;
use Data::Dumper;

my $finm = shift(); # merged file
my $findb = shift(); # knowledge base

my $base = (split('\.', $finm))[0];
my $fout = "/home/onikolov/projects/gold_standard/results/Merged_CCLE_Sanger_Kdb.maf.tsv";

open INFM, "<$finm" or die "Cannot open input file $finm...\n";
open INFDB, "<$findb" or die "Cannot open input file $findb...\n";
open OUTF, ">>$fout" or die "Cannot open output file $fout...\n";

# print header
print OUTF "Cancer type\tGene\tVariant\tDescription\tEffect\tPathway\tAssociation\tTherapeutic context\tStatus\tEvidence\tPMID\tAnnotation\n";

my %dbhash = ();

while(my $line=<INFDB>){
	 chomp($line);
	# print original file to output with last column code = 0
	print OUTF $line."\t0\n";

	my $key = (split("\t", $line))[7];
	$key =~ s/^\s+|\s+$//g;
	if(exists($dbhash{$key})){
		push($dbhash{$key}, $line);
	}
	else{
		$dbhash{$key}[0] = $line;
	}
}

my $line = <INFM>; # skip header
while($line = <INFM>){
	chomp($line);
	$line =~ s/\"//g;
	my @cells =  split("\t", $line);
	my $queries = $cells[2];# may be multiple queries
	my $drug = $cells[0];
	#die Dumper(\@cells);
	if($queries ne ""){
		my @query = split(",", $queries);
		#print Dumper(\@q);
		foreach my $q (@query){
		#for(my $i=0; $i< scalar @q; $i++){
			$q =~ s/^\s+|\s+$//g;
			if(exists($dbhash{$q})){
				foreach( @{$dbhash{$q}}){
					#die Dumper(\$_);
					my @tmp = split("\t", $_);
					$tmp[7] = $drug;
					print OUTF join("\t", @tmp)."\t1\n";  
				}
			}
		}
	}
}

close INFDB;
close INFM;
close OUTF;
