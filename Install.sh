#! /bin/bash
echo "Welcome to the installation of DWM by @iamharshit188 (Harshit Tiwari)"
echo " An Important Note : Please enter sudo / root password whenever prompted, To install it without any issues."
echo " If you are Using any desktop environment then logout and execute this script from console/tty"
echo "Installing necessary packages"
sudo pacman -S xorg-server xorg-xinit git python-pywal feh alacritty dunst ttf-jetbrains-mono picom --noconfirm
echo "All necessary packages download and installed."
echo "Cloning repository"
mkdir ~/DWMbyHt
cd ~/DWMbtHt
git clone https://github.com/iamharshit188/dwm
cd dwm
echo " Do you want to enable touchpad support ? Y for yes / N for no"
read input
if( input = "Y" )
	sudo mkdir -p /etc/X11/xorg.conf.d/
	sudo cp 30-touchpad.conf /etc/X11/xorg.conf.d/
else
	echo " Skipped "
fi

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
echo " Do you want my Wallpaper collection ? Y for yes / N for no"
read input1
if ( input1 = "Y" )
	echo " Copying Wallpapers ;)"
	mkdir -p ~/WalllllsbyHarshit
	cd Wallpapers
	mv * ~/WalllllsbyHarshit
	echo "All Wallpapers copied"
	ls -al ~/WalllllsbyHarshit
	
else
	echo " Skipped "
fi

echo "Copying Neccesary scripts"
cd ~/DWMbyHt/Scripts
sudo mv * /bin/

echo "Copied all Scripts"
echo " Do you want to use any Login manager (Y) or Want to login manually using  startx  (N) . Enter you choice Y/N"
read lm
if( lm = "Y" )
	sudo pacman -S lightdm --noconfirm
	sudo systemctl enable lightdm
	sudo mkdir -p /usr/share/xsessions/
       echo "[Desktop Entry]" >> /usr/share/xsessions/dwm.desktop
       echo "Encoding=UTF-8" >> /usr/share/xsessions/dwm.desktop
       echo "Name=dwm" >> /usr/share/xsessions/dwm.desktop
       echo "Comment=Dynamic window manager" >> /usr/share/xsessions/dwm.desktop
       echo "Exec=dwm" >> /usr/share/xsessions/dwm.desktop
       echo "Icon=dwm" >> /usr/share/xsessions/dwm.desktop
       echo "Type=XSession" >> /usr/share/xsessions/dwm.desktop
       echo "Script Finished :) DWM installed "
       sudo systemctl start lightdm     
       rm -rf ~/DWMbyHt

else
	cp ~/DWMbyHt/.xinitrc ~/
	echo "Copied .xinitrc file to your home" 
	echo "Execute startx ~/.xinitrc for first time"
fi
echo " Script Finished "
       rm -rf ~/DWMbyHt


