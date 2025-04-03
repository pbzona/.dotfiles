#!/usr/bin/env bash
# Core packages for everyday use

OS=$(detect_os)

case "$OS" in
  "linux")
    sudo apt install \
      tmux \
      docker.io \
      openssl \
      fail2ban
  ;;
  "macos") 
    brew install \
      tmux \
      docker \
      openssl \
    
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
  *) echo default
  ;;
esac



