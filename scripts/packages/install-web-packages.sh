#!/usr/bin/env bash

# Packages for web search and browsing
# - w3m, elinks are text-based browsers
# - surfraw searches multiple indices (elvi) but homebrew version is broken
# - ddgr is DuckDuckGo search cli
#   example: BROWSER=w3m ddgr "search query" 

OS=$(detect_os)

case "$OS" in
  "linux") 
    sudo apt install \
      elinks \
      w3m \
      surfraw \
      ddgr
  ;;
  "macos") 
    brew install \
      elinks \
      w3m \
      ddgr
  ;;
  *) echo default
  ;;
esac

