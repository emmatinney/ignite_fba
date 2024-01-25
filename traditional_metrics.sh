#!/bin/bash 
#SBATCH --job-name=mrtrix
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=32000
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


	#path to mrtrix3 singularity container, for executing mrtrix commands
	mx=/shared/container_repository/MRtrix/MRtrix3.sif
	
    singularity exec --nv ${mx} dwi2tensor ${PP_DIR}/DWI_DN_UR_BC_1MM.mif ${PP_DIR}/dti.mif -mask ${PP_DIR}/MASK_1MM_ss.mif -b0 ${PP_DIR}/MEANB0_1MM.mif -force
    
    #dwi to tensor Generate maps of tensor-derived parameters
    singularity exec --nv ${mx} tensor2metric ${PP_DIR}/dti.mif -adc ${PP_DIR}/${SUBJID}_MD.mif -force
    singularity exec --nv ${mx} tensor2metric ${PP_DIR}/dti.mif -fa ${PP_DIR}/${SUBJID}_FA.mif -force
    singularity exec --nv ${mx} tensor2metric ${PP_DIR}/dti.mif -rd ${PP_DIR}/${SUBJID}_RD.mif -force
	singularity exec --nv ${mx} tensor2metric ${PP_DIR}/dti.mif -ad ${PP_DIR}/${SUBJID}_AD.mif -force

singularity exec ${mx} tcksample -stat_tck mean ${POP_DIR}/tractseg/ForEmma/tractseg_output/masks/CC_mask.tck ${PP_DIR}/${SUBJID}_AD.mif ${PP_DIR}/AD_CC.txt

awk '{ sum += $1 } END { if (NR > 0) print sum / NR }' ${PP_DIR_NS}/AD_CC.txt > ${PP_DIR_NS}/mean_AD_CC.txt