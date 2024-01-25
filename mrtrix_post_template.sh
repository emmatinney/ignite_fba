#!/bin/bash
#SBATCH --time=24:0:0
#SBATCH --nodes=2
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=32000
#SBATCH --job-name=MRtrix
#SBATCH --partition=short

#subj=$(cat subj.txt); for i in $subj; do sbatch 5ttgen_hvsv_${i}.sh; done
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
	SUBJID=REPLACE


	#define/create some directories
	RAW_DIR=/mnt/DR45_Diffusion_forEmma/${SUBJID}_MR1 #where the raw DWI data are stored
	RAW_DIR_NS=/work/cbhlab/ignite/IGNITE/DR45_Diffusion_forEmma/${SUBJID}_MR1
	#RAW_DIR_FMAP_NS=/work/cnelab/TECHS/MRI/BID/${SUBJID}/fmap
	#RAW_DIR_FMAP=/mnt/BID/${SUBJID}/fmap
	FS_DIR=/mnt/Freesurfer/${SUBJID}_MR1_FS_HIRES #where the already-run Freesurfer output is stored
	FS_DIR_NS=/work/cbhlab/ignite/IGNITE/Freesurfer/${SUBJID}_MR1_FS_HIRES #non-singularity path to freesurfer folder
	SUBJECTS_DIR=/work/cbhlab/ignite/IGNITE/Freesurfer #for freesurfer commands
	PP_DIR=/mnt/dwi_preprocessed_data/${SUBJID}_MR1 #where the additionally processed data are stored
	PP_DIR_NS=/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/${SUBJID}_MR1 #path to_ses-1-processed folder OUTSIDE singularity 
	POP_DIR=/mnt/POP
	POP_DIR_NS=/work/cbhlab/ignite/IGNITE/POP
	RF_DIR=/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/GROUP-RF
	RF_DIR1=/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/GROUP-RF_1
	RF_DIR2=/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/GROUP-RF_2
	RF_DIR3=/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/GROUP-RF_3 #where the subject-specific tissue response functions should be copied to, for group averaging 
    TEMP=/work/cbhlab/ignite/IGNITE/mask_temp_space

	#path to mrtrix3 singularity container, for executing mrtrix commands
	mx=/shared/container_repository/MRtrix/MRtrix3.sif
	singularity exec ${mx} mtnormalise ${PP_DIR}/WM_FOD_GROUPAVG_RF.mif ${PP_DIR}/WM_FOD_GROUPAVG_RF_NORM.mif ${PP_DIR}/GM_FOD_GROUPAVG_RF.mif ${PP_DIR}/GM_FOD_GROUPAVG_RF_NORM.mif ${PP_DIR}/CSF_FOD_GROUPAVG_RF.mif ${PP_DIR}/CSF_FOD_GROUPAVG_RF_NORM.mif -mask ${PP_DIR}/MASK_1MM_ss.mif 
    singularity exec ${mx} mrregister -type rigid_affine_nonlinear ${PP_DIR}/WM_FOD_GROUPAVG_RF_NORM.mif /mnt/POP_larger_2/template_wm_fod_grouprf_norm.mif ${PP_DIR}/GM_FOD_GROUPAVG_RF_NORM.mif /mnt/POP_larger_2/template_gm_fod_grouprf_norm.mif -mask1 ${PP_DIR}/MASK_1MM_ss.mif -nl_warp ${PP_DIR}/WM_FOD_GROUP_RF_NORM_WARP2temp.mif ${PP_DIR}/template2subject_warp.mif -force
    singularity exec ${mx} mrtransform	${PP_DIR}/MASK_1MM_ss.mif -warp ${PP_DIR}/WM_FOD_GROUP_RF_NORM_WARP2temp.mif -interp nearest -datatype bit ${PP_DIR}/MASK_warp2temp.mif -force
	singularity exec ${mx} mrtransform ${PP_DIR}/WM_FOD_GROUPAVG_RF_NORM.mif -warp ${PP_DIR}/WM_FOD_GROUP_RF_NORM_WARP2temp.mif -reorient_fod no ${PP_DIR}/WM_FOD_GROUP_RF_NORM_in_template_space_NOT_REORIENTED.mif -force
	singularity exec ${mx} fod2fixel -mask /mnt/POP_larger_2/template_wm_fod_grouprf_norm_mask.mif ${PP_DIR}/WM_FOD_GROUP_RF_NORM_in_template_space.mif ${PP_DIR}/fixel_in_template_space.mif -afd afd.mif -force
	#compute a template mask (the intersection of all individual masks)
	singularity exec ${mx} mrtransform ${PP_DIR}/MASK_1MM_ss.mif -warp ${PP_DIR}/WM_FOD_GROUP_RF_NORM_WARP2temp.mif -interp nearest -datatype bit ${PP_DIR}/MASK_TEMP_SPACE.mif -force
	# this should be done outside of this script - generate group mask
    singularity exec ${mx} mrmath ${TEMP}/* min ${POP_DIR}/MASK_TEMP.mif -datatype bit
#compute white matter template analysis fixel mask
#	singularity exec ${mx} fod2fixel -mask ${POP_DIR}/MASK_TEMP.mif -fmls_peak_value 0.1 ${POP_DIR}/template_wm_fod_grouprf_norm_40subjs.mif ${POP_DIR}/FIXEL_MASK_peak01

	# Warp FOD images to template space
#	singularity exec ${mx} mrtransform ${PP_DIR}/WM_FOD_norm.mif -warp ${PP_DIR}/SUB2TEMP_warp.mif -reorient_fod no ${PP_DIR}/FOD_TEMP_SPACE_NO_ORE.mif

	# Segment FOD images to estimate fixels and FD
#	singularity exec ${mx} fod2fixel -mask ${POP_DIR}/MASK_TEMP.mif ${PP_DIR}/FOD_TEMP_SPACE_NO_ORE.mif ${PP_DIR}/FIX_TEMP_SPACE_NO_ORE -afd fd.mif

	# Re-orient fixels 
#	singularity exec ${mx} fixelreorient ${PP_DIR}/FIX_TEMP_SPACE_NO_ORE ${PP_DIR}/SUB2TEMP_warp.mif ${PP_DIR}/FIX_TEMP_SPACE

	# Calculate FD
#	if test -f "${POP_DIR}/fd/${SUBJID}.mif"; then
#		echo "${SUBJID}.mif exits"
#	else 
#		singularity exec ${mx}  fixelcorrespondence  -force ${PP_DIR}/FIX_TEMP_SPACE/fd.mif ${POP_DIR}/FIXEL_MASK_peak01 ${POP_DIR}/fd ${SUBJID}.mif
#	fi


	# calculate FC
#	if test -f "${POP_DIR}/fc/${SUBJID}.mif"; then
#               echo "${SUBJID}.mif exits"
#        else
#		singularity exec ${mx} warp2metric -force ${PP_DIR}/SUB2TEMP_warp.mif -fc ${POP_DIR}/FIXEL_MASK_peak01 ${POP_DIR}/fc ${SUBJID}.mif
#	fi
	# calculate FDC
#	singularity exec ${mx} mrcalc -force ${POP_DIR}/fd/${SUBJID}.mif ${POP_DIR}/fc/${SUBJID}.mif -mult ${POP_DIR}/fdc/${SUBJID}.mif

	# caculate FC log
 #      singularity exec ${mx} mrcalc  ${POP_DIR}/fc/${SUBJID}.mif  -log ${POP_DIR}/log_fc/${SUBJID}.mif  
	
	
	