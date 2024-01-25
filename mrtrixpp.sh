#!/bin/bash 
#SBATCH --job-name=mrtrix
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=32000
#SBATCH --partition=short


#if [ $# -lt 1 ] ; then
#        echo '
#------ MRTRIX_ses-1-PROCESSING FOR FBA --------

#'
#	       exit 0
#fi

#while getopts i: flag

#do
	
#    case "${flag}" in
#		i) SUBJID="$OPTARG";;
#    esac
	
#done
#run one script per subj
# Read subjects from subj.txt into an array 
#subjects=($(cat subj.txt))
# Loop through the subjects
#for i in "${subjects[@]}"; do
    # Copy mrtrixpp.sh to a new file with subject-specific name
 #   cp 5ttgen_hvsv.sh "5ttgen_hvsv_${i}.sh"
    # Use sed to replace "REPLACE" with the current subject
 #   sed -i "s/REPLACE/${i}/g" "5ttgen_hvsv_${i}.sh"
#done
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
	RF_DIR=/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/GROUP-RF
	RF_DIR1=/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/GROUP-RF_1
	RF_DIR2=/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/GROUP-RF_2
	RF_DIR3=/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/GROUP-RF_3 #where the subject-specific tissue response functions should be copied to, for group averaging 
	if [ ! -d ${PP_DIR_NS} ]; then mkdir ${PP_DIR_NS}; fi
	if [ ! -d ${RF_DIR} ]; then mkdir ${RF_DIR}; fi
	if [ ! -d ${RF_DIR1} ]; then mkdir ${RF_DIR1}; fi
	if [ ! -d ${RF_DIR2} ]; then mkdir ${RF_DIR2}; fi
	if [ ! -d ${RF_DIR3} ]; then mkdir ${RF_DIR3}; fi

	#path to mrtrix3 singularity container, for executing mrtrix commands
	mx=/shared/container_repository/MRtrix/MRtrix3.sif
	
	#convert diffusion data and blip-up/blip-down sequences to mrtrix's mif format. this data is already distortion and eddy current corrected 
	singularity exec --nv ${mx} mrconvert $RAW_DIR/fdti_ec.nii.gz $PP_DIR/DWI.mif -fslgrad $RAW_DIR/bvec $RAW_DIR/bval

	#perform initial denoising, unringing, and DWI mask creation (from distorted images) steps - note *DN = denoised, *UR = unringed
	singularity exec --nv ${mx} dwidenoise ${PP_DIR}/DWI.mif ${PP_DIR}/DWI_DN.mif -noise ${PP_DIR}/NOISE.mif
	singularity exec --nv ${mx} mrcalc ${PP_DIR}/DWI.mif ${PP_DIR}/DWI_DN.mif -subtract ${PP_DIR}/RESIDUAL.mif #difference between raw and the denoised images and save as "RESIDUAL.mif"
	singularity exec --nv ${mx} mrdegibbs ${PP_DIR}/DWI_DN.mif ${PP_DIR}/DWI_DN_UR.mif
	
    #bias field correction using ants, save out bias field as image - note *BC = bias-corrected
	singularity exec --nv ${mx} dwibiascorrect ants ${PP_DIR}/DWI_DN_UR.mif ${PP_DIR}/DWI_DN_UR_BC.mif -bias ${PP_DIR}/BIAS.mif

	#extract b=0 images and calculate mean
	singularity exec --nv ${mx} dwiextract ${PP_DIR}/DWI_DN_UR_BC.mif -bzero ${PP_DIR}/DWI_DN_UR_BC_B0S.mif
	singularity exec --nv ${mx} mrmath ${PP_DIR}/DWI_DN_UR_BC_B0S.mif mean $PP_DIR/MEANB0.nii.gz -axis 3  

	#create brain mask - two versions (one using dwi2mask and another using fsl's bet, just in case one works better ...)
	singularity exec --nv ${mx} dwi2mask ${PP_DIR}/DWI_DN_UR_BC.mif ${PP_DIR}/MASK.mif 
	bet2 ${PP_DIR_NS}/MEANB0.nii.gz ${PP_DIR_NS}/ALTMASK_BET2.nii.gz -m
	singularity exec --nv ${mx} mrconvert ${PP_DIR}/MASK.mif ${PP_DIR}/MASK.nii.gz
   
	#estimate subject-specific tissue response functions using 'dhollander' method
	singularity exec --nv ${mx} dwi2response dhollander -voxels ${PP_DIR}/RF_VOXELS_DHOLL.mif ${PP_DIR}/DWI_DN_UR_BC.mif ${PP_DIR}/RF_WM_DHOLL.txt ${PP_DIR}/RF_GM_DHOLL.txt ${PP_DIR}/RF_CSF_DHOLL.txt 
	
	#copy subject-specific tissue response functions to common group directory for group-averaging
	cp ${PP_DIR_NS}/RF_WM_DHOLL.txt ${RF_DIR}/${SUBJID}_RF_WM_DHOLL.txt 
	cp ${PP_DIR_NS}/RF_GM_DHOLL.txt ${RF_DIR}/${SUBJID}_RF_GM_DHOLL.txt
	cp ${PP_DIR_NS}/RF_CSF_DHOLL.txt ${RF_DIR}/${SUBJID}_RF_CSF_DHOLL.txt
	
    site=$(cut -c 1-1 <<< ${SUBJID})
    if [ "$site" = "1" ]; then 
	cp ${PP_DIR_NS}/RF_WM_DHOLL.txt ${RF_DIR1}/${SUBJID}_RF_WM_DHOLL.txt 
	cp ${PP_DIR_NS}/RF_GM_DHOLL.txt ${RF_DIR1}/${SUBJID}_RF_GM_DHOLL.txt
	cp ${PP_DIR_NS}/RF_CSF_DHOLL.txt ${RF_DIR1}/${SUBJID}_RF_CSF_DHOLL.txt
    elif [ "$site" = "2" ]; then
    cp ${PP_DIR_NS}/RF_WM_DHOLL.txt ${RF_DIR2}/${SUBJID}_RF_WM_DHOLL.txt 
	cp ${PP_DIR_NS}/RF_GM_DHOLL.txt ${RF_DIR2}/${SUBJID}_RF_GM_DHOLL.txt
	cp ${PP_DIR_NS}/RF_CSF_DHOLL.txt ${RF_DIR2}/${SUBJID}_RF_CSF_DHOLL.txt
    elif [ "$site" = "3" ]; then
    cp ${PP_DIR_NS}/RF_WM_DHOLL.txt ${RF_DIR3}/${SUBJID}_RF_WM_DHOLL.txt 
	cp ${PP_DIR_NS}/RF_GM_DHOLL.txt ${RF_DIR3}/${SUBJID}_RF_GM_DHOLL.txt
	cp ${PP_DIR_NS}/RF_CSF_DHOLL.txt ${RF_DIR3}/${SUBJID}_RF_CSF_DHOLL.txt
    fi
    
	#workaround to use old fsl. fsl_sub not working in other version
	module unload fsl
	module unload fsl/6.0.0
	module load fsl/2019-01-11
	. ${FSLDIR}/etc/fslconf/fsl.sh
	
	 #upsample the data to 1mm voxel 
    singularity exec ${mx} mrgrid ${PP_DIR}/DWI_DN_UR_BC.mif regrid ${PP_DIR}/DWI_DN_UR_BC_1MM.mif -voxel 1.0
    singularity exec ${mx} mrgrid ${PP_DIR}/MASK.mif regrid - -template ${PP_DIR}/DWI_DN_UR_BC_1MM.mif -interp linear -datatype bit | singularity exec ${mx} maskfilter - median ${PP_DIR}/MASK_1MM.mif
	#extract b=0 images and calculate mean
	singularity exec --nv ${mx} dwiextract ${PP_DIR}/DWI_DN_UR_BC_1MM.mif -bzero ${PP_DIR}/DWI_DN_UR_BC_1MM_B0S.mif
	singularity exec --nv ${mx} mrmath ${PP_DIR}/DWI_DN_UR_BC_1MM_B0S.mif mean ${PP_DIR}/MEANB0_1MM.nii.gz -axis 3  

	#generate a "5 tissue type" segmentation from freesurfer output using hybrid surface-volume method
	singularity exec --nv ${mx} 5ttgen -nocrop hsvs ${FS_DIR} ${PP_DIR}/5tt_hsvs.nii.gz #note save as .nii.gz because want to apply transforms to this outside of mrtrix 
