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
	POP_DIR=/mnt/POP_larger
	POP_DIR_NS=/work/cbhlab/ignite/IGNITE/POP_larger

	#path to mrtrix3 singularity container, for executing mrtrix commands
	mx=/shared/container_repository/MRtrix/MRtrix3.sif
	singularity exec ${mx} fixelfilter ${POP_DIR}/fd smooth ${POP_DIR}/fd_smooth -matrix ${POP_DIR}/tracks_2_million_sift_fixelconnmatrix
	singularity exec ${mx} fixelfilter ${POP_DIR}/fc smooth ${POP_DIR}/fc_smooth -matrix ${POP_DIR}/tracks_2_million_sift_fixelconnmatrix
	singularity exec ${mx} fixelfilter ${POP_DIR}/fdc smooth ${POP_DIR}/fdc_smooth -matrix ${POP_DIR}/tracks_2_million_sift_fixelconnmatrix
    singularity exec ${mx} fixelfilter ${POP_DIR}/log_fc smooth ${POP_DIR}/log_fc_smooth -matrix ${POP_DIR}/tracks_2_million_sift_fixelconnmatrix
