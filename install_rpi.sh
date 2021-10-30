#!/bin/bash

ROOTDIR=$PWD
BASHRCFILE=$HOME/.bashrc

function update {
    sudo apt update
    sudo apt -y upgrade
}

# Install Singularity
function install_singularity {
    export SINGULARITY_VERSION=3.8.0 GO_VERSION=1.16.7 OS=linux ARCH=arm64
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

function setup_wap {
    sudo apt install network-manager
    sudo bash -c "echo 'network: {config: disabled}' > /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg"
    sudo cat >/etc/netplan/10-hotspot-config.yaml << 'EOF'
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    eth0:
      dhcp4: true
      optional: true
  wifis:
    wlan0:
      dhcp4: true
      optional: true
      access-points:
        "RPi3B-a0be":
          password: "robotseverywhere"
          mode: ap
    sudo netplan generate
    sudo netplan apply
EOF
}

#update
#install_essentials
#install_vscode
#install_latex
#configure_bsuvpn
#install_julia
#install_singularity

