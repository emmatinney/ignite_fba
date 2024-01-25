#!/bin/bash 
#SBATCH --job-name=response_mean
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=8000
#SBATCH --partition=short
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=tinney.e@northeastern.edu

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


	RF_DIR=/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/GROUP-RF
	RF_DIR1=/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/GROUP-RF_1
	RF_DIR2=/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/GROUP-RF_2
	RF_DIR3=/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/GROUP-RF_3 #where the subject-specific tissue response functions should be copied to, for group averaging 
	
	#path to mrtrix3 singularity container, for executing mrtrix commands
	mx=/shared/container_repository/MRtrix/MRtrix3.sif

    cd $RF_DIR 
	singularity exec ${mx} responsemean *_WM_DHOLL.txt GROUPAVG_RF_WM_DHOLL.txt
	singularity exec ${mx} responsemean *_GM_DHOLL.txt GROUPAVG_RF_GM_DHOLL.txt
	singularity exec ${mx} responsemean *_CSF_DHOLL.txt GROUPAVG_RF_CSF_DHOLL.txt

    cd $RF_DIR1
	singularity exec ${mx} responsemean *_WM_DHOLL.txt GROUPAVG_RF_WM_DHOLL.txt
	singularity exec ${mx} responsemean *_GM_DHOLL.txt GROUPAVG_RF_GM_DHOLL.txt
	singularity exec ${mx} responsemean *_CSF_DHOLL.txt GROUPAVG_RF_CSF_DHOLL.txt
	
	cd $RF_DIR2
	singularity exec ${mx} responsemean *_WM_DHOLL.txt GROUPAVG_RF_WM_DHOLL.txt
	singularity exec ${mx} responsemean *_GM_DHOLL.txt GROUPAVG_RF_GM_DHOLL.txt
	singularity exec ${mx} responsemean *_CSF_DHOLL.txt GROUPAVG_RF_CSF_DHOLL.txt
	
	cd $RF_DIR3
	singularity exec ${mx} responsemean *_WM_DHOLL.txt GROUPAVG_RF_WM_DHOLL.txt
	singularity exec ${mx} responsemean *_GM_DHOLL.txt GROUPAVG_RF_GM_DHOLL.txt
	singularity exec ${mx} responsemean *_CSF_DHOLL.txt GROUPAVG_RF_CSF_DHOLL.txt
	
	