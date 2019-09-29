#Script by Maria Beatriz Walter Costa

#This script select specific groups in --report file from the Kraken2 tool

#Usage: $bash SCRIPT
#To adapt the script for your needs, remove the old IDs of the array, and insert your own

######################
#   Change the IDs   #   
######################

list=(mgm4536100.3
mgm4536472.3
mgm4536473.3)

for i in "${list[@]}"; do
	perl selectGroups.pl --input $i --file_groups groups.txt > ${i}.selected
	echo "$i has been processed, and the groups have been selected"
done

