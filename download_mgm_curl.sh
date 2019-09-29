#Script by Maria Beatriz Walter Costa

#This script downloads MG-RAST files, from the IDs of array @mgm_list

#Usage: $bash SCRIPT
#To adapt the script for your needs, remove the old IDs of the array, and insert your own

mgm_list=(mgm4536100.3
mgm4536472.3
mgm4536473.3
)

for i in "${mgm_list[@]}"; do
	curl http://api.metagenomics.anl.gov/download/"${i}"?file=299.1 > ${i}.299.1
	echo "$i has been processed"
done
