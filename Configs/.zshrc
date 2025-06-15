
export ZSH="$HOME/.oh-my-zsh"
export COLORTERM=truecolor

ZSH_THEME="robbyrussell"

plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8

export EDITOR=nano

# === Alias ===

# Docker
alias dco="docker compose"
alias dps="docker ps"
alias dpa="docker ps -a"
alias dl="docker ps -l -q"
alias dx="docker exec -it"
alias di='docker images'

# Dirs
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# System
alias shnow='shutdown -h now'
alias cls='clear'
alias lsa='ls -a'

# Bat
alias cat='bat'

# Tmux
alias tm=tmux
alias tml='tmux ls'
alias tma='tmux a'
alias tmat='tmux a -t'
alias tmn='tmux new -t'
alias tmk='tmux kill-ses -t'
alias tmkill='tmux kill-server'

# Eza
alias l="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias lti="eza --tree --level=2 --long --icons --git-ignore"
alias ltree="eza --tree --level=2  --icons --git"
alias ls='eza --icons=auto'

# Yazi
alias y='yazi'

# Auto cd
setopt auto_cd

# FZF
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# history setup
HISTFILE=$HOME/.zhistory
#SAVEHIST=10000
#HISTSIZE=10000
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

eval "$(starship init zsh)"

eval "$(zoxide init zsh)"
. "$HOME/.atuin/bin/env"

# eval "$(atuin init zsh)"
eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r)"
