#!/bin/bash 
#SBATCH --job-name=mrtrix
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=32000
#SBATCH --partition=short

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
    PP_DIR=/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data
    tbss=/work/cbhlab/ignite/IGNITE/tbss/mytbss
	mx=/shared/container_repository/MRtrix/MRtrix3.sif

while IFS= read -r subject; do
    cd  ${PP_DIR}/${subject}_MR1
singularity exec ${mx} mrconvert ${subject}_AD.mif ${subject}_AD.nii
cp ${PP_DIR}/${subject}_MR1/${subject}_AD.nii ${tbss}/AD
singularity exec ${mx} mrconvert ${subject}_RD.mif ${subject}_RD.nii
cp ${PP_DIR}/${subject}_MR1/${subject}_RD.nii ${tbss}/RD
singularity exec ${mx} mrconvert ${subject}_MD.mif ${subject}_MD.nii
cp ${PP_DIR}/${subject}_MR1/${subject}_MD.nii ${tbss}/MD
done < /work/cbhlab/ignite/IGNITE/subj.txt