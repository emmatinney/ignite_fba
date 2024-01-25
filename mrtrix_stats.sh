#!/bin/bash
#SBATCH --time=24:0:0
#SBATCH --nodes=2
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=32000
#SBATCH --job-name=MRtrix
#SBATCH --partition=short

	module load singularity
     module load cuda/9.1
    export SINGULARITYENV_LD_LIBRARY_PATH="/shared/centos7/cuda/9.1/lib64"
	#bind folder to singularity
	export SINGULARITY_BIND="/work/cbhlab/ignite/IGNITE:/mnt,/shared/centos7"


	#define/create some directories
	POP_DIR=/mnt/POP_larger_2
	POP_DIR_NS=/work/cbhlab/ignite/IGNITE/POP_larger_2

	#path to mrtrix3 singularity container, for executing mrtrix commands
	mx=/shared/container_repository/MRtrix/MRtrix3.sif
    singularity exec ${mx} fixelcfestats ${POP_DIR}/fc ${POP_DIR}/subj.txt ${POP_DIR}/Design_matrix_age_sex_educ_site_race_etiv_vo2.txt ${POP_DIR}/contrasts_fitness.txt ${POP_DIR}/tracks_2_million_sift_fixelconnmatrix ${POP_DIR}/fc_stats_vo2 -nshuffles 500
