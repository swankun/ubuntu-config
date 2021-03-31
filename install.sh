#!/bin/bash

ROOTDIR=$PWD
BASHRCFILE=$HOME/.bashrc

sudo apt update
sudo apt upgrade

# Essentials
sudo apt install build-essential libatomic1 gfortran perl wget m4 cmake pkg-config curl python3-venv
sudo apt install vim htop git zathura zathura-djvu openssh-server net-tools openconnect
sudo apt install libgl1-mesa-glx libegl1-mesa libxcb-xtest0  # zoom
sudo apt install apt-transport-https ca-certificates gnupg lsb-release  # docker and code

# VS Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install code
code --install-extension ms-vscode.cpptools
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension ms-python.python
code --install-extension vscode-icons-team.vscode-icons
code --install-extension dracula-theme.theme-dracula
code --install-extension stkb.rewrap

# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

# LaTeX
sudo apt install texlive-full
code --install-extension james-yu.latex-workshop
code --install-extension ban.spellright
ln -s /usr/share/hunspell/* $HOME/.config/Code/Dictionaries

# BSU VPN
cp -r $ROOTDIR/bsuvpn/ $HOME/.config/
cp -r $ROOTDIR/scripts/ $HOME/.config/scripts
echo "" >> $BASHRCFILE
echo "# Load VPN scripts" >> $BASHRCFILE
echo 'export PATH=$PATH:$HOME/.config/scripts' >> $BASHRCFILE

# Julia
mkdir -p $HOME/.local/src/julia && cd $HOME/.local/src/julia
git clone https://github.com/JuliaLang/julia.git
mv julia/ v1.6.0/ && cd v1.6.0/
git checkout v1.6.0
make -j2
cd /usr/local/bin
sudo ln -s $HOME/.local/src/julia/v1.6.0/usr/bin/julia julia
cd $ROOTDIR
code --install-extension julialang.language-julia

# Microcontroller programming
code --install-extension platformio.platformio-ide
sudo usermod -aG dialout $USER
cd $HOME/.local/src/
sudo apt install qtbase5-dev libqt5serialport5-dev libqwt-qt5-dev libqt5svg5 libqt5svg5-dev mercurial 
hg clone https://hg.sr.ht/~hyozd/serialplot
cd serialplot
mkdir build && cd build
cmake -DBUILD_QWT=false ..
make
make install/local
cd $ROOTDIR
