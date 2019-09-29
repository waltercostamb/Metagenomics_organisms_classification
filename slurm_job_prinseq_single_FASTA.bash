#!/bin/bash

    #Maria Beatriz Walter Costa

    #This script submits jobs to the slurm queueing system. It takes an array of IDs as input. You need to change the array 
    #@lista to include your IDs. You also need to change the directory (see marked warnings #########Warnings#########).
	
    #Usage: $bash SCRIPT

    #SBATCH --nodes=21 		
    #SBATCH --ntasks-per-node=1 		
    #SBATCH --cpus-per-task=1 			
    #SBATCH -p cpu
    #SBATCH -J limpeza_prinseq_SRR1283371 	
    ##SBATCH --time=24:00:00	         	
 
    #Exibe os nós alocados para o Job
    echo $SLURM_JOB_NODELIST
    nodeset -e $SLURM_JOB_NODELIST
    cd $SCRATCH

    ####################################
    #                                  #
    #         Change directory         #
    #                                  #
    ####################################

    #Here you need to change the directory to your working directory
    cd $PATH

    #Commands below are only to test the script, if it correctly changed the directory
    #ls -lh
    #pwd

    module load prinseq/0.20.4
    module load perl/5.26

    #Array with the file IDs
    ####################################
    #                                  #
    #         Change array IDs         #
    #                                  #
    ####################################
    lista=(mgm4451759
mgm4451761
mgm4453297)

for i in "${lista[@]}"
  do
	#This command submits jobs to the slurm queue
  	srun -N 21 -n 1 -c 1 $PATH/prinseq-lite.pl -verbose -fasta ${i}.fasta -min_len 80 -ns_max_p 2 -out_format 1

  done


