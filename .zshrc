#
#  _ __ | |__ _______| |__  
# | '_ \| '_ \_  / __| '_ \ 
# | |_) | |_) / /\__ \ | | |
# | .__/|_.__/___|___/_| |_|
# |_|                       
#
# Need this for some os-specific settings
source $HOME/.dotfiles/scripts/lib.sh
OS=$(detect_os)

# Searchable sections:
#
#   config.env
#   config.directories
#   config.zinit
#     config.zinit.plugins
#     config.zinit.snippets
#     config.zinit.config
#   config.path
#   config.history
#   config.sourcing
#   config.mise / config.tools
#   config.fnm
#   config.node
#   config.pnpm
#   config.golang
#   config.zoxide
#   config.fzf
#   config.aliases
#   config.prompt

# =============================================================================
# ENVIRONMENT
# config.env
# =============================================================================

export VISUAL="nvim"
export EDITOR="nvim"
export TERM="tmux-256color"

export GITHUBUSER="pbzona"

# Using mostly defaults for predictability
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_DIRS="/usr/local/share:/usr/share"
export XDG_CONFIG_DIRS="/etc/xdg"
export XDG_CACHE_HOME="$HOME/.cache"


# =============================================================================
# DIRECTORIES
# config.directories
# =============================================================================

export PROJECTS="$HOME/Projects"
export DOTFILES="$HOME/.dotfiles"


# =============================================================================
# ZINIT
# config.zinit
# =============================================================================

if [[ -f "/opt/homebrew/bin/brew" ]] then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# ZINIT PLUGINS
# ----------------------------------------------------------------------------
# config.zinit.plugins
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light Aloxaf/fzf-tab

# More feature complete than set -o vi
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=242"
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZVM_VI_ESCAPE_BINDKEY=jk

# ZINIT SNIPPETS 
# ----------------------------------------------------------------------------
# config.zinit.snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo

# ZINIT CONFIG
# ----------------------------------------------------------------------------
# config.zinit.config
autoload -Uz compinit && compinit

zinit cdreplay -q

# =============================================================================
# PATH CONFIG 
# config.path
# =============================================================================

setopt extended_glob null_glob

path=(
  $path
  $HOME/bin
  $HOME/.local/share
  $HOME/.local/bin
  $DOTFILES/bin
  $DOTFILES/scripts
)

# Remove duplicate entries 
typeset -U path

export PATH

# =============================================================================
# HISTORY
# config.history
# =============================================================================

HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase

setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# =============================================================================
# COMPLETIONS
# config.completions
# =============================================================================

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

command -v portal 2>/dev/null && eval $(portal completion zsh)

# =============================================================================
# SOURCING
# config.sourcing
# =============================================================================

source "$HOME/.privaterc"

# =============================================================================
# MISE / DEV TOOLS
# config.mise config.tools
# =============================================================================

eval "$(~/.local/bin/mise activate zsh)"

# =============================================================================
# FNM (Node.js)
# config.fnm config.node
# =============================================================================

export PATH="$HOME/.local/share/fnm:$PATH"
eval "`fnm env`"
eval "$(fnm env --use-on-cd --shell zsh)"

# =============================================================================
# PNPM
# config.pnpm
# =============================================================================

export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# =============================================================================
# GOLANG
# config.golang
# =============================================================================

export GOROOT=$HOME/.go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# =============================================================================
# ZOXIDE
# config.zoxide
# =============================================================================

eval "$(zoxide init zsh)"

# =============================================================================
# FZF
# config.fzf
# =============================================================================

if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
else
  source <(fzf --zsh)
fi

export FZF_DEFAULT_OPTS="--layout=reverse" 

# =============================================================================
# ALIASES 
# config.aliases
# =============================================================================

# platform specific
if [[ "$OS" == "linux" ]]; then
  source "$DOTFILES/aliases/linux.zsh"
fi

if [[ "$OS" == "macos" ]]; then
  source "$DOTFILES/aliases/macos.zsh"
fi

# Keep aliases separate for organization
source "$DOTFILES/aliases/common.zsh"

# One-liners
# ==========

# find man pages interactively (broken without omz)
alias fman="compgen -c | fzf | xargs man"

# find pid interactively
alias fpid="ps aux | fzf | awk '{print $2}'" 

# finds all files recursively and sorts by last modification, ignore hidden files
alias lastmod='find . -type f -not -path "*/\.*" -exec ls -lrt {} +'

# generate a random secret
alias secret="openssl rand -hex 32"

# =============================================================================
# PROMPT
# config.prompt
# =============================================================================

zinit ice compile'(pure|async).zsh' pick'async.zsh' src'pure.zsh'
zinit light sindresorhus/pure


. "$HOME/.local/share/../bin/env"
