#!/bin/bash
#SBATCH --time=24:0:0
#SBATCH --nodes=2
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=32000
#SBATCH --job-name=TractSeg_bundle
#SBATCH --partition=short



	module load singularity
    module load cuda/9.1
    module load fsl
    export SINGULARITYENV_LD_LIBRARY_PATH="/shared/centos7/cuda/9.1/lib64"
	#bind folder to singularity
	export SINGULARITY_BIND="/work/cbhlab/ignite/IGNITE:/mnt,/shared/centos7"
	#define/create some directories
	POP_DIR=/mnt/POP_larger
	POP_DIR_NS=/work/cbhlab/ignite/IGNITE/POP_larger
	mx=/shared/container_repository/MRtrix/MRtrix3.sif
	ts=/shared/container_repository/TractSeg/tractseg_2.7.sif
	module load anaconda3/2022.01

#Steps to transform population template to MNI space, then run tractseg to get 72 fiber bundles, then return the fiber bundles to native population template space for subsequent analysis:
# First need to extract a single 3D l0image from the 4d template:
   singularity exec ${mx} mrconvert ${POP_DIR}/template_stridesfixed.mif ${POP_DIR}/trackseg/l0image.nii.gz -coord 3 0 -force
#This results in a “3d” image that still contains a fourth dimension that is only 1 volume in length. This causes issues with the registration-to-MNI-space step below. So first split the image using fslpslit 
   fslsplit ${POP_DIR_NS}/trackseg/l0image.nii.gz 
#Now that we have a single 3D volume to register to MNI space, calculate the registration using Mrtrix’s mrregister. We register it to the MNI template image “MNI_FA_template.nii.gz”
 singularity exec ${mx} mrregister -type rigid -transformed ${POP_DIR}/trackseg/l0image_2mni.nii.gz -rigid ${POP_DIR}/trackseg/l0image_2mni.txt ${POP_DIR}/trackseg/vol0000.nii.gz ${POP_DIR}/trackseg/MNI_FA_template.nii.gz -force 
# Then we apply the register-to-MNI transform to your population template image:
   singularity exec ${mx} mrtransform ${POP_DIR}/template_gm_fod_grouprf_norm.mif -linear ${POP_DIR}/trackseg/l0image_2mni.txt -template ${POP_DIR}/trackseg/MNI_FA_template.nii.gz ${POP_DIR}/trackseg/template2mni.mif -force
# calculate a “peaks” image (for input to tractseg) from this MNI space template:
  singularity exec ${mx} sh2peaks ${POP_DIR}/trackseg/template2mni.mif ${POP_DIR}/trackseg/peaks_mni.nii.gz -force

#run trackseg
cd /work/cbhlab/ignite/IGNITE/POP_larger/tractseg
  singularity exec ${ts} TractSeg -i ${POP_DIR_NS}/trackseg/peaks_mni.nii.gz --output_type TOM -force
 #Create an “identity” warp using the native-space l0image.nii.gz:
  singularity exec ${ts} warpinit ${POP_DIR}/trackseg/l0image.nii.gz ${POP_DIR}/trackseg/wi.mif
 #Then compose a transform to apply to each of the .tck fiber bundles, using the rigid-body “template-to-mni” transform calculated above:
   singularity exec ${ts} transformcompose ${POP_DIR}/trackseg/wi.mif ${POP_DIR}/trackseg/l0image_2mni.txt ${POP_DIR}/trackseg/warp.mif -template ${POP_DIR}/trackseg/l0image_2mni.nii.gz 
 #Then, finally, apply this transform to each of the .tck files:
for i in $tracts; do singularity exec ${ts} tcktransform ${POP_DIR}/trackseg/${i}.tck ${POP_DIR}/trackseg/warp.mif ${POP_DIR}/trackseg/${i}_native.tck; done 
