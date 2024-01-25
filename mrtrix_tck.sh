#!/bin/bash
#SBATCH --partition=long
#SBATCH --time=120:00:00
#SBATCH -N 1
#SBATCH -n 24
#SBATCH --mem=100g

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

   # singularity exec ${mx} tckgen -nthreads 4 -maxlen 250 -minlen 10 ${POP_DIR}/template_wm_fod_grouprf_norm.mif -seed_image ${POP_DIR}/template_wm_fod_grouprf_norm_mask.mif -mask ${POP_DIR}/template_wm_fod_grouprf_norm_mask.mif -select  20000000 -cutoff 0.1 ${POP_DIR}/tracks_20_million.tck

    singularity exec ${mx} tcksift  ${POP_DIR}/tracks_20_million.tck ${POP_DIR}/template_wm_fod_grouprf_norm.mif ${POP_DIR}/TK_2M_sift.tck -term_number 2000000
    singularity exec ${mx} tckedit ${POP_DIR}/TK_2M_sift.tck -num 200000 ${POP_DIR}/TK_200k_sift.tck

#	singularity exec ${mx} fixelconnectivity ${POP_DIR}/FIXEL_MASK_peak01 ${POP_DIR}/TK_2M_sift.tck ${POP_DIR}/tracks_2_million_sift_fixelconnmatrix
