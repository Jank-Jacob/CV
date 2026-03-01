#!/bin/bash
JOB_TYPES=("mech" "electrical" "embedded" "software" "mechatronics")
mkdir -p builds

# 1. Build CV Variants
for JOB in "${JOB_TYPES[@]}"; do
    echo "--- Building CV: $JOB ---"
    xelatex -8bit -halt-on-error -jobname="Jacob_Church_CV_$JOB" -output-directory=builds \
    "\\def\\jobtype{$JOB} \\input{CV.tex}"

    if [ "$JOB" == "mechatronics" ]; then
        pdftoppm -png -singlefile "builds/Jacob_Church_CV_$JOB.pdf" "Jacob_Church_CV_Preview"
    fi
done

# 2. Determine which Cover Letter details to use
if [ -f "CoverLetter/job_details.tex" ]; then
    DETAILS_FILE="CoverLetter/job_details.tex"
    echo "--- Found private job_details.tex ---"
else
    DETAILS_FILE="CoverLetter/job_details.example.tex"
    echo "--- Using job_details.example.tex for build ---"
fi

# 3. Build the Cover Letter
# We extract the company name from the .tex file to rename the PDF automatically
# This removes spaces and special characters for a clean filename
COMPANY_NAME=$(grep "companyName" "$DETAILS_FILE" | head -1 | cut -d '{' -f 3 | cut -d '}' -f 1 | tr -d ' ' | tr -dc '[:alnum:]')
[ -z "$COMPANY_NAME" ] && COMPANY_NAME="Template"

echo "--- Building Cover Letter for: $COMPANY_NAME ---"

xelatex -8bit -halt-on-error -jobname="Jacob_Church_Cover_Letter_$COMPANY_NAME" -output-directory=builds \
"\\input{CL.tex}"

# Clean up junk
find builds -type f ! -name '*.pdf' -delete
echo "Done. Files generated in /builds"
