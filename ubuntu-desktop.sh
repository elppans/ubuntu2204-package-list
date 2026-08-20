#!/usr/bin/env bash


sudo mv /etc/apt/sources.list /etc/apt/sources.list.backup_"$(date +%Y%m%d%H%M)"

cat <<EOF | sudo tee /etc/apt/sources.list
deb http://br.archive.ubuntu.com/ubuntu/ jammy main universe restricted
deb http://br.archive.ubuntu.com/ubuntu/ jammy-updates main universe restricted
deb http://br.archive.ubuntu.com/ubuntu/ jammy-security main universe restricted
EOF

sudo apt update
sudo apt --fix-broken install
sudo apt install --reinstall ubuntu-desktop gdm3 -y
sudo dpkg-reconfigure gdm3
sudo systemctl set-default graphical.target
sudo apt install -f
sudo systemctl start gdm3
sudo apt upgrade -y
sudo apt clean
sudo apt autoclean
sudo apt autoremove

sleep 15
sudo systemctl reboot -i
