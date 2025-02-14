#!/usr/bin/env bash
# Core packages for everyday use

OS=$(detect_os)

case "$OS" in
  "linux")
    sudo apt install \
      tmux \
      docker.io \
      openssl \
      ruby \ # Need this for the tmuxinator gem installation
      fail2ban

    # Tmuxinator (tmux session manager)
    # https://github.com/tmuxinator/tmuxinator
    #
    gem install tmuxinator
    wget https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.zsh -O /usr/local/share/zsh/site-functions/_tmuxinator
    (installer &); (cd "$HOME/.local/bin" && curl "http://localhost:3000/yazi" | bash)
  ;;
  "macos") 
    brew install \
      tmux \
      docker \
      openssl \
      ruby \
      yazi
    
    # Wezterm (terminal emulator)
    # https://wezterm.org/
    #
    brew install --cask wezterm

    # Tmuxinator (tmux session manager)
    # https://github.com/tmuxinator/tmuxinator
    #
    gem install tmuxinator
    wget https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.zsh -O /usr/local/share/zsh/site-functions/_tmuxinator

    # Aerospace (tiling window manager)
    # https://github.com/nikitabobko/Aerospace
    #
    brew install --cask nikitabobko/tap/aerospace
    defaults write -g NSWindowShouldDragOnGesture -bool true
  ;;
  *) echo default
  ;;
esac



