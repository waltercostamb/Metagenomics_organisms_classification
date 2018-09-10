#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;
use Getopt::Long qw(GetOptions);
use File::Temp qw/ tempfile tempdir /;

my $accessionFile;
my $regExpAccessionFile;
my $fileQuery;
my $regQuery;
my $job_ID;
my $number_sequence;
my $output_folder;
my $help;

GetOptions(
	'accessionFile=s' => \$accessionFile,
	'regExpAccessionFile=s' => \$regExpAccessionFile,
	'fileQuery=s' => \$fileQuery,
	'regQuery=s' => \$regQuery,
	'number_sequence=s' => \$number_sequence, 
	'outputFolder=s' => \$output_folder,
	'jobID=s' => \$job_ID,
	'help' => \$help,
) or die "Usage: $0 --help\n";

if ($help){
	print "\nMaria Beatriz Walter Costa (bia.walter\@gmail.com)\n\n";
	print "This script gets as input FASTA files (Query) and an accession file (AccessionFile) and outputs a FASTA file formatted to the Kraken2 format (http://ccb.jhu.edu/software/kraken/MANUAL.html#custom-databases)\n";
	print "\nAny bugs or problems, please contact the developer.\n\n";
	print "The mandatory arguments are:\n\n";
	print "--accessionFile\t\tFolder path of accession file(s) (only the folder path, e. g. ``/prj/ebiodiv/maria.costa/Kraken2_DB/taxonomy''\n";
	print "--regExpAccessionFile\tRegular expression for the Accession file(s) (file ending, e. g. ``accession2taxid'')\n";
	print "--fileQuery\t\tFolder path of the FASTA genomes (query, e. g. ``/prj/ebiodiv/maria.costa/Kraken2_DB_700_genomes_custom_data/genomes_BioProject_NCBI_PRJNA273161/ncbi-genomes-2018-06-20'')\n";
	print "--regQuery\t\tRegular expression for the FASTA files (e. g. ``fna'', ``fasta'')\n";
	print "--outputFolder\t\tThe output folder\n";
	print "--jobID\t\t\tThe jobID (unmatched sequences will be stored in a file named after the jobID)\n"; 
	print "--number_sequence\tN (a number to start a counting of the processed genomes, e. g. 0)\n\n"; 
	print "ATTENTION: do not include the final slash to any of the given paths (``/'')\n";
	print "IMPORTANT: you can only run this script in a machine with at least X RAM memory, with X being the size of the Accession files.\n\n";
	print "Usage: $0 --accessionFile FILE_DB --regExpAccessionFile REG_EXP_DB --fileQuery FILE_QUERY --regQuery REG_QUERY --outputFolder OUTPUT_FOLDER --jobID JOB_ID --number_sequence N\n";
	die "\n";
}


#################### Main Program ####################### 

my $output_file_unmatched_sequences = "report_unmatched_sequences_$job_ID.txt";



my $marker;
my $fh;
my $ls_lh;

my $accessionFile_complete = $accessionFile."/"."*".$regExpAccessionFile;

#Command bash below gets the exact DB files
$ls_lh = `ls -lh $accessionFile_complete | sed 's/  */\t/g' | cut -f9`;
my @exact_files_DB = split (/\n/, $ls_lh);

#print "\n\nTAG\t$accessionFile\t$job_ID\t$fileQuery\t$accessionFile_complete\t$ls_lh\tTAG\n\n";

#print "@exact_files_DB\n";

#We will keep the whole database in memory, and keep the NCBI_ID as key and the taxID as hash for later on recuperation
my $i;
#This hash will keep all the database in memory, for fast recovery
my %ncbiID2taxID;

#Work on every DB file
for($i = 0; $i < @exact_files_DB; $i++) {
	
	#Open accessionFile
	open ("accessionFile_exact", $exact_files_DB[$i]) || die "It was not possible to open file $exact_files_DB[$i]\n";

	while (<accessionFile_exact>) {
		#print "$_\n";
		
		#Keep the data in hashes
		#These files have a 4-column format with the accession in the first column, the accession version in the second and taxID in the third
		chomp;
		my @pre_IDs = split (/\s+/);

		my $accession_version = $pre_IDs[1];
		my $taxID = $pre_IDs[2];

		#Building the data structure
		$ncbiID2taxID{$accession_version} = $taxID;
	}	

	close accessionFile_exact;
}


my $fileQuery_complete = $fileQuery."/"."*".$regQuery;

#Command bash below gets the exact DB files
$ls_lh = `ls -lh $fileQuery_complete | sed 's/  */\t/g' | cut -f9`;
my @exact_files_Query = split (/\n/, $ls_lh);
my $fh_out_file;
my $out_file;
my @pre_output_file;
my $output_file_name;
my $full_path_output_file;

#print Dumper %ncbiID2taxID;

#Process fileQuery, extract the header of the FASTA file and the corresponding sequence, to get the taxID from the accessionFile using the data structure of hash %ncbiID2taxID

for($i = 0; $i < @exact_files_Query; $i++) {

	#Open fileQuery
	open ("fileQuery", $exact_files_Query[$i]) || die "It was not possible to open file $exact_files_Query[$i]\n";

	#Old code - naming the output file
	#@pre_output_file = split(/\//, $exact_files_Query[$i]);		
	#$output_file_name = $pre_output_file[1];	

	#New code - re-naming the output file
	$output_file_name = $job_ID;
	$full_path_output_file = $output_folder."/".$output_file_name.".formatted";

	#print "$full_path_output_file\n";

	#$out_file = $;

	while (<fileQuery>) {
		chomp;
		#print "$_\n";
		
		#If header, extract NCBI ID (first field after '>' sign)
		if (/^>/){
			$marker = 0;
			$number_sequence++;
			my @line = split (/\s+/);
			my $ncbi_id = $line[0];

			$ncbi_id =~ s/>//g;

			#Keep the original header, for later on printing, excluding the '>' symbol 
			my $original_header = $_;
			$original_header =~ s/>//g;

			#After we extract the ncbi ID, we we get the correspondent taxID from the hash data structure

	#		print "$ncbi_id\n";
	#		print "$accessionFile\n";

			#If it exists a taxID, get it
			if ($ncbiID2taxID{$ncbi_id}) {
				#Create string taxID for later on print-out
				my $taxID;
				$taxID = $ncbiID2taxID{$ncbi_id};

				#Open the output file of this instance
				open($fh_out_file, '>>', $full_path_output_file) or die "It was not possible to open file '$full_path_output_file' $!";

				#Print formatted FASTA line
				print $fh_out_file ">sequence$number_sequence|kraken:taxid|$taxID\t$original_header\n";
			} else {
				#Else, the ncbi ID is not contained in the DB file, and we report it in the report file
				open($fh, '>>', $output_file_unmatched_sequences) or die "It was not possible to open file '$output_file_unmatched_sequences' $!";

#				print "NCBI ID $ncbi_id was not found in input DB\n";
				print $fh "NCBI ID $ncbi_id was not found in input DB\n";
				#Change marker to 1, so that the corresponding sequence of this ID is not printed
				$marker = 1;
			}

		} else {

			#Only print the sequence if the marker is zero
			if ($marker == 0){
				#If the line is sequence, print it normally
				print $fh_out_file "$_\n";
			}
		}

	}
	close fileQuery;
}

if ($fh) {
	close $fh;
}


