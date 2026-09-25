#!/usr/bin/env bash
set -euo pipefail

## Sanity check: this script is Arch-only (pacman-based)
command -v pacman >/dev/null 2>&1 || { echo "This script is for Arch Linux only. For Debian trixie, use ./Install-Debian.sh instead." >&2; exit 1; }

loc=$(pwd)
## Installing DWM dependencies
## Setting up chaotic-aur
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' --noconfirm
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm
sudo mv "$loc/pacman.conf" /etc/pacman.conf

## Detecting Nvidia Card
# NvidiaDetector.sh legitimately exits non-zero when there's no NVIDIA card
# or the driver isn't installed yet, so don't let it abort the whole install.
bash "$loc/NvidiaDetector.sh" || true

sudo pacman -Syu libx11 libxft imagemagick feh libxinerama xorg-server xorg-xinit ttf-jetbrains-mono noto-fonts python-pip trash-cli asusctl envycontrol google-chrome openssh libappindicator-gtk3 tlp powertop --noconfirm
## Installing Pywal for Wallpaper color support
pip install --user --break-system-packages pywal
## Installing DWM
cd "$loc/dwm"
pwd
echo "Installing DWM :) and applying patches"
sudo make clean install
echo "DWM Installed"
cd "$loc/st"
pwd
echo "Installing st (Simple Terminal) ;)"
sudo make clean install
echo "Simple Terminal Installed"
cd "$loc/dmenu"
pwd
echo "Installing dmenu :)"
sudo make clean install
echo "dmenu installed"
cd "$loc/dwmblocks"
pwd
echo "Installing dwmblocks and applying patches :)"
sudo make clean install
echo "DWMblocks Installed"

# Adding TLP support Underclocking CPU to 2.70Ghz
[ -f /etc/default/grub ] && sudo cp /etc/default/grub "/etc/default/grub.bak.$(date +%s)"
sudo mv "$loc/grub" /etc/default/
sudo grub-mkconfig -o /boot/grub/grub.cfg
[ -f /etc/tlp.conf ] && sudo cp /etc/tlp.conf "/etc/tlp.conf.bak.$(date +%s)"
sudo mv "$loc/tlp.conf" /etc/tlp.conf
sudo systemctl enable tlp --now
## Adding all the Fonts
sudo mkdir -p /usr/share/fonts/dwm-nerd-fonts
sudo cp -r "$loc/Fonts/." /usr/share/fonts/dwm-nerd-fonts/
sudo fc-cache -f
mkdir -p ~/.local/bin/ ~/.local/src/
cp -r "$loc"/Scripts/* ~/.local/bin/
chmod +x ~/.local/bin/*
## Backing up and installing dotfiles
for f in .bashrc .xinitrc; do
	[ -f "$HOME/$f" ] && cp "$HOME/$f" "$HOME/$f.bak.$(date +%s)"
	cp "$loc/$f" "$HOME/$f"
done
## Adding touchpad support for laptops
[ -f /etc/X11/xorg.conf.d/30-touchpad.conf ] && sudo cp /etc/X11/xorg.conf.d/30-touchpad.conf "/etc/X11/xorg.conf.d/30-touchpad.conf.bak.$(date +%s)"
sudo mv "$loc/30-touchpad.conf" /etc/X11/xorg.conf.d/
echo "DWM has been installed , Simple Terminal has been installed , now reboot "
echo "type startx after logging in to tty"
echo "Thank you for using my dots ;)"
