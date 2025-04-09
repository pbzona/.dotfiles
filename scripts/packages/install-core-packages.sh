#!/usr/bin/env bash
# Core packages for everyday use

OS=$(detect_os)

case "$OS" in
"linux")
  sudo apt install \
    tmux \
    docker.io \
    openssl \
    fail2ban \
    fd-find # Needed for initial nvim exlorer config, doens't pick up mise for some reason
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
