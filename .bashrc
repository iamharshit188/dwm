# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Wal sequences for terminal colors
#cat ~/.cache/wal/sequences

# Environment variables for Android SDK, Flutter, Dart, and Java
export PATH="/home/$(whoami)/.flutter/bin:$PATH"
export PATH="/home/$(whoami)/.local/bin:$PATH"
export PATH="/home/$(whoami)/Android/Sdk/cmdline-tools/latest/bin:$PATH"
# Your existing aliases
alias findpackage='pacman -Qq | fzf'
alias ls='ls --color=auto'
alias rm='trash -v'
alias nv='neovide'
alias killcmus='sudo kill -9 "$(pidof cmus)"'
alias downloadplaylist="yt-dlp -f 'bestvideo[height<=720][ext=mp4]+bestaudio[ext=m4a]/best[height<=720][ext=mp4]/best' --yes-playlist"
alias downloadsongs="yt-dlp --extract-audio --audio-format mp3 "
alias ytfzf='ytfzf  --video-pref=720p'
alias grep='grep --color=auto'

# Starship prompt configuration
eval "$(starship init bash)"

# Custom PS1 prompt
PS1='[\u@\h \W]\$ '

