#!/bin/bash
#SBATCH --partition=long
#SBATCH --time=120:00:00
#SBATCH -N 1
#SBATCH -n 24
#SBATCH --mem=100g
#SBATCH --job-name=poptemplate
#SBATCH --mail-user=tinney.e@northeastern.edu

#population template script. 

	module unload fsl #was causing issues before ... just unload in case something already loaded
	module load singularity
	module load fsl/6.0.0
	module load freesurfer
    module load cuda/9.1
    export SINGULARITYENV_LD_LIBRARY_PATH="/shared/centos7/cuda/9.1/lib64"
	. ${FSLDIR}/etc/fslconf/fsl.sh
	unset LD_LIBRARY_PATH
	#bind folder to singularity
	export SINGULARITY_BIND="/work/cbhlab/ignite/IGNITE:/mnt,/shared/centos7"
	POP_t1=/mnt/POP_larger_2/T1
	POP=/mnt/POP_larger_2
	POP_FOD=${POP}/FODS
	POP_MASK=${POP}/MASKS

	mx=/shared/container_repository/MRtrix/MRtrix3.sif


singularity exec ${mx} population_template -voxel_size 1 -nthreads 80 $POP_FOD ${POP}/template_wm_fod_grouprf_norm.mif ${POP}/FODS_GM ${POP}/template_gm_fod_grouprf_norm.mif -mask_dir $POP_MASK -template_mask ${POP}/template_wm_fod_grouprf_norm_mask.mif -warp_dir ${POP}/WARPS -transformed_dir ${POP}/TRANSFORMED_WM,${POP}/TRANSFORMED_GM -linear_transformations_dir ${POP}/LINEAR_TRANSFORMS
