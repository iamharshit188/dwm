## Installing DWM dependencies
sudo pacman -S libx11 libxft imagemagick feh libxinerama xorg-server xorg-xinit ttf-jetbrains-mono noto-fonts python-pip trash-cli --noconfirm 
## Installing Pywal for Wallpaper color support
pip install pywal --break
## Installing DWM
cd dwm
echo "Installing DWM :) and applying patches"
sudo make clean install
echo "DWM Installed"
cd ../st
echo "Installing st (Simple Terminal) ;)"
sudo make clean install 
echo "Simple Terminal Installed"
cd ../dmenu
echo "Installing dmenu :)"
sudo make clean install
echo "dmenu installed"
cd ../dwmblocks
echo "Installing dwmblocks and applying patches :)"
sudo make clean install
echo "DWMblocks Installed"
## Adding all the Fonts
cd ./Fonts/
sudo mv * /usr/share/fonts/
mkdir -p ~/.local/bin/
cd .././Scripts/  
mv * ~/.local/bin/
cd ..
mv ./.xinit ./.bashrc ~/
## Adding touchpad support for laptops
sudo mv ./30-touchpad.conf /etc/X11/xorg.conf.d/
clear
echo "DWM has been installed , Simple Terminal has been installed , now reboot "
echo "type startx after logging in to tty"
echo "Thank you for using my dots ;)"

