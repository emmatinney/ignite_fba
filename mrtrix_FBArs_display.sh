#!/bin/sh
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=32000
#SBATCH --job-name=FBA_rs_display
#SBATCH --partition=short
       
	module load singularity
     export SINGULARITYENV_LD_LIBRARY_PATH="/shared/centos7/cuda/9.1/lib64"
	unset LD_LIBRARY_PATH
	export SINGULARITY_BIND="/work/cbhlab/ignite/IGNITE:/mnt,/shared/centos7"        
    POP_DIR=/mnt/POP_larger
	POP_DIR_NS=/work/cbhlab/ignite/IGNITE/POP_larger
     mx=/shared/container_repository/MRtrix/mrtrix3_3.0.4.sif

# create low resoultion tractogram as the template for your fiber results
 singularity exec ${mx} tckedit ${POP_DIR}/TK_2M_sift.tck -num 200000 ${POP_DIR}/TK_200k_sift.tck

# map fixel values to streamline points and save in track scalar file
# overlay your P value file to the track file
#singularity exec ${mx} fixel2tsf ${POP_DIR}/fd_smooth_stats_vo2/fwe_1mpvalue_t2.mif ${POP_DIR}/TK_200k_sift.tck ${POP_DIR}/rs_clusters/fd_smooth_age_sex_educ_site_race_etiv_vo2_fwepval_t2.tsf
# overlay your effect size file to the track file
#singularity exec ${mx} fixel2tsf ${POP_DIR}/fd_smooth_stats_vo2/abs_effect_t2.mif ${POP_DIR}/TK_200k_sift.tck ${POP_DIR}/rs_clusters/fd_smooth_age_sex_educ_site_race_etiv_vo2_abs_effect_t2.tsf

#singularity exec ${mx} fixel2tsf ${POP_DIR}/fdc_smooth_stats_vo2/fwe_1mpvalue_t2.mif ${POP_DIR}/TK_200k_sift.tck ${POP_DIR}/rs_clusters/fdc_smooth_age_sex_educ_site_race_etiv_vo2_fwepval_t2.tsf -force
#singularity exec ${mx} fixel2tsf ${POP_DIR}/fdc_smooth_stats_vo2/fwe_1mpvalue_t1.mif ${POP_DIR}/TK_200k_sift.tck ${POP_DIR}/rs_clusters/fdc_smooth_age_sex_educ_site_race_etiv_vo2_fwepval_t1.tsf -force

#singularity exec ${mx} fixel2tsf ${POP_DIR}/fdc_smooth_stats_vo2/abs_effect_t2.mif ${POP_DIR}/TK_200k_sift.tck ${POP_DIR}/rs_clusters/fdc_smooth_age_sex_educ_site_race_etiv_vo2_abs_effect_t2.tsf -force
#singularity exec ${mx} fixel2tsf ${POP_DIR}/fdc_smooth_stats_vo2/abs_effect_t1.mif ${POP_DIR}/TK_200k_sift.tck ${POP_DIR}/rs_clusters/fdc_smooth_age_sex_educ_site_race_etiv_vo2_abs_effect_t1.tsf -force

#singularity exec ${mx} fixel2tsf ${POP_DIR}/log_fc_smooth_stats_vo2/fwe_1mpvalue_t2.mif ${POP_DIR}/TK_200k_sift.tck ${POP_DIR}/rs_clusters/fclog_smooth_age_sex_educ_site_race_etiv_vo2_fwepval_t2.tsf -force
#singularity exec ${mx} fixel2tsf ${POP_DIR}/log_fc_smooth_stats_vo2/fwe_1mpvalue_t1.mif ${POP_DIR}/TK_200k_sift.tck ${POP_DIR}/rs_clusters/fclog_smooth_age_sex_educ_site_race_etiv_vo2_fwepval_t1.tsf -force

#singularity exec ${mx} fixel2tsf ${POP_DIR}/log_fc_smooth_stats_vo2/abs_effect_t2.mif ${POP_DIR}/TK_200k_sift.tck ${POP_DIR}/rs_clusters/fclog_smooth_age_sex_educ_site_race_etiv_vo2_abs_effect_t2.tsf -force
#singularity exec ${mx} fixel2tsf ${POP_DIR}/log_fc_smooth_stats_vo2/abs_effect_t1.mif ${POP_DIR}/TK_200k_sift.tck ${POP_DIR}/rs_clusters/fclog_smooth_age_sex_educ_site_race_etiv_vo2_abs_effect_t1.tsf -force

singularity exec ${mx} fixel2tsf ${POP_DIR}/fd_smooth_stats_vo2/fwe_1mpvalue_t1.mif ${POP_DIR}/TK_200k_sift.tck ${POP_DIR}/rs_clusters/fd_smooth_age_sex_educ_site_race_etiv_vo2_fwepval_t1.tsf -force

singularity exec ${mx} fixel2tsf ${POP_DIR}/fd_smooth_stats_vo2/abs_effect_t1.mif ${POP_DIR}/TK_200k_sift.tck ${POP_DIR}/rs_clusters/fd_smooth_age_sex_educ_site_race_etiv_vo2_abs_effect_t1.tsf -force


