#!/usr/bin/env bash

# Set up some important directories if not already created
mkdir -p "$HOME/.local/{bin,share,state}"

# Check for zsh
USING_ZSH=$(test [[ $(echo $SHELL | tr '/' '\n' | tail -n 1) == 'zsh' ]])
if [[ ! $USING_ZSH ]]; then
  echo "Please set up zsh and try again"
  exit 1
fi

# Install mise to manage packages
#
# see: https://github.com/jdx/mise
#      https://mise.jdx.dev/
#
# Might need to add `mise trust` here due to symlinking
# but need to test 
#

curl "https://mise.run" | sh
command -v mise && \
  mise activate zsh && \
  mise install

# Install a local server that will help grab binaries 
# that I don't want to manage with mise of system package manager
#
# see: https://github.com/jpillora/installer
#

BIN_DIR="$HOME/.local/bin"
(cd "$BIN_DIR" && source "$DOTFILES/scripts/installer.sh")
installer # Starts the server

# Grab a few key packages, will move a bunch more over as I test this more
#

# neovim
(cd "$BIN_DIR && curl -s http://localhost:3000/neovim/neovim?as=nvim | bash)
# fzf
(cd "$BIN_DIR && curl -s http://localhost:3000/junegunn/fzf | bash)
# zoxide
(cd "$BIN_DIR && curl -s http://localhost:3000/ajeetdsouza/zoxide | bash)
