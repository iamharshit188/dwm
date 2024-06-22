#! /bin/bash
loc=$(pwd)
## Installing DWM dependencies
## Setting up chaotic-aur
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
sudo mv $loc/pacman.conf /etc/pacman.conf

## Detecting Nvidia Card
 sh $loc/NvidiaDetector.sh

sudo pacman -Syu libx11 libxft imagemagick feh libxinerama xorg-server xorg-xinit ttf-jetbrains-mono noto-fonts python-pip trash-cli asusctl envycontrol google-chrome openssh libappindicator-gtk3 --noconfirm 
## Installing Pywal for Wallpaper color support
pip install pywal --break
## Installing DWM
cd dwm
pwd
echo "Installing DWM :) and applying patches"
sudo make clean install
echo "DWM Installed"
cd $loc/st
pwd
echo "Installing st (Simple Terminal) ;)"
sudo make clean install 
echo "Simple Terminal Installed"
cd $loc/dmenu
pwd
echo "Installing dmenu :)"
sudo make clean install
echo "dmenu installed"
cd $loc/dwmblocks
pwd
echo "Installing dwmblocks and applying patches :)"
sudo make clean install
echo "DWMblocks Installed"

## Adding all the Fonts
cd $loc 
sudo mv $loc/Fonts * /usr/share/fonts/
mkdir -p ~/.local/bin/ ~/.local/src/
mv $loc/Scripts/* ~/.local/bin/
mv $loc/.xinitrc $loc/.bashrc ~/
## Adding touchpad support for laptops
sudo mv $loc/30-touchpad.conf /etc/X11/xorg.conf.d/
echo "DWM has been installed , Simple Terminal has been installed , now reboot "
echo "type startx after logging in to tty"
echo "Thank you for using my dots ;)"

