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

cd /work/cbhlab/ignite/IGNITE/tbss/mytbss
#TBSS_1_PREPROC
#erode FA images slightly and zero the end slices
#tbss_1_preproc *.nii.gz

#TBSS_2_REG
#nonlinear registration
#tbss_2_reg -T

#TBSS_3_POSTREG
#applies non linear transform to bring subjects into standard space.
#-S derive the mean FA and skeleton from the actual subjects you have. -T uses  FMRIB58_FA mean FA image and its derived skeleton. 
#tbss_3_postreg -S

#TBSS_4_PRESTATS
#threshold mean FA skeleton at a common threshold.
#tbss_4_prestats 0.2
#cd FA
#imglob *_FA.*
#cd stats
#design matrix setting one group first, then other. specify how many in each group
#contrast 1 gives x>y and contrast 2 gives y>x 
#design_ttest2 design 98 148
tbss_non_FA AD
cd /work/cbhlab/ignite/IGNITE/tbss/mytbss/stats
randomise -i all_AD_skeletonised -o tbss -m mean_AD_skeleton_mask -d design.txt -t design.con -n 500 --T2
mv tbss_tstat1.nii.gz AD_tbss_tstat1.nii.gz
mv tbss_tstat2.nii.gz AD_tbss_tstat2.nii.gz
mv tbss_tfce_corrp_tstat1.nii.gz AD_tbss_tfce_corrp_tstat1.nii.gz
mv tbss_tfce_corrp_tstat2.nii.gz AD_tbss_tfce_corrp_tstat2.nii.gz
cd /work/cbhlab/ignite/IGNITE/tbss/mytbss
tbss_non_FA MD
randomise -i all_MD_skeletonised -o tbss -m mean_MD_skeleton_mask -d design.txt -t design.con -n 500 --T2
mv tbss_tstat1.nii.gz MD_tbss_tstat1.nii.gz
mv tbss_tstat2.nii.gz MD_tbss_tstat2.nii.gz
mv tbss_tfce_corrp_tstat1.nii.gz MD_tbss_tfce_corrp_tstat1.nii.gz
mv tbss_tfce_corrp_tstat2.nii.gz MD_tbss_tfce_corrp_tstat2.nii.gz
cd /work/cbhlab/ignite/IGNITE/tbss/mytbss
tbss_non_FA RD

randomise -i all_RD_skeletonised -o tbss -m mean_RD_skeleton_mask -d design.txt -t design.con -n 500 --T2
mv tbss_tstat1.nii.gz RD_tbss_tstat1.nii.gz
mv tbss_tstat2.nii.gz RD_tbss_tstat2.nii.gz
mv tbss_tfce_corrp_tstat1.nii.gz RD_tbss_tfce_corrp_tstat1.nii.gz
mv tbss_tfce_corrp_tstat2.nii.gz RD_tbss_tfce_corrp_tstat2.nii.gz
#threshold tbss_tfce_corrp_tstat1.nii.gz at .95 in fsleyes

#cd stats
#extract mean values from significant clusters:
#fslmaths FA_tbss_tfce_corrp_tstat2.nii.gz -thrp .95 FA_thrp_stat2.nii.gz
#fslmaths FA_thrp_stat2.nii.gz -mas all_FA_skeletonised.nii.gz FA_stat2_masked_4D
#fslmeants -i all_FA_skeletonised.nii.gz -m FA_stat2_masked_4D.nii.gz -o FA_meants_roi2.txt
#fslmaths FA_tbss_tfce_corrp_tstat1.nii.gz -thrp .95 FA_thrp_stat1.nii.gz
#fslmaths FA_thrp_stat1.nii.gz -mas all_FA_skeletonised.nii.gz FA_stat1_masked_4D
#fslmeants -i all_FA_skeletonised.nii.gz -m FA_stat1_masked_4D.nii.gz -o FA_meants_roi1.txt
