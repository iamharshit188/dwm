#!/bin/bash
### Installing Basic packages
sudo pacman -S  imagemagick mpv flameshot-gui  feh ttf-jetbrains-mono noto-fonts python-pip trash-cli tlp --noconfirm 

## Installing Pywal for Wallpaper color support
pip install pywal --break

## Adding all the Fonts
cd ../Fonts/
sudo mv * /usr/share/fonts/
mkdir -p ~/.local/bin/ ~/.local/src/
cd ../Scripts/  
mv * ~/.local/bin/
cd ..
mv  ./.bashrc ~/

# Enabling TLP 
sudo mv ./tlp.conf /etc/
systemctl enable tlp.service --now
## Adding touchpad support for laptops
sudo mv ./30-touchpad.conf /etc/X11/xorg.conf.d/

## Setting up chaotic-aur
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
mv ./pacman.conf /etc/

## Setting up git 
sudo pacman -S git 
git config --global user.name "Harshit Tiwari"
git config --global user.mail "tech.harshit.tiwari@gmail.com"
## Installing AUR Packages
sudo pacman -Rns vim nano 
sudo pacman -S neovim npm unzip envycontrol flameshot google-chrome visual-studio-code-bin asusctl 

## Installing neovim
git clone https://github.com/NvChad/starter ~/.config/nvim && nvim

## Installing Flutter Dependencies
sudo pacman -S android-studio jdk17-openjdk 
mkdir ~/.flutter 

curl -O "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.5-stable.tar.xz" 
tar xf flutter_linux_3.19.5-stable.tar.xz 
mv flutter/* ~/.flutter/ 
envycontrol -s Hybrid
reboot
