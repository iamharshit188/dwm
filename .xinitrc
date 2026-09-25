#!/bin/sh
# To execute dwmblocks.
dwmblocks &
#To add transparency
picom &
#To restore the wallpaper you've applied last time.
[ -f "$HOME/.fehbg" ] && "$HOME/.fehbg" &
# To change DWM status bar color with pywal.
wal -R
# Your must Define ~/.local/bin in whichever shell you're using. Else color won't change.
# Python script to change DWMstatus color written in python
python3 ~/.local/bin/status.py
# To Execute dwm workspace
exec dwm
