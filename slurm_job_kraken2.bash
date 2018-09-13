#!/bin/bash

#Author: Maria Beatriz Walter Costa
#This script submit jobs to the slurm queue for profiling of metagenomes using the Kraken2 tool using a custom Database

#SBATCH --nodes=30 #Numero de Nós
#SBATCH --ntasks-per-node=1 #Numero de tarefas por Nó
#SBATCH --cpus-per-task=5 #Numero de threads
#SBATCH --partition=cpu
#SBATCH -J profile_kraken2 #Nome job
##SBATCH --time=24:00:00	         #Altera o tempo limite para 24 horas
#Exibe os nós alocados para o Job

echo $SLURM_JOB_NODELIST
nodeset -e $SLURM_JOB_NODELIST
cd $SCRATCH

###########################################################
#                                                         #
#     Change the directory to your working directory      #
#                                                         #
###########################################################
cd /scratch/ebiodiv/maria.costa/data_aquifer_db_suzana_table_mgm/filtered_prinseq_good

#Below commands are controls to know if we are in the correct folder to run the jobs
#ls -lh
#pwd

#Load appropriate module
module load kraken2/2.0.6

#Array lista contains the files you wish to filter with PRINSEQ
lista=(file1_prinseq.good
file2_prinseq.good
file3_prinseq.good
)

#For each of the files in the list, do
for file in "${lista[@]}"; do
  do

	#Get the variables corresponding to base name of the file, prefix of the file and ids
        base=${file##*/}
        prefix=${base%.*}
        id=${prefix%%_*}

	#Run the command, only if the report file of Kraken2 do not exist in the current directory
	if [ ! -f ${id}_kraken.report ]
	  then

		###########################################################
		#                                                         #
		#     Change the directory of the Kraken2_DB              #
		#                                                         #
		###########################################################

		#Slurm queue command to submit the job
		srun -N 30 -n 1 -c 5 --partition=cpu kraken2 --db /scratch/ebiodiv/maria.costa/Kraken2_DB --threads 5 $file --output ${id}_kraken.profiled --use-names --report ${id}_kraken.report 
		echo "Produced profile and report for file: ${file}!"
		
	else 	
		#If there is already a report file from Kraken2, then the program will run overwrite this file
		echo "${id}_kraken.report already exists!"
	fi

done

