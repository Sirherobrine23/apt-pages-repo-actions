#!/bin/env bash
sudo apt update
sudo apt install -y gnupg wget git curl screen ubuntu-server dos2unix cmake make
wget https://github.com/aptly-dev/aptly/releases/download/v1.4.0/aptly_1.4.0_amd64.deb -O /tmp/aptly.deb 
sudo dpkg -i /tmp/aptly.deb
sudo -rfv /tmp/aptly.deb
git clone https://github.com/Sirherobrine23/Index-pages.git /tmp/index
cd /tmp/index
cmake . -DCMAKE_INSTALL_PREFIX=/usr
sudo make install
mkdir aptly
# Autoremove
sudo apt-get -qq autoremove --purge
exit 0