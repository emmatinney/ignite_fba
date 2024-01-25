#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=32000
#SBATCH --job-name=make_glass_brain
#SBATCH --partition=short


	module load singularity
     export SINGULARITYENV_LD_LIBRARY_PATH="/shared/centos7/cuda/9.1/lib64"
	. ${FSLDIR}/etc/fslconf/fsl.sh
	unset LD_LIBRARY_PATH
	export SINGULARITY_BIND="/work/cbhlab/ignite/IGNITE:/mnt,/shared/centos7"        
    POP_DIR=/mnt/POP_larger_2
	POP_DIR_NS=/work/cbhlab/ignite/IGNITE/POP_larger_2
     mx=/shared/container_repository/MRtrix/mrtrix3_3.0.4.sif


# note1: the force flag is to over-write my old files
# note2: when loading this glass brain in mrview, you will have to select volume render under the view tab
# note3: won't work on discovery cluster (potentially memory issue) recommend using local computer

# up-scale the population template mask 
	singularity exec ${mx} mrgrid -force ${POP_DIR}/template_wm_fod_grouprf_norm_mask.mif regrid -scale 2 ${POP_DIR}/template_mask_up.mif
# smooth the mask file
	singularity exec ${mx} mrfilter -force ${POP_DIR}/template_mask_up.mif smooth -stdev 1 ${POP_DIR}/template_mask_smooth.mif
# make the result neat by thresholding
	singularity exec ${mx} mrthreshold  -force ${POP_DIR}/template_mask_smooth.mif -abs 0.5 ${POP_DIR}/template_mask_thres.mif
# dilate the volume
	singularity exec ${mx} maskfilter -force ${POP_DIR}/template_mask_thres.mif dilate -npass 2 ${POP_DIR}/template_mask_dilated.mif 
# subtracting the volume and get the glass brain
	singularity exec ${mx} mrcalc -force ${POP_DIR}/template_mask_dilated.mif ${POP_DIR}/template_mask_thres.mif -subtract ${POP_DIR}/template_glass_brain.mif
