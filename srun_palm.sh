#!/bin/bash
#SBATCH --time=24:0:0
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --job-name=palm
#SBATCH --partition=short
module load matlab/R2021a

cd /work/cbhlab/ignite/palm-alpha119
srun matlab -nodisplay -singleCompThread -r "palm -i /work/cbhlab/ignite/IGNITE/tbss/mytbss/stats/RD.nii -d /work/cbhlab/ignite/IGNITE/tbss/mytbss/stats/design.mat -t /work/cbhlab/ignite/IGNITE/tbss/mytbss/stats/design.con -n 1000 -pearson -T -corrcon -fdr -logp -o /work/cbhlab/ignite/IGNITE/tbss/mytbss/stats/RD"