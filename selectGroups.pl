#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;
use Getopt::Long qw(GetOptions);
use File::Temp qw/ tempfile tempdir /;

my $input_file;
my $file_with_groups;
my $help;

GetOptions(
	'input=s' 		=> \$input_file,
	'file_groups=s'		=> \$file_with_groups,
	'help' 			=> \$help,
) or die "Help: $0 --help\n";

if ($help){
	print "\nAuthor: Maria Beatriz Walter Costa (bia.walter\@gmail.com)\n";
	print "\nThis script filters files that were produced by Kraken2, when one uses Kraken2 with the --report argument. It will print out all lines that match to the groups specified in FILE_WITH_GROUPS_TO_FILTER and all lower ranks related to the specified groups.\n";
	print "FILE_WITH_GROUPS_TO_FILTER has to have a specific format: one group perl line, with two columns per line, the first being the group and the second the rank in one letter format (e. g. D).\n";
	print "E. g. if \$GROUP_TO_FILTER=Bacteria, all lines that match this pattern will be printed out, along with all subsequent lines, until another RANK=D is reached (rank would be equal to the one determined by the pattern, in the case of Bacteria, RANK=D)\n\n";
	print "Mandatory arguments:\n\n";
	print "--input KRAKEN_INPUT\n";
	print "--file_groups FILE_WITH_GROUPS_TO_FILTER\n\n";
	print "\nUsage: $0 --input KRAKEN_INPUT --file_groups FILE_WITH_GROUPS_TO_FILTER\n";
	print "ATTENTION: PERCENTAGES ARE EXACTLY AS THEY HAVEN BEEN REPORTED BY KRAKEN2\n";
	die "\n";
}

#################### Main Program ####################### 

#Open file of groups to filter in
open ("input_groups", $file_with_groups) || die "It was not possible to open file $file_with_groups\n";

my %groups_to_filter_in;

#Keep all groups into an array
while (<input_groups>) {
	chomp;

	my @rows = split (/\t/);
	my $group = $rows[0];
	my $rank = $rows[1];

	$groups_to_filter_in{$group} = $rank;
}

close input_groups;

#Open file of Kraken to process it
open ("input_file", $input_file) || die "It was not possible to open file $input_file\n";

#$rank variable will be defined, when the pattern is found in the input file
my $rank;
#Marker will be zero if the line is to be printed, one otherwise
my $marker_of_filter = 0;
my $line;
my @rows;

#According to the manual of the Kraken2: http://ccb.jhu.edu/software/kraken/MANUAL.html#sample-report-output-format The row 1 of the --report output is: 1. Percentage of fragments covered by the clade rooted at this taxon
#This corresponds to: $row_2_of_current_line/$sum_of_row3
#The calculation of the sum of any row can be calculated with the command below:
#$sum_row3 = `cut -f3 mgm4451759_kraken.matrix | awk '{s+=$1}END{print s}'`

#The percentages will need to be re-calculated, after the filtering
#For that the file will be read once, kept into an array and read twice for printing of the new percentages

#This array will contain all filtered lines, for afterwards processing
my @filtered_lines_of_input;
#This variable will contain the sum of the third row, after the file is filtered to excluded unwanted groups
my $sum_of_third_row;

