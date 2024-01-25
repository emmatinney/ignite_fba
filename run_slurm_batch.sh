#run one script per subj
# Read subjects from subj.txt into an array 
subjects=($(cat subj.txt))
# Loop through the subjects
for i in "${subjects[@]}"; do
    # Copy mrtrixpp.sh to a new file with subject-specific name
  cp extract_values.sh "extract_values_${i}.sh"
    # Use sed to replace "REPLACE" with the current subject
  sed -i "s/REPLACE/${i}/g" "extract_values_${i}.sh"
done
subj=$(cat subj.txt); for i in $subj; do sbatch extract_values_${i}.sh; done

