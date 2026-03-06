# Jacob Church — CV

[![Generate PDF](https://github.com/Jank-Jacob/CV/actions/workflows/deploy.yml/badge.svg)](https://github.com/Jank-Jacob/CV/actions/workflows/deploy.yml)

A LaTeX-based CV and cover letter system with role-specific variants, per-job customisation, and automated builds via GitHub Actions.

Built on [Awesome-CV](https://github.com/posquit0/Awesome-CV), forked from [JosiahBull/resume](https://github.com/JosiahBull/resume) with modifications for tighter layout and a modular build system.

---

## Latest CV

View or download the latest generic (mechatronics) variant:

[![CV Preview](https://github.com/Jank-Jacob/CV/releases/download/latest/Jacob_Church_CV_Preview.png)](https://github.com/Jank-Jacob/CV/releases/download/latest/Jacob_Church_CV_mechatronics.pdf)

---

## CV Variants

Five role-focused variants are built automatically on every push to `main`. Each variant shows and hides content based on the target discipline:

| Variant | Focus |
|---|---|
| `mechatronics` | All content shown — full cross-domain view |
| `mech` | Mechanical design, CAD, fabrication, HALT |
| `electrical` | PCB, Altium, embedded hardware |
| `embedded` | Firmware, microcontrollers, Linux drivers |
| `software` | Linux systems, ROS2, CI/CD, C++/Python |

---

## Project Structure

```
.
├── CV.tex                        # Main CV document
├── CL.tex                        # Cover letter document
├── shared_configs.tex            # Identity, toggles, helpers — shared by CV and CL
├── build.sh                      # Build script (see usage below)
├── Dockerfile                    # TeX Live build environment
│
├── CV/
│   ├── personal_statement.tex
│   ├── skills.tex
│   ├── achievements.tex
│   ├── education.tex
│   ├── experience.tex            # Orchestrator — loads from experience/
│   ├── experience/
│   │   ├── clutterbot.tex
│   │   ├── frasergear.tex
│   │   ├── sixthsense.tex
│   │   └── vexreferee.tex
│   ├── projects.tex              # Orchestrator — loads from projects/
│   └── projects/
│       ├── vex.tex
│       ├── fsae.tex
│       ├── cnc.tex
│       └── intake.tex
│
└── CoverLetter/
    ├── example/                  # Generic template — committed to repo, built by CI
    │   ├── job_details.tex
    │   ├── opening.tex
    │   ├── evidence.tex
    │   └── closing.tex
    └── <company>/                # Per-application folder — gitignored, built locally
        ├── job_details.tex
        ├── opening.tex
        ├── evidence.tex
        └── closing.tex
```

---

## Build Script Usage

```bash
# Build all five generic CV variants + example cover letter
./build.sh

# Build CV (type from job_details) + cover letter for a specific job
./build.sh --job rocketlab

# Force a specific CV type for a job build
./build.sh --job rocketlab --cv mechatronics
```

Output files are written to `builds/`. Job-specific CV output is named to include the company, e.g. `Jacob_Church_CV_mech_Autonomo.pdf`.

---

## Per-Job Customisation

Create a folder under `CoverLetter/<companyname>/` with a `job_details.tex` and the three letter content files. The `job_details.tex` file controls:

```latex
% Which CV variant to build
\def\jobtype{mech}

% Optional CV overrides
\def\regionoverride{au}           % Adds AU working rights line below header
\def\inventorfirst{1}             % Lists Inventor before SolidWorks in skills
\def\addressoverride{Papamoa, Tauranga}   % Replaces address in header

% Reorder sections (omit an entry to hide it entirely)
\def\projectorder{fsae,vex,cnc,intake}
\def\experienceorder{clutterbot,frasergear,sixthsense,vexreferee}

% Cover letter header fields
\newcommand{\companyName}{Acme Corp}
\newcommand{\jobTitle}{Mechanical Engineer}
\newcommand{\companyAddress}{123 Example St \\ Perth WA 6000}
```

These folders are gitignored — they contain private application details and are never committed or built by CI.

---

## Local Build (Docker)

```bash
# Build the Docker image
docker build -t cv-builder .

# Run a generic build
docker run --rm -v $(pwd):/workspace cv-builder

# Run a job-specific build
docker run --rm -v $(pwd):/workspace cv-builder ./build.sh --job autonomo
```

---

## CI/CD

GitHub Actions runs on every push and pull request to `main`:

1. Builds and pushes the Docker image to GHCR
2. Runs `./build.sh` (generic variants + example cover letter)
3. Uploads PDFs as workflow artifacts
4. On push to `main`: creates/updates a `latest` release with all PDFs and the preview PNG

Private job folders are gitignored and are never present in CI — only the generic variants and example cover letter are built automatically.

---

## Dependencies

Built inside the Docker container — no local TeX installation required.

- [TeX Live](https://hub.docker.com/r/texlive/texlive) (full)
- XeLaTeX
- `poppler-utils` (for `pdftoppm` preview generation)
- Python 3 (for company name extraction in `build.sh`)
