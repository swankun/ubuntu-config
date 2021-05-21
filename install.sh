#!/bin/bash

ROOTDIR=$PWD
BASHRCFILE=$HOME/.bashrc

function update {
    sudo apt update
    sudo apt upgrade
}

# Essentials
function install_essentials {
    sudo apt install -y terminator screen vim htop git zathura zathura-djvu
    sudo apt install -y openssh-server net-tools openconnect
    sudo apt install -y build-essential libatomic1 gfortran perl wget m4 cmake pkg-config curl python3-venv
    sudo apt install -y libgl1-mesa-glx libegl1-mesa libxcb-xtest0  # zoom
    sudo apt install -y apt-transport-https ca-certificates gnupg lsb-release  # docker and code
}

# VS Code
function install_vscode {
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt update
    sudo apt install -y code
    code --install-extension ms-vscode.cpptools
    code --install-extension ms-vscode-remote.remote-ssh
    code --install-extension ms-python.python
    code --install-extension vscode-icons-team.vscode-icons
    code --install-extension dracula-theme.theme-dracula
    code --install-extension stkb.rewrap
    rm packages.microsoft.gpg
}

# Docker
function install_docker {
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
}

# LaTeX
function install_latex {
    sudo apt install -y texlive-full
    code --install-extension james-yu.latex-workshop
    code --install-extension ban.spellright
    ln -s /usr/share/hunspell/* $HOME/.config/Code/Dictionaries
}

# BSU VPN
function configure_bsuvpn {
    cp -r $ROOTDIR/bsuvpn/ $HOME/.config/
    cp -r $ROOTDIR/scripts/ $HOME/.config/scripts
    echo "" >> $BASHRCFILE
    echo "# Load VPN scripts" >> $BASHRCFILE
    echo 'export PATH=$PATH:$HOME/.config/scripts' >> $BASHRCFILE
    source $BASHRCFILE
}

# Julia
function install_julia {
    mkdir -p $HOME/.local/src/julia && cd $HOME/.local/src/julia
    git clone https://github.com/JuliaLang/julia.git
    mv julia/ v1.6.0/ && cd v1.6.0/
    git checkout v1.6.0
    make -j$(nproc)
    cd /usr/local/bin
    sudo ln -s $HOME/.local/src/julia/v1.6.0/usr/bin/julia julia
    cd $ROOTDIR
    code --install-extension julialang.language-julia
}

# Microcontroller programming
function install_platformio {
    code --install-extension platformio.platformio-ide
    sudo usermod -aG dialout $USER
    cd $HOME/.local/src/
    sudo apt install -y qtbase5-dev libqt5serialport5-dev libqwt-qt5-dev libqt5svg5 libqt5svg5-dev mercurial 
    hg clone https://hg.sr.ht/~hyozd/serialplot
    cd serialplot
    mkdir build && cd build
    cmake -DBUILD_QWT=false ..
    make
    sudo make install/local
    cd $ROOTDIR
}

# Install Singularity
function install_singularity {
    export SINGULARITY_VERSION=3.7.0 GO_VERSION=1.16.4 OS=linux ARCH=amd64
    cd /tmp
    wget https://dl.google.com/go/go$GO_VERSION.$OS-$ARCH.tar.gz
    sudo tar -C /usr/local -xzvf go$GO_VERSION.$OS-$ARCH.tar.gz
    rm go$GO_VERSION.$OS-$ARCH.tar.gz
    echo 'export PATH=/usr/local/go/bin:$PATH' >> $BASHRCFILE
    source $BASHRCFILE

    sudo apt install -y build-essential libssl-dev uuid-dev libgpgme11-dev squashfs-tools libseccomp-dev wget pkg-config git cryptsetup
    cd $HOME/.local/src
    wget https://github.com/hpcng/singularity/releases/download/v${SINGULARITY_VERSION}/singularity-${SINGULARITY_VERSION}.tar.gz 
    tar -xzf singularity-${SINGULARITY_VERSION}.tar.gz
    rm singularity-${SINGULARITY_VERSION}.tar.gz
    cd singularity
    ./mconfig
    make -C builddir
    sudo make -C builddir install
}
