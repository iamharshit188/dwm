sudo pacman -S libx11 libxinerama libxft webkit2gtk alacritty xorg-xinit xorg-server pulseaudio-bluetooth pulseaudio bluez bluez-utils ytfzf fzf bc jq yt-dlp mpv sxiv opendoas
mkdir -p ~/.local/bin
mkdir -p ~/.local/src
mkdir -p ~/.config/alacritty
cd ~/.local/src
git clone https://github.com/iamharshit188/dwm
git clone https://aur.archlinux.org/google-chrome
git clone https://aur.archlinux.org/visual-studio-code-bin
cd ~/.local/src/dwm
cd dwm
echo "Installing DWM :) and applying patches"
sudo make clean install
cd ../st
echo "Installing st just in case alacritty isnt supported by your GPU ;)"
sudo make clean install 
echo "Patches applied"
cd ../dmenu
echo "Installing dmenu :)"
sudo make clean install
cd ../dwmblocks
echo "Installing dwmblocks and applying patches :)"
sudo make clean install
echo "Installing slock lockscreen, Unpatched due to Security issues:)"
cd ../slock
sudo make clean install
cd ~/local/src/google-chrome
makepkg -si
cd ~/local/src/visual-studio-code-bin
makepkg -si
cp ~/.local/src/dwm/.xinitrc ~/
cp ~/.local/src/dwm/.bashrc ~/
cp ~/.local/src/dwm/.config/starship.toml ~/.config/
sudo echo "permit :wheel" >> /etc/doas.conf
