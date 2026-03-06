#!/bin/bash
set -e

JOB_TYPES=("mech" "electrical" "embedded" "software" "mechatronics")
mkdir -p builds

# 1. Build CV Variants
for JOB in "${JOB_TYPES[@]}"; do
  echo "--- Building CV: $JOB ---"
  xelatex -8bit -halt-on-error \
    -jobname="Jacob_Church_CV_$JOB" \
    -output-directory=builds \
    "\\def\\jobtype{$JOB} \\input{CV.tex}"

  if [ "$JOB" == "mechatronics" ]; then
    pdftoppm -png -singlefile \
      "builds/Jacob_Church_CV_$JOB.pdf" \
      "builds/Jacob_Church_CV_Preview"
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

# 3. Extract company name for output filename (robust Python method)
COMPANY_NAME=$(python3 -c "
import re, sys
text = open('$DETAILS_FILE').read()
m = re.search(r'\\\\newcommand\{\\\\companyName\}\{([^}]+)\}', text)
print(re.sub(r'[^a-zA-Z0-9]', '', m.group(1)) if m else 'Template')
")
[ -z "$COMPANY_NAME" ] && COMPANY_NAME="Template"

echo "--- Building Cover Letter for: $COMPANY_NAME ---"
xelatex -8bit -halt-on-error \
  -jobname="Jacob_Church_Cover_Letter_$COMPANY_NAME" \
  -output-directory=builds \
  "\\input{CL.tex}"

# 4. Clean up auxiliary files, preserve PDFs and preview PNG
find builds -type f ! -name '*.pdf' ! -name '*.png' -delete

echo "Done. Files in /builds:"
ls builds/