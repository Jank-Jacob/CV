FROM ghcr.io/Jank-Jacob/dotfiles:latest

# Install everything required to build the cv.
RUN sudo apt-get update && sudo apt-get install \
    -y \
    build-essential \
    texlive \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    poppler-utils \
    texlive-xetex \
    vim && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# Set the shell to zsh
RUN chsh -s /bin/zsh
SHELL ["/bin/zsh", "-c"]
