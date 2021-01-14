#!/bin/env bash
apt update
export DEBIAN_FRONTEND=noninteractive
apt install -y gnupg wget git curl screen ubuntu-server dos2unix cmake make
wget https://github.com/aptly-dev/aptly/releases/download/v1.4.0/aptly_1.4.0_amd64.deb -O /tmp/aptly.deb 
dpkg -i /tmp/aptly.deb
-rfv /tmp/aptly.deb
git clone https://github.com/Sirherobrine23/Index-pages.git /tmp/index
cd /tmp/index
cmake . -DCMAKE_INSTALL_PREFIX=/usr
make install
mkdir aptly
# Autoremove
apt-get -qq autoremove --purge
exit 0