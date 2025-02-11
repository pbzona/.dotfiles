#!/usr/bin/env bash

os_name=$(uname -s)

# Linux
if [[ "$os_name" == "Linux" ]]; then
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  tar -C /opt -xzf nvim-linux-x86_64.tar.gz
  ln -s /opt/nvim-linux-x86_64/bin/nvim "$HOME/.local/bin/nvim" 
fi  

# Macos
if [[ "$os_name" == "Darwin" ]]; then
  curl -L0 https://github.com/neovim/neovim/releases/latest/download/nvim-macos-arm64.tar.gz
  xattr -c ./nvim-macos-arm64.tar.gz

  if [[ -d /opt/nvim ]]; then
    sudo rm -rf /opt/nvim
  elif [[ -f /opt/homebrew/bin/nvim ]]; then
    brew uninstall neovim
  fi
  sudo tar -C /opt -xzf nvim-macos-arm64.tar.gz
fi

