#!/usr/bin/env python

import subprocess

# Get the current colorscheme using pywal
colors = subprocess.check_output(['wal', '-i', '~/.config/wallpapers/wall1.jpg', '-q', '-t']).decode('utf-8').split('\n')

STATUSCOLOR = colors[0]
SELCOLOR = colors[1]

# Set the status bar colors using X11
subprocess.run(['xsetroot', '-solid', STATUSCOLOR])
subprocess.run(['setxkbmap', '-option', 'grp:menu_toggle', '-option', 'grp_led:scroll', 'us,ru'])
