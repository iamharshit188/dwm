
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


