#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
cat .cache/wal/sequences
export PATH=$PATH:/home/iamharshit188/.local/bin/
alias findpackage='pacman -Qq | fzf'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
eval "$(starship init bash)"
PS1='[\u@\h \W]\$ '
