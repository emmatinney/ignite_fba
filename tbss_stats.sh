#!/bin/bash
#SBATCH --partition=short
#SBATCH --time=24:0:0
#SBATCH -N 1
#SBATCH -n 24
#SBATCH --mem=100g
#SBATCH --job-name=tbss
#SBATCH --mail-user=tinney.e@northeastern.edu
#TBSS

#load fsl
module unload fsl
module load fsl/6.0.6.2 
unset LD_LIBRARY_PATH


cd /work/cbhlab/ignite/IGNITE/tbss/mytbss/stats


#randomise -i all_MD_skeletonised -o tbss -m mean_FA_skeleton_mask -d design.txt -t design.con -n 500 --T2
#mv tbss_tstat1.nii.gz MD_tbss_tstat1.nii.gz
#mv tbss_tstat2.nii.gz MD_tbss_tstat2.nii.gz
#mv tbss_tfce_corrp_tstat1.nii.gz MD_tbss_tfce_corrp_tstat1.nii.gz
#mv tbss_tfce_corrp_tstat2.nii.gz MD_tbss_tfce_corrp_tstat2.nii.gz


#randomise -i all_RD_skeletonised -o tbss -m mean_FA_skeleton_mask -d design.txt -t design.con -n 500 --T2
#mv tbss_tstat1.nii.gz RD_tbss_tstat1.nii.gz
#mv tbss_tstat2.nii.gz RD_tbss_tstat2.nii.gz
#mv tbss_tfce_corrp_tstat1.nii.gz RD_tbss_tfce_corrp_tstat1.nii.gz
#mv tbss_tfce_corrp_tstat2.nii.gz RD_tbss_tfce_corrp_tstat2.nii.gz
#threshold tbss_tfce_corrp_tstat1.nii.gz at .95 in fsleyes

#cd stats
#extract mean values from significant clusters:
fslmaths RD_tbss_tfce_corrp_tstat1.nii.gz -thrp .95 RD_thrp_stat1.nii.gz
fslmaths RD_thrp_stat1.nii.gz -mas all_RD_skeletonised.nii.gz RD_stat1_masked_4D
fslmeants -i all_RD_skeletonised.nii.gz -m RD_stat1_masked_4D.nii.gz -o RD_meants_roi1.txt
fslmaths MD_thrp_stat1.nii.gz -mas all_MD_skeletonised.nii.gz MD_stat1_masked_4D
fslmeants -i all_MD_skeletonised.nii.gz -m MD_stat1_masked_4D.nii.gz -o MD_meants_roi1.txt
