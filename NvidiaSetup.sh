#!/bin/bash

echo "A minimal Script to Install Driver's for Nvidia Graphic cards"
# Installing Necessary Packages.
sudo pacman -S nvidia nvidia-utils opencl-nvidia bumblebee glxinfo
mv ./NvidiaScripts/* ~/.local/bin/


