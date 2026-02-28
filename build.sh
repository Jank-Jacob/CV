#!/bin/bash

# Array of job types defined in your CV.tex
JOB_TYPES=("mech" "electrical" "embedded" "software" "mechatronics")

# Create a build directory if it doesn't exist
mkdir -p builds

for JOB in "${JOB_TYPES[@]}"; do
    echo "-------------------------------------------------------"
    echo "Building CV for: $JOB"
    echo "-------------------------------------------------------"
    
    # Run xelatex with the jobtype defined
    # We use -jobname so the output files are named uniquely
    xelatex -8bit -halt-on-error -jobname="Jacob_Church_CV_$JOB" "\def\jobtype{$JOB} \input{CV.tex}"
    
    # Move the results to the builds folder
    mv "Jacob_Church_CV_$JOB.pdf" builds/
    
    # Optional: Generate PNG preview for the main version or all versions
    if [ "$JOB" == "mechatronics" ]; then
        pdftoppm -png -singlefile "builds/Jacob_Church_CV_$JOB.pdf" "Jacob_Church_CV_Preview"
    fi
done

echo "Build Complete. Files are in the /builds directory."