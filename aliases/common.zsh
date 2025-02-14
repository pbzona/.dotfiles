# Short
alias c=clear
alias d=docker
alias k=kubectl
alias l="eza -1"
alias t=tmux
alias v=nvim

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
alias ts="tmux-sessionizer" # Custom script in ~/.local/bin
alias tx="tmuxinator"

# ls
alias ls="eza"
alias la="eza -laghm@ --all --icons --git --color=always"

# cd 
alias ..="cd .."
alias ...="cd ../.."
alias proj="cd $PROJECTS"
alias dot="cd $DOTFILES"

# fnm
alias nvm="fnm" 

# docker/k8s
alias kctx="kubectl set-context"
alias kgp="kubectl get pods"

# git
alias gs="git status"
alias gc="git commit -m" # Must provide your own message
alias gp="git push"
alias gl="git log --oneline" 

