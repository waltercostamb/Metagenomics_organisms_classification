#!/usr/bin/bash

#Script doesnt work

filename="$1"

while read -r line
do
	name="$line"
	#echo "Name read from file - $name"
	rsync --copy-links --times --verbose --progress --append-verify rsync://$line .
done < "$filename"

#URLFILE=$1  
#NUM=8 

#while read url 
#  do 
	#axel --num-connections=$NUM $URL 

#	echo $url
#	rsync --copy-links --times --verbose --progress --append-verify rsync://$URL .

	#ftp-trace.ncbi.nih.gov: /sra/sra-instant/reads/ByRun/sra/SRR/SRR434/SRR4343434/SRR4343434.sra .
	#rsync --copy-links --times --verbose --progress --append-verify rsync://ftp-trace.ncbi.nih.gov:/sra/sra-instant/reads/ByRun/sra/SRR/SRR434/SRR4343434/SRR4343434.sra .
#done < $1  

#Old script below (did not work for large datasets)
#Ids obtained from Suzana's table - check Bia's Lab Book 27/07/18

#sra_single_list=(SRR4343434
#SRR4343431
#SRR3308675
#SRR3308881
#SRR3308740
#SRR3308741
#SRR3309137
#SRR3309152
#SRR3309241
#SRR3309324
#SRR3309327
#SRR3309325
#SRR3309326
#SRR3309375)

#module load sratoolkit/2.8.2

#for i in "${sra_single_list[@]}"; do
#	fastq-dump "${i}"
#	echo $i
#done
