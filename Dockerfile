# Official TeX Live image
FROM texlive/texlive:latest

RUN apt-get update && apt-get install -y \
    build-essential \
    poppler-utils \
    vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory for the build
WORKDIR /workspace

# Copy the CV source files into the container
COPY . .

# Ensure the build script has execution permissions
RUN chmod +x build.sh

# The build script runs xelatex for each variant
CMD ["./build.sh"]
