#!/usr/bin/env bash
# Diagnostics and troubleshooting

cmd_doctor() {
  local show_help=false
  local has_issues=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help|-h)
        show_help=true
        shift
        ;;
      *)
        error "Unknown option: $1"
        exit 1
        ;;
    esac
  done

  if $show_help; then
    cat << EOF
dot doctor - Run diagnostics on dotfiles setup

Usage:
  dot doctor

Description:
  Checks the health of your dotfiles setup:
  - Shell configuration (zsh)
  - Package managers (Homebrew, mise)
  - Required tools (stow, git)
  - Symlink integrity
  - PATH configuration
  - Broken links detection

  Returns exit code 1 if any issues are found.

Examples:
  dot doctor    # Run all health checks
EOF
    exit 0
  fi

  echo ""
  info "Running dotfiles diagnostics..."
  echo ""

  # Source lib for OS detection
  source "$DOTFILES/scripts/lib.sh"
  local OS=$(detect_os)

  # Check 1: Shell
  echo "━━━ Shell Configuration ━━━"
  if [[ "$(echo $SHELL | tr '/' '\n' | tail -n 1)" == "zsh" ]]; then
    success "Default shell: zsh"
  else
    error "Default shell is not zsh: $SHELL"
    has_issues=true
    echo "  Fix: chsh -s \$(which zsh)"
  fi

  if [[ -f "$HOME/.zshrc" ]]; then
    if [[ -L "$HOME/.zshrc" ]]; then
      success ".zshrc is symlinked"
      local target=$(readlink "$HOME/.zshrc")
      if [[ -f "$target" ]]; then
        echo "  → $target"
      else
        error ".zshrc points to missing file: $target"
        has_issues=true
      fi
    else
      warn ".zshrc exists but is not a symlink"
      echo "  Consider backing up and running: dot link"
    fi
  else
    error ".zshrc not found"
    has_issues=true
  fi
  echo ""

  # Check 2: Package Managers
  echo "━━━ Package Managers ━━━"
  if [[ $OS == "macos" ]]; then
    if command -v brew &> /dev/null; then
      success "Homebrew: $(brew --version | head -n1)"

      # Check brew health
      if brew doctor &> /dev/null; then
        success "Homebrew health check passed"
      else
        warn "Homebrew has warnings (run 'brew doctor' for details)"
      fi
    else
      error "Homebrew not installed"
      has_issues=true
      echo "  Install: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    fi
  fi

  if command -v mise &> /dev/null; then
    success "mise: $(mise --version)"
  else
    error "mise not installed"
    has_issues=true
    echo "  Install: curl https://mise.run | sh"
  fi
  echo ""

  # Check 3: Essential Tools
  echo "━━━ Essential Tools ━━━"
  local tools=("git" "stow" "curl" "tmux" "nvim")
  for tool in "${tools[@]}"; do
    if command -v "$tool" &> /dev/null; then
      success "$tool installed"
    else
      error "$tool not found"
      has_issues=true
      if [[ "$tool" == "stow" ]]; then
        echo "  Install: brew install stow"
      fi
    fi
  done
  echo ""

  # Check 4: PATH Configuration
  echo "━━━ PATH Configuration ━━━"
  if [[ ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
    success "~/.local/bin in PATH"
  else
    error "~/.local/bin not in PATH"
    has_issues=true
    echo "  Add to ~/.zshrc: export PATH=\"\$HOME/.local/bin:\$PATH\""
  fi

  if command -v mise &> /dev/null; then
    if mise env &> /dev/null; then
      success "mise environment configured"
    else
      warn "mise installed but environment not configured"
      echo "  Add to ~/.zshrc: eval \"\$(mise activate zsh)\""
    fi
  fi
  echo ""

  # Check 5: Symlinks
  echo "━━━ Dotfile Symlinks ━━━"
  local configs=(
    "$HOME/.zshrc"
    "$HOME/.tmux.conf"
    "$HOME/.aerospace.toml"
    "$HOME/.config/nvim"
    "$HOME/.config/wezterm"
    "$HOME/.config/mise"
  )

  for config in "${configs[@]}"; do
    local name=$(basename "$config")
    if [[ "$config" == *".config/"* ]]; then
      name=".config/$(basename "$config")"
    fi

    if [[ -e "$config" ]]; then
      if [[ -L "$config" ]]; then
        local target=$(readlink "$config")
        if [[ -e "$target" ]]; then
          success "$name → linked correctly"
        else
          error "$name → broken link (target missing)"
          has_issues=true
          echo "  Target: $target"
        fi
      else
        warn "$name exists but is not a symlink"
        echo "  Location: $config"
      fi
    else
      warn "$name not found"
      echo "  Run: dot link"
    fi
  done
  echo ""

  # Check 6: Broken Symlinks in Home
  echo "━━━ Broken Symlinks ━━━"
  local broken_links=$(find "$HOME" -maxdepth 3 -type l ! -exec test -e {} \; -print 2>/dev/null | grep -v "Library\|\.Trash" || true)
  if [[ -z "$broken_links" ]]; then
    success "No broken symlinks found"
  else
    warn "Found broken symlinks:"
    echo "$broken_links" | while IFS= read -r link; do
      echo "  - $link → $(readlink "$link")"
    done
  fi
  echo ""

  # Check 7: Git Configuration
  echo "━━━ Git Configuration ━━━"
  if git config user.name &> /dev/null; then
    success "Git user.name: $(git config user.name)"
  else
    warn "Git user.name not set"
    echo "  Set: git config --global user.name \"Your Name\""
  fi

  if git config user.email &> /dev/null; then
    success "Git user.email: $(git config user.email)"
  else
    warn "Git user.email not set"
    echo "  Set: git config --global user.email \"you@example.com\""
  fi
  echo ""

  # Check 8: Dotfiles Repository
  echo "━━━ Dotfiles Repository ━━━"
  if [[ -d "$DOTFILES/.git" ]]; then
    success "Dotfiles is a git repository"

    cd "$DOTFILES"
    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [[ -n "$branch" ]]; then
      echo "  Branch: $branch"
    fi

    local status=$(git status --porcelain 2>/dev/null)
    if [[ -z "$status" ]]; then
      success "No uncommitted changes"
    else
      warn "Uncommitted changes detected"
      echo "  Run: cd $DOTFILES && git status"
    fi
  else
    error "Dotfiles directory is not a git repository"
    has_issues=true
  fi
  echo ""

  # Summary
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  if $has_issues; then
    error "Issues found - see above for details"
    echo ""
    exit 1
  else
    success "All checks passed!"
    echo ""
    info "Your dotfiles setup looks healthy ✨"
  fi
}
