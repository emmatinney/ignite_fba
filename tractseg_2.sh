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
	
	tracts=$(cat ${POP_DIR_NS}/tractseg/ForEmma/tracts.txt)
#for i in $tracts; do singularity exec --nv ${mx} tck2fixel ${POP_DIR}/tractseg/ForEmma/tractseg_output/TOM_trackings_native/${i}.tck ${POP_DIR}/fdc_smooth_stats_vo2 ${POP_DIR}/fdc_smooth_stats_vo2/tractseg ${i}_fixel.mif; done 
for i in $tracts; do singularity exec --nv ${mx} tck2fixel ${POP_DIR}/tractseg/ForEmma/tractseg_output/TOM_trackings_native/${i}.tck ${POP_DIR}/log_fc_smooth_stats_vo2 ${POP_DIR}/log_fc_smooth_stats_vo2/tractseg ${i}_fixel.mif; done 
#for i in $tracts; do singularity exec --nv ${mx} tck2fixel ${POP_DIR}/tractseg/ForEmma/tractseg_output/TOM_trackings_native/${i}.tck ${POP_DIR}/fd_smooth_stats_vo2 ${POP_DIR}/fd_smooth_stats_vo2/tractseg ${i}_fixel.mif; done

#for i in $tracts; do singularity exec --nv ${mx} mrthreshold -abs 1 ${POP_DIR}/fdc_smooth_stats_vo2/tractseg/${i}_fixel.mif ${POP_DIR}/fdc_smooth_stats_vo2/tractseg/${i}_fixel_abs1thresh.mif; done 
for i in $tracts; do singularity exec --nv ${mx} mrthreshold -abs 1 ${POP_DIR}/log_fc_smooth_stats_vo2/tractseg/${i}_fixel.mif ${POP_DIR}/log_fc_smooth_stats_vo2/tractseg/${i}_fixel_abs1thresh.mif; done 
#for i in $tracts; do singularity exec --nv ${mx} mrthreshold -abs 1 ${POP_DIR}/fd_smooth_stats_vo2/tractseg/${i}_fixel.mif ${POP_DIR}/fd_smooth_stats_vo2/tractseg/${i}_fixel_abs1thresh.mif; done 

#singularity exec --nv ${mx} mrthreshold ${POP_DIR}/fdc_smooth_stats_vo2/fwe_1mpvalue_t1.mif -abs 0.95 ${POP_DIR}/fdc_smooth_stats_vo2/fwe_1mpvalue_t1_p05.mif
singularity exec --nv ${mx} mrthreshold ${POP_DIR}/log_fc_smooth_stats_vo2/fwe_1mpvalue_t2.mif -abs 0.95 ${POP_DIR}/log_fc_smooth_stats_vo2/fwe_1mpvalue_t2_p05.mif
#singularity exec --nv ${mx} mrthreshold ${POP_DIR}/fd_smooth_stats_vo2/fwe_1mpvalue_t1.mif -abs 0.95 ${POP_DIR}/fd_smooth_stats_vo2/fwe_1mpvalue_t1_p05.mif

#for i in $tracts; do singularity exec --nv ${mx} mrcalc ${POP_DIR}/fdc_smooth_stats_vo2/tractseg/${i}_fixel_abs1thresh.mif ${POP_DIR}/fdc_smooth_stats_vo2/fwe_1mpvalue_t1_p05.mif -multi ${POP_DIR}/fdc_smooth_stats_vo2/tractseg/${i}_fixel_abs1thresh_intersect.mif; done
for i in $tracts; do singularity exec --nv ${mx} mrcalc ${POP_DIR}/log_fc_smooth_stats_vo2/tractseg/${i}_fixel_abs1thresh.mif ${POP_DIR}/log_fc_smooth_stats_vo2/fwe_1mpvalue_t2_p05.mif -multi ${POP_DIR}/log_fc_smooth_stats_vo2/tractseg/${i}_fixel_abs2thresh_intersect.mif; done
#for i in $tracts; do singularity exec --nv ${mx} mrcalc ${POP_DIR}/fd_smooth_stats_vo2/tractseg/${i}_fixel_abs1thresh.mif ${POP_DIR}/fd_smooth_stats_vo2/fwe_1mpvalue_t1_p05.mif -multi ${POP_DIR}/fd_smooth_stats_vo2/tractseg/${i}_fixel_abs1thresh_intersect.mif; done

#for i in $tracts; do
 #   count=$(singularity exec --nv ${mx} mrstats ${POP_DIR}/fdc_smooth_stats_vo2/tractseg/${i}_fixel_abs1thresh_intersect.mif \
   #     -mask ${POP_DIR}/fdc_smooth_stats_vo2/tractseg/${i}_fixel_abs1thresh_intersect.mif \
  #      | awk 'FNR==2 {print $9}')
  #  echo ${i} ${count} >> ${POP_DIR_NS}/fdc_smooth_stats_vo2/tractseg/all_tracts_count_sig_fixels.txt
#done
for i in $tracts; do
    count=$(singularity exec --nv ${mx} mrstats ${POP_DIR}/log_fc_smooth_stats_vo2/tractseg/${i}_fixel_abs2thresh_intersect.mif \
        -mask ${POP_DIR}/log_fc_smooth_stats_vo2/tractseg/${i}_fixel_abs2thresh_intersect.mif \
        | awk 'FNR==2 {print $9}')
    echo ${i} ${count} >> ${POP_DIR_NS}/log_fc_smooth_stats_vo2/tractseg/all_tracts_count_sig_fixels_t2.txt
done
#for i in $tracts; do
#    count=$(singularity exec --nv ${mx} mrstats ${POP_DIR}/fd_smooth_stats_vo2/tractseg/${i}_fixel_abs1thresh_intersect.mif \
#        -mask ${POP_DIR}/fd_smooth_stats_vo2/tractseg/${i}_fixel_abs1thresh_intersect.mif \
#        | awk 'FNR==2 {print $9}')
#    echo ${i} ${count} >> ${POP_DIR_NS}/fd_smooth_stats_vo2/tractseg/all_tracts_count_sig_fixels.txt
#done

#for i in $sig_tracts; do fixel2tsf ${POP_DIR}/fdc_smooth_stats_vo2/tractseg/${i}_fixel_abs1thresh_intersect.mif ${POP_DIR}/fd_smooth_stats_vo2/tractseg/ForEmma/tractseg_output/${i}.tck ${POP_DIR}/fdc_smooth_stats_vo2/tractseg/${i}_fixel_abs1thresh_intersect.tsf; done

for i in $tracts; do singularity exec ${mx} tckedit -mask ${POP_DIR}/template_wm_fod_grouprf_norm_mask.mif ${POP_DIR}/tractseg/ForEmma/tractseg_output/TOM_trackings_native/${i}.tck ${POP_DIR}/tractseg/ForEmma/tractseg_output/masks/${i}_mask.tck; done 


