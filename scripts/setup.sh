#!/usr/bin/env bash

DOTFILES="$HOME/.dotfiles"

# Source private environment variables if they exist
if [[ -f "$HOME/.privaterc" ]]; then
  source "$HOME/.privaterc"
fi

# Set up some important directories if not already created
mkdir -p "$HOME/.local/{bin,share,state}"

# Check for zsh
if [[ ! "$(echo $SHELL | tr '/' '\n' | tail -n 1)" == "zsh" ]]; then
  echo "Please set up zsh and try again"
  exit 1
fi

# If mac get some cool fonts for the terminal
# If linux I'm prob accessing remotely so doesn't matter
source "$DOTFILES/scripts/lib.sh"
OS=$(detect_os)
if [[ $OS == "macos" ]]; then
  brew install font-geist-mono-nerd-font font-lilex-nerd-font
fi

# Install mise to manage packages
# see: https://github.com/jdx/mise
#      https://mise.jdx.dev/
#

echo "Installing mise-en-place..."
if [[ ! -f "$HOME/.local/bin/mise" ]]; then
  curl "https://mise.run" | sh
  command -v mise && \
    mise activate zsh && \
    mise install
else
  echo "Mise is already installed, skipping..."
fi

# Install eget 
# see: https://github.com/zyedidia/eget
#
echo "Installing eget..."
curl https://zyedidia.github.io/eget.sh | sh
mv ./eget "$HOME/.local/bin"

# neovim
source "$DOTFILES/scripts/packages/install-neovim.sh"
# fzf
eget "junegunn/fzf"
mv ./fzf "$HOME/.local/bin"
# zoxide
eget "ajeetdsouza/zoxide" 
mv ./zoxide "$HOME/.local/bin"
# yazi
eget "sxyazi/yazi"
mv ./yazi "$HOME/.local/bin"

# Misc standard tools
source "$DOTFILES/scripts/packages/install-core-packages.sh"
source "$DOTFILES/scripts/packages/install-cheatsheet-packages.sh"

# Posting: TUI REST API client
# https://github.com/darrenburns/posting
uv tool install --python 3.12 posting

