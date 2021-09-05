#!/bin/bash

ROOTDIR=$PWD
BASHRCFILE=$HOME/.bashrc

function update {
    sudo apt update
    sudo apt -y upgrade
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

# LaTeX
function install_latex {
    sudo apt install -y texlive-full
    code --install-extension james-yu.latex-workshop
    code --install-extension valentjn.vscode-ltex
}

# BSU VPN
function configure_bsuvpn {
    cp -r $ROOTDIR/bsuvpn/ $HOME/.config/
    cp -r $ROOTDIR/scripts/ $HOME/.local/bin
    echo "" >> $BASHRCFILE
    echo "# Load local executables" >> $BASHRCFILE
    echo 'export PATH=$PATH:$HOME/.local/bin' >> $BASHRCFILE
    source $BASHRCFILE
}

# Julia
function install_julia {
    build_path=$HOME/.local/src/julia
    install_path=/usr/local/bin
    julia_version=1.6.2

    mkdir -p $build_path && cd $build_path
    git clone https://github.com/JuliaLang/julia.git
    mv julia/ v$julia_version/ && cd v$julia_version/
    git checkout v$julia_version
    echo "MARCH=native" > Make.user
    make -j$(nproc)
    cd /usr/local/bin
    sudo ln -s "$HOME/.local/src/julia/v$julia_version/usr/bin/julia" julia
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
    export SINGULARITY_VERSION=3.8.0 GO_VERSION=1.16.7 OS=linux ARCH=amd64
    cd /tmp
    wget https://dl.google.com/go/go$GO_VERSION.$OS-$ARCH.tar.gz
    sudo tar -C /usr/local -xzvf go$GO_VERSION.$OS-$ARCH.tar.gz
    sudo ln -s /usr/local/go/bin/go /usr/bin/go
    rm go$GO_VERSION.$OS-$ARCH.tar.gz

    sudo apt install -y build-essential libssl-dev uuid-dev libgpgme11-dev squashfs-tools libseccomp-dev wget pkg-config git cryptsetup
    cd $HOME/.local/src
    git clone https://github.com/hpcng/singularity.git
    cd singularity
    git checkout v$SINGULARITY_VERSION
    bash mconfig
    make -C builddir
    sudo make -C builddir install
}

function install_wine {
    DISTRO=focal
    wget -q https://dl.winehq.org/wine-builds/winehq.key -O- | sudo apt-key add -
    sudo add-apt-repository "deb https://dl.winehq.org/wine-builds/ubuntu/ $DISTRO main"
    sudo apt update
    sudo apt install winehq-stable
    cd /tmp
    wget  https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
    chmod +x winetricks
    sudo mv winetricks /usr/bin
    wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks.bash-completion
    sudo mv winetricks.bash-completion /usr/share/bash-completion/completions/winetricks
    wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks.1
    sudo mv winetricks.1 /usr/share/man/man1/winetricks.1
}

#update
#install_essentials
#install_vscode
#install_latex
#configure_bsuvpn
#install_julia
#install_singularity

