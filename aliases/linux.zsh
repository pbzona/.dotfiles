# Package name conflict, name is batcat, not bat
alias bat=batcat

# Ubuntu names the binary fdfind
alias fd=fdfind

alias f2b=fail2ban-client

# pbcopy/pbpaste equivalents via xclip
if command -v xclip &> /dev/null; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi
