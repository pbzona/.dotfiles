#!/usr/bin/env bash

DOTFILES="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"
BACKUP_CONFIG="$HOME/.backup_config"

# Make dirs if they don't already exist
mkdir -p $CONFIG_DIR
mkdir -p $BACKUP_CONFIG

# Usage: create_backup_config <original config> <backup filename>
create_backup_config() {
  if [ -d $1 ]; then 
    echo "Creating backup of $1 in $BACKUP_CONFIG"
    mv $1 "$BACKUP_CONFIG/$2.bak-$(date +%s)"
  fi
}

# Usage: create_link <original path> <dotfile path>
create_link() {
  create_backup_config $1 $2

  echo "Linking configuration for: $2..."
  ln -s "$DOTFILES/$2" $1
}

# Functions for each application so it's easier to enable/disable
link_neovim() {
  create_link "$CONFIG_DIR/nvim" ".config/nvim"
}

link_tmux() {
  create_link "$HOME/.tmux.conf" ".tmux.conf"
  echo "Press c-space + I to install tmux plugins"
}

link_zsh() {
  create_link "$HOME/.zshrc" ".zshrc"
}

# Link the stuff
case "$1" in
  nvim | neovim)
    link_neovim
    ;;
  tmux)
    link_tmux
    ;;
  zsh) 
    link_zsh
    ;;
  mac)
    echo "TODO: put macos specific configs here"
    ;;
  all)
    link_neovim
    link_tmux
    link_zsh
    ;;
  *)
    echo "Please pass the name of a configuration to link (or use 'all' to install all)" 
  ;;
esac


