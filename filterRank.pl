#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;
use Getopt::Long qw(GetOptions);
use File::Temp qw/ tempfile tempdir /;

my $input;
my $group;
my $help;

GetOptions(
	'input=s' 	=> \$input,
	'rank=s'	=> \$group,
	'help' 		=> \$help,
) or die "Usage: $0 --help\n";

if ($help){
	print "\nAuthor: Maria Beatriz Walter Costa (bia.walter\@gmail.com)\n";
	print "\nThis script gets as input a tsv file from the biom program and outputs an abundance matrix for the rank chosen by the user.\n"; 
	print "\nMandatory arguments:\n\n"; 
	print "--input FILE\n"; 
       	print "--rank TAXONOMIC_RANK (the selected rank that will be output in the matrix - e. g. d, p, c, g\n\n";
	print "Options for TAXONOMIC_RANK:\n";
	print "k -> Kingdom\n";
	print "p -> Phylum\n";
	print "c -> Class\n";
	print "o -> Order\n";
	print "f -> Family\n";
       	print "g -> Genus\n";
	print "s -> Species\n";
	print "\n"; 
	print "Usage: $0 --input FILE --rank TAXONOMIC_RANK\n";
	die "\n";
}


#################### Main Program ####################### 

#Open file of Kraken to process it
open ("input_file", $input) || die "It was not possible to open file $input\n";

my $marker = 0;
my $marker2 = 0;

#Go through the list of all files and process each one of them
while (<input_file>) {

	chomp;
	#print "$_\n";

	$marker2 = 0;

	if ($marker == 1) {
			
		#Print only the taxonomic group (last element of the line)
		my @rows = split (/\t/);
		my $pre_group = $rows[-1];

		my @pre_filtered_group = split (/; /, $pre_group);
		my $chosen_group;

		#Look for the group specified by the user
		foreach my $probe_group (@pre_filtered_group) {
			if ($probe_group =~ /^$group/) {

				my @tmp = split (/__/, $probe_group);

				if (defined $tmp[1]) {
					my $is_element_empty = $tmp[1];

					unless ($is_element_empty eq '') {
						$marker2 = 1;
						$chosen_group = $is_element_empty;
					}
	
					if ($marker2 == 1) {
						print "$chosen_group";
					}
				}
			}
		}

		my $i;
		#Print line 
		if ($marker == 1 && $marker2 == 1) {
			for ($i = 1; $i < @rows - 1; $i++) {
				print "\t$rows[$i]";
			}
			print "\n";
		}
	}

	#Find header
	if (/OTU ID/) {
		my @rows = split (/\t/);

		print "Taxonomic_group";

		my $i;
		#Print header 
		for ($i = 1; $i < @rows - 1; $i++) {
				my @pre_name_files = split (/_/, $rows[$i]);
				my $name_file = $pre_name_files[0];
				print "\t$name_file";
		}

		print "\n";
		$marker = 1;
	}
}

close input_file;	

