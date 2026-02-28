#!/bin/bash

JOB_TYPES=("mech" "electrical" "embedded" "software" "mechatronics")

# Ensure builds directory exists
mkdir -p builds

for JOB in "${JOB_TYPES[@]}"; do
    echo "-------------------------------------------------------"
    echo "Building CV for: $JOB"
    echo "-------------------------------------------------------"
    
    xelatex -8bit -halt-on-error -jobname="Jacob_Church_CV_$JOB" -output-directory=builds \
    "\\def\\jobtype{$JOB} \\input{CV.tex}"
    
    # Generate PNG from the Mechatronics version specifically
    if [ "$JOB" == "mechatronics" ]; then
        pdftoppm -png -singlefile "builds/Jacob_Church_CV_$JOB.pdf" "Jacob_Church_CV_Preview"
    fi
done

# Clean up all auxiliary junk inside the builds folder
# This keeps only the PDFs
find builds -type f ! -name '*.pdf' -delete

echo "Done. All PDFs are in the /builds directory."