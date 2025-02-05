alias v=nvim
alias t=tmux
alias c=clear

# Overrides
alias vim=nvim
alias cd=z

# zsh
alias config="$EDITOR $HOME/.zshrc"
alias reload="source $HOME/.zshrc"

# tmux
alias ta="tmux attach"
alias td="tmux detach"
alias trs="tmux rename-session"
alias trw="tmux rename-window"

# ls
alias l="eza -1"
alias ls="eza"
alias la='exa -laghm@ --all --icons --git --color=always'

# cd 
alias ..="cd .."
alias ...="cd ../.."
alias proj="cd $PROJECTS"
alias dot="cd $DOTFILES"

# fnm
alias nvm="fnm" 

# docker/k8s
alias d="docker"
alias k="kubectl"
alias kctx="kubectl set-context"
alias kgp="kubectl get pods"

# git
alias gs="git status"
alias gc="git commit -m" # Must provide your own message
alias gp="git push"
alias gl="git log --oneline" 

