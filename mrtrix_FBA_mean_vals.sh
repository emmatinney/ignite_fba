#!/bin/bash

#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=32000
#SBATCH --job-name=FBA_mean_value
#SBATCH --partition=short

     module load singularity
     export SINGULARITYENV_LD_LIBRARY_PATH="/shared/centos7/cuda/9.1/lib64"
	unset LD_LIBRARY_PATH
	export SINGULARITY_BIND="/work/cbhlab/ignite/IGNITE:/mnt,/shared/centos7"        
    POP_DIR=/mnt/POP_larger
	POP_DIR_NS=/work/cbhlab/ignite/IGNITE/POP_larger
     mx=/shared/container_repository/MRtrix/mrtrix3_3.0.4.sif

cd /work/cbhlab/ignite/IGNITE/POP_larger

# create the mask for the FBA stats result
#singularity exec ${mx} mrthreshold -abs 0.95 ${POP_DIR}/fclog_stats_smooth_age_center_control/fwe_1mpvalue_t1.mif ${POP_DIR}/rs_clusters/log_fc_age_smooth_sex_educ_site_race_etiv_center_control_fwepval_t1_mask.mif
#singularity exec ${mx} mrthreshold -abs 0.95 ${POP_DIR}/fclog_stats_smooth_age_center_control/fwe_1mpvalue_t2.mif ${POP_DIR}/rs_clusters/log_fc_age_smooth_sex_educ_site_race_etiv_center_control_fwepval_t2_mask.mif
# extract the mean fd/fc/fdc values from the cluster
while read sub 
do singularity exec ${mx} mrstats ${POP_DIR}/fdc_smooth/$sub -output mean -mask  ${POP_DIR}/rs_clusters/fdc_age_smooth_sex_educ_site_race_etiv_center_control_fwepval_t2_mask.mif
done < ${POP_DIR_NS}/subj.txt


# create the mask for the FBA stats result
#	singularity exec ${mx} mrthreshold -abs 0.95 ${POP_DIR}/fdc_smooth_stats_vo2/fwe_1mpvalue_t2.mif ${POP_DIR}/rs_clusters/fdc_smooth_age_sex_educ_site_race_etiv_vo2_fwepval_t2_mask.mif
#	singularity exec ${mx} mrthreshold -abs 0.95 ${POP_DIR}/fdc_smooth_stats_vo2/fwe_1mpvalue_t1.mif ${POP_DIR}/rs_clusters/fdc_smooth_age_sex_educ_site_race_etiv_vo2_fwepval_t1_mask.mif
# extract the mean fd/fc/fdc values from the cluster
#while read sub
#do	singularity exec ${mx} mrstats ${POP_DIR}/fdc_smooth/$sub -output mean -mask  ${POP_DIR}/rs_clusters/fdc_smooth_age_sex_educ_site_race_etiv_vo2_fwepval_t2_mask.mif
#done < ${POP_DIR_NS}/subj.txt
# create the mask for the FBA stats result
#	singularity exec ${mx} mrthreshold -abs 0.95 ${POP_DIR}/fd_smooth_stats_vo2/fwe_1mpvalue_t2.mif ${POP_DIR}/rs_clusters/fd_smooth_age_sex_educ_site_race_etiv_vo2_fwepval_t2_mask.mif
#	singularity exec ${mx} mrthreshold -abs 0.95 ${POP_DIR}/fd_smooth_stats_vo2/fwe_1mpvalue_t1.mif ${POP_DIR}/rs_clusters/fd_smooth_age_sex_educ_site_race_etiv_vo2_fwepval_t1_mask.mif
# extract the mean fd/fc/fdc values from the cluster
#while read sub
#do	singularity exec ${mx} mrstats ${POP_DIR}/fd_smooth/$sub -output mean -mask  ${POP_DIR}/rs_clusters/fd_smooth_age_sex_educ_site_race_etiv_vo2_fwepval_t1_mask.mif
#done < ${POP_DIR_NS}/subj.txt
#while read sub
#do	singularity exec ${mx} mrstats ${POP_DIR}/fd_smooth/$sub -output mean -mask  ${POP_DIR}/rs_clusters/fd_smooth_age_sex_educ_site_race_etiv_vo2_fwepval_t1_mask.mif
#done < ${POP_DIR_NS}/subj.txt
