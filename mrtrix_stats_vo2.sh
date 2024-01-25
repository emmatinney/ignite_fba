#!/bin/bash
#SBATCH --partition=long
#SBATCH --time=120:00:00
#SBATCH -N 1
#SBATCH -n 24
#SBATCH --mem=100g
#SBATCH --job-name=vo2

	module load singularity
     module load cuda/9.1
    export SINGULARITYENV_LD_LIBRARY_PATH="/shared/centos7/cuda/9.1/lib64"
	#bind folder to singularity
	export SINGULARITY_BIND="/work/cbhlab/ignite/IGNITE:/mnt,/shared/centos7"


	#define/create some directories
	POP_DIR=/mnt/POP_larger
	POP_DIR_NS=/work/cbhlab/ignite/IGNITE/POP_larger

	#path to mrtrix3 singularity container, for executing mrtrix commands
	mx=/shared/container_repository/MRtrix/MRtrix3.sif
    singularity exec ${mx} fixelcfestats ${POP_DIR}/fdc_smooth ${POP_DIR}/subj.txt ${POP_DIR}/Design_matrix_age_sex_educ_site_race_vo2.txt ${POP_DIR}/contrasts.txt ${POP_DIR}/tracks_2_million_sift_fixelconnmatrix ${POP_DIR}/fdc_stats_vo2_smooth_center_control -nshuffles 500
    singularity exec ${mx} fixelcfestats ${POP_DIR}/log_fc_smooth ${POP_DIR}/subj.txt ${POP_DIR}/Design_matrix_age_sex_educ_site_race_vo2.txt ${POP_DIR}/contrasts.txt ${POP_DIR}/tracks_2_million_sift_fixelconnmatrix ${POP_DIR}/log_fc_stats_vo2_smooth_center_control -nshuffles 500
    singularity exec ${mx} fixelcfestats ${POP_DIR}/fd_smooth ${POP_DIR}/subj.txt ${POP_DIR}/Design_matrix_age_sex_educ_site_race_vo2.txt ${POP_DIR}/contrasts.txt ${POP_DIR}/tracks_2_million_sift_fixelconnmatrix ${POP_DIR}/fd_stats_vo2_smooth_center_control -nshuffles 500
