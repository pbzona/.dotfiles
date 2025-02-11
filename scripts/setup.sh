#!/usr/bin/env bash

# Make sure this includes GITHUB_TOKEN to avoid rate limiting
source "$HOME/.privaterc"

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
#
# see: https://github.com/jdx/mise
#      https://mise.jdx.dev/
#
# Might need to add `mise trust` here due to symlinking
# but need to test 
#

if [[ ! -f "$HOME/.local/bin/mise" ]]; then
  curl "https://mise.run" | sh
  command -v mise && \
    mise activate zsh && \
    mise install
else
  echo "Mise is already installed, skipping..."
fi

# Install a local server that will help grab binaries 
# that I don't want to manage with mise of system package manager
#
# see: https://github.com/jpillora/installer
#

BIN_DIR="$HOME/.local/bin"
(cd "$BIN_DIR" && source "$DOTFILES/scripts/installer.sh")
installer & # Starts the server as a bg process

# Grab a few key packages, will move a bunch more over as I test this more
#

# neovim
command -v nvim 2>/dev/null || (cd "$BIN_DIR" && curl -s "http://localhost:3000/neovim/neovim?as=nvim" | bash)
# fzf
command -v fzf 2>/dev/null || (cd "$BIN_DIR" && curl -s "http://localhost:3000/junegunn/fzf" | bash)
# zoxide
command -v zoxide 2>/dev/null || (cd "$BIN_DIR" && curl -s "http://localhost:3000/ajeetdsouza/zoxide" | bash)

source "$DOTFILES/scripts/packages/install-core-packages.sh"

# Configure other packages to install here
# Default is to include everything
#

WEB_PACKAGES=true

if [[ "$WEB_PACKAGES" ]]; then
  source "$DOTFILES/scripts/packages/install-web-packages.sh"
fi

# Other packages that I'm not sure how to categorize
#

# Portal: p2p file transfer
# https://github.com/SpatiumPortae/portal
(cd "$BIN_DIR" && curl -s "http://localhost:3000/SpatiumPortae/portal" | bash)

# Posting: TUI REST API client
# https://github.com/darrenburns/posting
# (Using uv because it's Python, not a compiled binary)
uv tool install --python 3.12 posting

