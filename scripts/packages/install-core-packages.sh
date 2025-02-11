#!/usr/bin/env bash

# Core packages for everyday use, self explanatory
OS=$(detect_os)

case "$OS" in
  "linux")
    sudo apt install \
      tmux \
      zellij \
      docker.io \
      openssl

    installer & ; (cd "$HOME/.local/bin" && curl "http://localhost:3000/yazi" | bash)
  ;;
  "macos") 
    brew install \
      tmux \
      zellij \
      docker \
      openssl \
      yazi
  ;;
  *) echo default
  ;;
esac



