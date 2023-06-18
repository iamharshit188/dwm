#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
cat ~/.cache/wal/sequences
export PATH=$PATH:/home/iamharshit188/.local/bin/
alias findpackage='pacman -Qq | fzf'
alias ls='ls --color=auto'
alias rm='trash -v'
alias nv='neovide'
alias killcmus='sudo kill -9 "$(pidof cmus)"'
alias downloadplaylist="yt-dlp -f 'bestvideo[height<=720][ext=mp4]+bestaudio[ext=m4a]/best[height<=720][ext=mp4]/best' --yes-playlist"
alias downloadsongs="yt-dlp --extract-audio --audio-format mp3 "
alias ytfzf='ytfzf  --video-pref=720p'
alias sudo='doas'
alias grep='grep --color=auto'
eval "$(starship init bash)"
PS1='[\u@\h \W]\$ '
