#!/bin/bash
#SBATCH --job-name=5ttgen_${SUBJID}
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=32000
#SBATCH --partition=short


	#load required software
    module load singularity/3.5.3
    MX=/shared/container_repository/MRtrix/mrtrix_ubuntu.sif

	. ${FSLDIR}/etc/fslconf/fsl.sh
	unset LD_LIBRARY_PATH
	#bind folder to singularity
	export SINGULARITY_BIND="/work/cbhlab/ignite/IGNITE:/mnt,/shared/centos7"
	SUBJID=REPLACE
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
	SUBJID=REPLACE

	#path to mrtrix3 singularity container, for executing mrtrix commands
	mx=/shared/container_repository/MRtrix/MRtrix3.sif

	#define/create some directories
	RAW_DIR=/mnt/DR45_Diffusion_forEmma/${SUBJID}_MR1 #where the raw DWI data are stored
	RAW_DIR_NS=/work/cbhlab/ignite/IGNITE/DR45_Diffusion_forEmma/${SUBJID}_MR1
	#RAW_DIR_FMAP_NS=/work/cnelab/TECHS/MRI/BID/${SUBJID}/fmap
	#RAW_DIR_FMAP=/mnt/BID/${SUBJID}/fmap
	FS_DIR=/mnt/Freesurfer/${SUBJID}_MR1_FS_HIRES #where the already-run Freesurfer output is stored
	FS_DIR_NS=/work/cbhlab/ignite/IGNITE/Freesurfer/${SUBJID}_MR1_FS_HIRES #non-singularity path to freesurfer folder
	SUBJECTS_DIR=/work/cbhlab/ignite/IGNITE/Freesurfer/${SUBJID}_MR1_FS_HIRES #for freesurfer commands
	PP_DIR=/mnt/dwi_preprocessed_data/${SUBJID}_MR1 #where the additionally processed data are stored
	PP_DIR_NS=/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/${SUBJID}_MR1 #path to_ses-1-processed folder OUTSIDE singularity 
	FS_DIR=/mnt/Freesurfer/${SUBJID}_MR1_FS_HIRES #where the already-run Freesurfer output is stored
	SUBJECTS_DIR=/work/cbhlab/ignite/IGNITE/Freesurfer/${SUBJID}_MR1_FS_HIRES #for freesurfer commands
	PP_DIR=/mnt/dwi_preprocessed_data/${SUBJID}_MR1 #where the additionally processed data are stored
	RF_DIR=/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/GROUP-RF

#    singularity exec --nv ${MX} 5ttgen -nocrop hsvs ${FS_DIR} ${PP_DIR}/5tt_hsvs.nii.gz
  # 	mri_vol2vol --mov ${PP_DIR_NS}/MEANB0_1MM.nii.gz --targ ${PP_DIR_NS}/5tt_hsvs.nii.gz --lta ${PP_DIR_NS}/MEANB02MRIFS.lta --inv --interp nearest --o ${PP_DIR_NS}/5tt_hsvs2MEANB0.nii.gz
	singularity exec ${mx} dwi2fod msmt_csd -force ${PP_DIR}/DWI_DN_UR_BC_1MM.mif ${RF_DIR}/GROUPAVG_RF_WM_DHOLL.txt ${PP_DIR}/WM_FOD_GROUPAVG_RF.mif ${RF_DIR}/GROUPAVG_RF_GM_DHOLL.txt ${PP_DIR}/GM_FOD_GROUPAVG_RF.mif ${RF_DIR}/GROUPAVG_RF_CSF_DHOLL.txt ${PP_DIR}/CSF_FOD_GROUPAVG_RF.mif -mask ${PP_DIR}/MASK_1MM_ss.mif
	singularity exec ${mx} mtnormalise ${PP_DIR}/WM_FOD_GROUPAVG_RF.mif ${PP_DIR}/WM_FOD_GROUPAVG_RF_NORM.mif ${PP_DIR}/GM_FOD_GROUPAVG_RF.mif ${PP_DIR}/GM_FOD_GROUPAVG_RF_NORM.mif ${PP_DIR}/CSF_FOD_GROUPAVG_RF.mif ${PP_DIR}/CSF_FOD_GROUPAVG_RF_NORM.mif -mask ${PP_DIR}/MASK_1MM_ss.mif
