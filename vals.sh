#!/bin/bash

#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=32000
#SBATCH --job-name=vals
#SBATCH --partition=short
# Assuming subj.txt contains a list of SUBJID names in /work/cbhlab/ignite/IGNITE/
SUBJID_FILE="/work/cbhlab/ignite/IGNITE/subj.txt"

# Read SUBJID names from subj.txt into an array
mapfile -t SUBJIDS < "${SUBJID_FILE}"

# Loop through each SUBJID
for SUBJID in "${SUBJIDS[@]}"; do
    # Check if the mean_values directory exists for the current SUBJID
    if [ -d "/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/${SUBJID}_MR1/mean_values" ]; then
        # Navigate to the mean_values directory for the current SUBJID
        cd "/work/cbhlab/ignite/IGNITE/dwi_preprocessed_data/${SUBJID}_MR1/mean_values" || continue

        # Combine files with headers using filenames from subj.txt
        paste_cmd="paste -d'\t'"
        
        # Read variable names from subj.txt into an array
        mapfile -t tracts < "/work/cbhlab/ignite/IGNITE/POP_larger/tractseg/ForEmma/tracts.txt"

        for filename in "${tracts[@]}"; do
            files=( "mean_AD_${filename}.txt" "mean_MD_${filename}.txt" "mean_FA_${filename}.txt" "mean_RD_${filename}.txt" )
            for ((i=0; i<"${#files[@]}"; i++)); do
                paste_cmd+=" <(echo '${filename}' ; cat '${files[$i]}')"
            done
        done

        # Execute the combined paste command
        eval "$paste_cmd" > "${SUBJID}_combined_meanvals.txt"

        # Return to the initial directory
        cd - || exit
    else
        echo "mean_values directory not found for ${SUBJID}"
    fi
done
