#!/bin/env bash
DEBIAN_FRONTEND=noninteractive
sudo apt update -qq 
sudo apt install -y gnupg wget git curl screen ubuntu-server dos2unix cmake make
sudo apt clean
wget https://github.com/aptly-dev/aptly/releases/download/v1.4.0/aptly_1.4.0_amd64.deb -O /tmp/aptly.deb 
sudo dpkg -i /tmp/aptly.deb || exit 127
sudo -rfv /tmp/aptly.deb

sudo mkdir -p /aptly
chown $USER:$GROUP /aptly
chown 777 /aptly