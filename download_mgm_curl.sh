#Script by Maria Beatriz Walter Costa

#This script downloads MG-RAST files, from the IDs of array @mgm_list
#The IDs of this script come from the 30 MG-RAST files of the table made by Suzana Varjao - check Bia's Lab Book 27/07/18

#Usage: $bash SCRIPT
#To adapt the script for your needs, remove the old IDs of the array, and insert your own

mgm_list=(mgm4536100.3
mgm4536472.3
mgm4536473.3
mgm4536074.3
mgm4529965.3
mgm4529964.3
mgm4536476.3
mgm4569549.3
mgm4569550.3
mgm4569551.3
mgm4569552.3
mgm4453297.3
mgm4451759.3
mgm4451761.3
mgm4739174.3
mgm4739175.3
mgm4739176.3
mgm4739177.3
mgm4739178.3
mgm4739179.3
mgm4739180.3
mgm4739181.3
mgm4739182.3
mgm4739183.3
mgm4739184.3
mgm4739185.3
mgm4739186.3
mgm4739187.3
mgm4739188.3
mgm4739189.3)

for i in "${mgm_list[@]}"; do
	curl http://api.metagenomics.anl.gov/download/"${i}"?file=299.1 > ${i}.299.1.gz
	echo "$i has been processed"
done
