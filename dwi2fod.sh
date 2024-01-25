#!/bin/bash
#SBATCH --time=24:0:0
#SBATCH --nodes=2
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=32000
#SBATCH --job-name=MRtrix_CR_createFOD
#SBATCH --partition=short

	
	#load required software
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
#	SUBJID=`sed "${SLURM_ARRAY_TASK_ID}q;d" subj.txt`
	SUBJID=REPLACE

	#define/create some directories
	RAW_DIR=/mnt/DR45_Diffusion_forEmma/${SUBJID}_MR1 #where the raw DWI data are stored
	RAW_DIR_NS=/work/cbhlab/ignite/IGNITE/DR45_Diffusion_forEmma/${SUBJID}_MR1
	FS_DIR=/mnt/Freesurfer/${SUBJID}_MR1_FS_HIRES #where the already-run Freesurfer output is stored
	FS_DIR_NS=/work/cbhlab/ignite/IGNITE/Freesurfer/${SUBJID}_MR1_FS_HIRES #non-singularity path to freesurfer folder
	SUBJECTS_DIR=/work/cbhlab/ignite/IGNITE/Freesurfer/${SUBJID}_MR1_FS_HIRES #for freesurfer commands
	PP_DIR=/mnt/dwi_preprocessed_data/${SUBJID}_MR1 #where the additionally processed data are stored
	PP_DIR_NS=/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/${SUBJID}_MR1 #path to_ses-1-processed folder OUTSIDE singularity 
	RF_DIR=/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/GROUP-RF
	RF_DIR1=/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/GROUP-RF_1
	RF_DIR2=/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/GROUP-RF_2
	RF_DIR3=/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/GROUP-RF_3 #where the subject-specific tissue response functions should be copied to, for group averaging 
	
	#path to mrtrix3 singularity container, for executing mrtrix commands
	mx=/shared/container_repository/MRtrix/MRtrix3.sif

    # this is to convert preprocessed data to FOD files
    singularity exec ${mx} dwi2fod msmt_csd -force ${PP_DIR}/DWI_DN_UR_BC_1MM.mif -mask ${PP_DIR}/MASK_1MM.mif ${PP_DIR}/RF_WM_DHOLL.txt ${PP_DIR}/WM_FOD_RF.mif ${PP_DIR}/RF_GM_DHOLL.txt ${PP_DIR}/GM_FOD_RF.mif ${PP_DIR}/RF_CSF_DHOLL.txt ${PP_DIR}/CSF_FOD_RF.mif 
# this is to generate a file for viewing
    singularity exec ${mx} mrconvert -force -coord 3 0 ${PP_DIR}/WM_FOD_RF.mif - | singularity exec ${mx}  mrcat ${PP_DIR}/CSF_FOD_RF.mif ${PP_DIR}/GM_FOD_RF.mif - ${PP_DIR}/VF.mif
# this is to normalize the FOD in case of confounded by intensity of images
    singularity exec ${mx} mtnormalise -force ${PP_DIR}/WM_FOD_RF.mif ${PP_DIR}/WM_FOD_norm.mif ${PP_DIR}/GM_FOD_RF.mif ${PP_DIR}/GM_FOD_norm.mif ${PP_DIR}/CSF_FOD_RF.mif ${PP_DIR}/CSF_FOD_norm.mif -mask ${PP_DIR}/MASK_1MM.mif

	