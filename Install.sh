## Installing DWM dependencies
sudo pacman -S libx11 libxft imagemagick feh libxinerama xorg-server xorg-xinit ttf-jetbrains-mono noto-fonts python-pip --noconfirm 
## Installing Pywal for Wallpaper color support
pip install pywal 
## Installing DWM
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
## Adding all the fonts
cd ../
sudo mv Fonts/* /usr/share/fonts/
mkdir -p ~/.local/bin/
mv ../Scripts/* ~/.local/bin/
cd ..
mv .xinit .bashrc ~/
## Adding touchpad support for laptops
mv ./30-touchpad.conf /etc/X11/xorg.conf.d/