#	singularity exec --nv ${mx} 5ttgen -nocrop fsl ${FS_DIR} ${PP_DIR}/5tt_fsl.nii.gz #note save as .nii.gz because want to apply transforms to this outside of mrtrix 
	singularity exec --nv ${mx} 5ttgen -nocrop freesurfer ${FS_DIR}/mri/aparc+aseg.mgz ${PP_DIR}/5tt_freesurfer.nii.gz #note save as .nii.gz because want to apply transforms to this outside of mrtrix 

	#calculate registration (DWI-to-T1), using Freesurfer's bbregister
	bbregister --s ${SUBJID}_MR1_FS_HIRES --mov ${PP_DIR_NS}/MEANB0_1MM.nii.gz --reg ${PP_DIR_NS}/MEANB02MRIFS.lta --dti --o ${PP_DIR_NS}/MEANB02MRIFS.nii.gz
	
	#register 5tt segmentation to mean b0, using INVERSE of transform calculated above
#	mri_vol2vol --mov ${PP_DIR_NS}/MEANB0_1MM.nii.gz --targ ${PP_DIR_NS}/5tt_hsvs.nii.gz --lta ${PP_DIR_NS}/MEANB02MRIFS.lta --inv --interp nearest --o ${PP_DIR_NS}/5tt_hsvs2MEANB0.nii.gz
#	mri_vol2vol --mov ${PP_DIR_NS}/MEANB0_1MM.nii.gz --targ ${PP_DIR_NS}/5tt_fsl.nii.gz --lta ${PP_DIR_NS}/MEANB02MRIFS.lta --inv --interp nearest --o ${PP_DIR_NS}/5tt_fsl2MEANB0.nii.gz
	mri_vol2vol --mov ${PP_DIR_NS}/MEANB0_1MM.nii.gz --targ ${PP_DIR_NS}/5tt_freesurfer.nii.gz --lta ${PP_DIR_NS}/MEANB02MRIFS.lta --inv --interp nearest --o ${PP_DIR_NS}/5tt_freesurfer2MEANB0.nii.gz
    
   