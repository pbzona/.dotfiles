#!/usr/bin/env bash

# Core packages for everyday use, self explanatory
OS=$(detect_os)

case "$OS" in
  "linux")
    sudo apt install \
      tmux \
      docker.io \
      openssl \
      fail2ban

    installer & ; (cd "$HOME/.local/bin" && curl "http://localhost:3000/yazi" | bash)
  ;;
  "macos") 
    brew install \
      tmux \
      docker \
      openssl \
      yazi
  ;;
  *) echo default
  ;;
esac



