#!/usr/bin/env bash
# Core packages for everyday use

source "$HOME/.dotfiles/scripts/lib.sh"
OS=$(detect_os)

case "$OS" in
"linux")
  sudo apt install \
    tmux \
    openssl \
    fail2ban \
    fd-find # Needed for initial nvim exlorer config, doens't pick up mise for some reason

  # Add Docker's official GPG key:
  sudo apt-get update
  sudo apt-get install ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update

  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  ;;
"macos")
  brew install \
    tmux \
    docker \
    openssl \
    fd

  # Wezterm (terminal emulator)
  # https://wezterm.org/
  #
  brew install --cask wezterm

  # Aerospace (tiling window manager)
  # https://github.com/nikitabobko/Aerospace
  #
  brew install --cask nikitabobko/tap/aerospace
  defaults write -g NSWindowShouldDragOnGesture -bool true
  ;;
*)
  echo default
  ;;
esac
