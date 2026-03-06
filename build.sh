#!/bin/bash
set -e

# ---------------------------------------------------------------------------
# build.sh
#
# Usage:
#   ./build.sh                           # All generic CV variants + example cover letter
#   ./build.sh --job autonomo            # Single CV (type from job_details) + cover letter
#   ./build.sh --job autonomo --cv mech  # Force a specific CV type + cover letter
#
# When --job is specified, the jobtype is read from job_details.tex and only
# that one CV variant is built alongside the cover letter.
# Generic builds (no --job) build all five CV variants + example cover letter.
# ---------------------------------------------------------------------------

JOB_FOLDER=""
SPECIFIC_CV=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --job) JOB_FOLDER="$2"; shift 2 ;;
    --cv)  SPECIFIC_CV="$2"; shift 2 ;;
    *)
      echo "Unknown argument: $1"
      echo "Usage: ./build.sh [--job <folder>] [--cv <type>]"
      exit 1
      ;;
  esac
done

ALL_JOB_TYPES=("mech" "electrical" "embedded" "software" "mechatronics")

# Determine cover letter folder
if [ -n "$JOB_FOLDER" ]; then
  CL_FOLDER="CoverLetter/$JOB_FOLDER"
  if [ ! -d "$CL_FOLDER" ]; then
    echo "Error: Cover letter folder '$CL_FOLDER' does not exist."
    exit 1
  fi
  echo "--- Using job folder: $JOB_FOLDER ---"
else
  CL_FOLDER="CoverLetter/example"
  echo "--- No job specified, using example cover letter ---"
fi

DETAILS_FILE="$CL_FOLDER/job_details.tex"
if [ ! -f "$DETAILS_FILE" ]; then
  echo "Error: job_details.tex not found in $CL_FOLDER"
  exit 1
fi

# Determine which CV type(s) to build
if [ -n "$SPECIFIC_CV" ]; then
  # Explicit --cv flag always wins
  CV_TYPES=("$SPECIFIC_CV")
elif [ -n "$JOB_FOLDER" ]; then
  # Job-specific build: extract jobtype from job_details.tex
  JOB_JOBTYPE=$(python3 -c "
import re
text = open('$DETAILS_FILE').read()
m = re.search(r'\\\\def\\\\jobtype\{([^}]+)\}', text)
print(m.group(1).strip() if m else '')
")
  if [ -n "$JOB_JOBTYPE" ]; then
    echo "--- CV type from job_details: $JOB_JOBTYPE ---"
    CV_TYPES=("$JOB_JOBTYPE")
  else
    echo "--- No jobtype in job_details, building all variants ---"
    CV_TYPES=("${ALL_JOB_TYPES[@]}")
  fi
else
  # Generic build: all variants
  CV_TYPES=("${ALL_JOB_TYPES[@]}")
fi

mkdir -p builds

# ---------------------------------------------------------------------------
# 1. Build CV variant(s)
# ---------------------------------------------------------------------------
for JOB in "${CV_TYPES[@]}"; do
  echo "--- Building CV: $JOB ---"

  # Name job-specific CVs with the company name to avoid overwriting generic builds
  if [ -n "$JOB_FOLDER" ]; then
    CV_JOBNAME="Jacob_Church_CV_${JOB}_${JOB_FOLDER}"
  else
    CV_JOBNAME="Jacob_Church_CV_${JOB}"
  fi

  xelatex -8bit -halt-on-error \
    -jobname="$CV_JOBNAME" \
    -output-directory=builds \
    "\\def\\jobtype{$JOB}\\def\\clfolder{$CL_FOLDER} \\input{CV.tex}"

  if [ "$JOB" == "mechatronics" ] && [ -z "$JOB_FOLDER" ]; then
    pdftoppm -png -singlefile \
      "builds/${CV_JOBNAME}.pdf" \
      "builds/Jacob_Church_CV_Preview"
  fi
done

# ---------------------------------------------------------------------------
# 2. Extract company name for output filename
# ---------------------------------------------------------------------------
COMPANY_NAME=$(python3 -c "
import re
text = open('$DETAILS_FILE').read()
m = re.search(r'\\\\newcommand\{\\\\companyName\}\{([^}]+)\}', text)
print(re.sub(r'[^a-zA-Z0-9]', '', m.group(1)) if m else 'Template')
")
[ -z "$COMPANY_NAME" ] && COMPANY_NAME="Template"

# ---------------------------------------------------------------------------
# 3. Build cover letter
# ---------------------------------------------------------------------------
echo "--- Building Cover Letter for: $COMPANY_NAME ---"
xelatex -8bit -halt-on-error \
  -jobname="Jacob_Church_Cover_Letter_$COMPANY_NAME" \
  -output-directory=builds \
  "\\def\\clfolder{$CL_FOLDER} \\input{CL.tex}"

# ---------------------------------------------------------------------------
# 4. Clean up auxiliary files, preserve PDFs and preview PNG
# ---------------------------------------------------------------------------
find builds -type f ! -name '*.pdf' ! -name '*.png' -delete

echo ""
echo "Done. Files in /builds:"
ls builds/
