#!/bin/env bash
DEBIAN_FRONTEND=noninteractive
sudo apt update
sudo apt install -y gnupg wget git curl screen ubuntu-server dos2unix cmake make
wget https://github.com/aptly-dev/aptly/releases/download/v1.4.0/aptly_1.4.0_amd64.deb -O /tmp/aptly.deb 
sudo dpkg -i /tmp/aptly.deb
sudo -rfv /tmp/aptly.deb
sudo apt purge -y *golang* *android* *google* *mysql* *java* *openjdk* &> /dev/null
git clone https://github.com/Sirherobrine23/Index-pages.git /tmp/index
cd /tmp/index
cmake . -DCMAKE_INSTALL_PREFIX=/usr
sudo make install
mkdir aptly
apt purge --remove *dotnet* -y
sudo rm -rf /usr/share/dotnet
sudo rm -rf /usr/local/lib/android
# Autoremove
sudo apt-get -qq autoremove --purge
sudo swapoff -a
sudo rm -rf /mnt/swap*
exit 0