#Go through all lines of the file
while(<input_file>) {

	chomp;
	#print "$_\n";
	
	$line = $_;	

	#Separate row fields
	#print "$line\n";
	@rows = split(/\t/, $line);
	#print Dumper @rows;

	#Keeping the current line's into a string
	my $current_line_rank = $rows[3];
	my $current_line_group = $rows[5];

	#Check for the pattern designed by the user (e. g. Eukaryota), if match, filter all subsequent lower ranks until another $rank is found in subsequent lines
	foreach my $group_to_filter (keys %groups_to_filter_in) {

		my $rank_to_filter = $groups_to_filter_in{$group_to_filter};

		#If both patterns of the input file match the correct rows of rank and group, then mark the line as desired
		if ($current_line_group =~ /^\s*$group_to_filter$/ && $current_line_rank =~ /^$rank_to_filter$/){

			#Define the rank variable with the fourth column of the line in which the pattern was found
			$rank = $rows[3];

			#Set marker to one, indicating all further lines are to be filtered
			$marker_of_filter = 1;

			#print "$line\n";

                        #$line will be kept in an array for later on processing
#                        push @filtered_lines_of_input, $line;

#                       my $current_third_row_count = $rows[2];
#                        $sum_of_third_row = 1;
			print "$line\n";

			#Go to nextline, to avoid printing the current line
        	        $line = <input_file>;
                	chomp ($line);
                	@rows = split(/\t/, $line);

		}
	}

	#Check if the marker is set to 1, if so, print the line
	if ($marker_of_filter == 1) {

		my $rank_of_comparison = $rows[3];

		#The rank of the current line is equal to the rank we were printing the lines		
		if ($rank_of_comparison eq $rank) {

			#Set marker to zero 
			$marker_of_filter = 0;

			#Check if the current line has a group that the user wants to print
			#Check for the pattern designed by the user (e. g. Eukaryota), if match, filter all subsequent lower ranks until another $rank is found in subsequent lines
			foreach my $group_to_filter (keys %groups_to_filter_in) {

				my $rank_to_filter = $groups_to_filter_in{$group_to_filter};

				#If both patterns of the input file match the correct rows of rank and group, then mark the line as desired
				if ($current_line_group =~ /^$group_to_filter$/ && $current_line_rank =~ /^$rank_to_filter$/){

					#Define the rank variable with the fourth column of the line in which the pattern was found
					$rank = $rows[3];

					#Set marker to one, indicating all further lines are to be filtered
					$marker_of_filter = 1;

					print "$line\n";

       			 		#$line will be kept in an array for later on processing
#		                        push @filtered_lines_of_input, $line;

#	       	 	                my $current_third_row_count = $rows[2];
#		                        $sum_of_third_row = 1;
				}
			}
		} else {
			
			#print "$rank_of_comparison was reached\t$line\n";
			print "$line\n";

			#$line will be kept in an array for later on processing
#			push @filtered_lines_of_input, $line;
		
#			my $current_third_row_count = $rows[2];	
#			$sum_of_third_row += $current_third_row_count;
		}
	}

}

#print "$sum_of_third_row\n";
#my $fn;

#Calculation of the percentages is incorrect
#Work on each line of the filtered file and re-calculate the percentages to print the filtered text
#foreach my $line (@filtered_lines_of_input) {
	
	#Split the rows by tabs
#	my @rows = split(/\t/, $line);
	#Get the current third row
#	my $current_second_row = $rows[1];

	#print Dumper @rows;

	#Split the rows by the percent symbol, to separate the percentages from the rest of the line, that will be maintained the same
#	my @rows_by_percent = split (/\%/, $line);
#	my $last_part_of_line = $rows_by_percent[1];

	#Re-calculate the percentages, with the updated values
#	my $pre_percentage_corrected = ($current_second_row/$sum_of_third_row)*100;

	
	#Get only two numbers after the coma, like the original file
#	my $percentage_corrected = sprintf("%.2f", $pre_percentage_corrected);

	#Print the corrected percentages and the last part of the line, as was in the original input file (since apart from the percentages, the rest of the line is maintained)
	
	#The blocks below are necessary to copy the format from Karken2
	#Print one space before line, if the percentage is bigger or equal to 10 but smaller than 100
#	if ($percentage_corrected < 100 && $percentage_corrected >= 10) {
#		print " ";
	
	#Print two spaces before line, if the percentage is smaller than 10
#	} elsif ($percentage_corrected < 10) {
#		print "  ";

	#Print zero spaces before line, if the percentage is equal to 100
#	} elsif ($percentage_corrected >= 100 ) {
#		print "";
#	}

#	print "$percentage_corrected\%$last_part_of_line\n";
#}

close input_file;	


