#!/bin/bash 
#SBATCH --job-name=mrtrix
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=32000
#SBATCH --partition=short
#SBATCH --time=24:0:0
#SBATCH --mail-user=tinney.e@northeastern.edu

	#load required software
	module unload fsl #was causing issues before ... just unload in case something already loaded
	module load singularity
	module load fsl/6.0.0
	module load freesurfer
    module load cuda/9.1
    module load ants
    export SINGULARITYENV_LD_LIBRARY_PATH="/shared/centos7/cuda/9.1/lib64"

	. ${FSLDIR}/etc/fslconf/fsl.sh
	unset LD_LIBRARY_PATH
	#bind folder to singularity
	export SINGULARITY_BIND="/work/cbhlab/ignite/IGNITE:/mnt,/shared/centos7"
	SUBJID=REPLACE

	#define/create some directories
	RAW_DIR=/mnt/DR45_Diffusion_forEmma/${SUBJID}_MR1 #where the raw DWI data are stored
	RAW_DIR_NS=/work/cbhlab/ignite/IGNITE/DR45_Diffusion_forEmma/${SUBJID}_MR1
	FS_DIR=/mnt/Freesurfer/${SUBJID}_MR1_FS_HIRES #where the already-run Freesurfer output is stored
	FS_DIR_NS=/work/cbhlab/ignite/IGNITE/Freesurfer/${SUBJID}_MR1_FS_HIRES #non-singularity path to freesurfer folder
	SUBJECTS_DIR=/work/cbhlab/ignite/IGNITE/Freesurfer/${SUBJID}_MR1_FS_HIRES #for freesurfer commands
	PP_DIR=/mnt/dwi_preprocessed_data/${SUBJID}_MR1 #where the additionally processed data are stored
	PP_DIR_NS=/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/${SUBJID}_MR1 #path to_ses-1-processed folder OUTSIDE singularity 
	RF_DIR=/mnt/dwi_preprocessed_data/GROUP-RF

	#path to mrtrix3 singularity container, for executing mrtrix commands
	mx=/shared/container_repository/MRtrix/MRtrix3.sif
	
	singularity exec ${mx} dwi2fod msmt_csd ${PP_DIR}/DWI_DN_UR_BC_1MM.mif ${RF_DIR}/GROUPAVG_RF_WM_DHOLL.txt ${PP_DIR}/WM_FOD_GROUPAVG_RF.mif ${RF_DIR}/GROUPAVG_RF_GM_DHOLL.txt ${PP_DIR}/GM_FOD_GROUPAVG_RF.mif ${RF_DIR}/GROUPAVG_RF_CSF_DHOLL.txt ${PP_DIR}/CSF_FOD_GROUPAVG_RF.mif -mask ${PP_DIR}/MASK_1MM_ss.mif -force
	singularity exec ${mx} mtnormalise ${PP_DIR}/WM_FOD_GROUPAVG_RF.mif ${PP_DIR}/WM_FOD_GROUPAVG_RF_NORM.mif ${PP_DIR}/GM_FOD_GROUPAVG_RF.mif ${PP_DIR}/GM_FOD_GROUPAVG_RF_NORM.mif ${PP_DIR}/CSF_FOD_GROUPAVG_RF.mif ${PP_DIR}/CSF_FOD_GROUPAVG_RF_NORM.mif -mask ${PP_DIR}/MASK_1MM_ss.mif -force
	
