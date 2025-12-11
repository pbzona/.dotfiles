#!/usr/bin/env bash
# Initial setup for a new machine

cmd_setup() {
  local dry_run=false
  local show_help=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        dry_run=true
        shift
        ;;
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
dot setup - Initial setup for a new machine

Usage:
  dot setup [options]

Options:
  --dry-run   Show what would be installed without making changes
  --help      Show this help message

Description:
  Performs initial setup on a new machine:
  1. Creates necessary directories (~/.local/bin, etc.)
  2. Verifies zsh is the default shell
  3. Installs Homebrew (macOS only)
  4. Installs packages from Brewfile
  5. Installs mise (runtime version manager)
  6. Installs eget (binary downloader)
  7. Links dotfiles with Stow
  8. Runs mise install for configured tools

Examples:
  dot setup              # Run full setup
  dot setup --dry-run    # Preview what would be installed
EOF
    exit 0
  fi

  if $dry_run; then
    warn "DRY RUN MODE - No changes will be made"
    echo ""
  fi

  # Source lib for OS detection
  source "$DOTFILES/scripts/lib.sh"
  local OS=$(detect_os)

  # Check prerequisites
  info "Checking prerequisites..."

  # Check for zsh
  if [[ ! "$(echo $SHELL | tr '/' '\n' | tail -n 1)" == "zsh" ]]; then
    error "Zsh is not your default shell"
    echo ""
    info "Set zsh as default with:"
    echo "  chsh -s \$(which zsh)"
    if ! $dry_run; then
      exit 1
    fi
  else
    success "Zsh is default shell"
  fi

  # Source private environment variables if they exist
  if [[ -f "$HOME/.privaterc" ]]; then
    if $dry_run; then
      info "Would source ~/.privaterc"
    else
      source "$HOME/.privaterc"
      success "Sourced ~/.privaterc"
    fi
  fi

  # Create directories
  info "Setting up directories..."
  if $dry_run; then
    info "Would create: ~/.local/{bin,share,state}"
  else
    mkdir -p "$HOME/.local/{bin,share,state}"
    export PATH="$HOME/.local/bin:$PATH"
    success "Created ~/.local directories"
  fi

  # Install Homebrew (macOS only)
  if [[ $OS == "macos" ]]; then
    info "Checking Homebrew installation..."
    if ! command -v brew &> /dev/null; then
      if $dry_run; then
        warn "Homebrew not found - would install"
      else
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
        success "Homebrew installed"
      fi
    else
      success "Homebrew already installed"
    fi

    # Install packages from Brewfile
    if [[ -f "$DOTFILES/packages/Brewfile" ]]; then
      info "Installing packages from Brewfile..."
      if $dry_run; then
        cd "$DOTFILES/packages"
        brew bundle list | while IFS= read -r line; do
          echo "  Would install: $line"
        done
      else
        cd "$DOTFILES/packages"
        brew bundle install
        success "Brewfile packages installed"
      fi
    fi
  fi

  # Install mise
  info "Installing mise..."
  if command -v mise &> /dev/null; then
    success "Mise already installed"
  else
    if $dry_run; then
      info "Would install mise from https://mise.run"
    else
      curl "https://mise.run" | sh
      export PATH="$HOME/.local/bin:$PATH"
      success "Mise installed"
    fi
  fi

  # Install eget (keep for future use)
  info "Installing eget..."
  if [[ -f "$HOME/.local/bin/eget" ]]; then
    success "Eget already installed"
  else
    if $dry_run; then
      info "Would install eget from https://zyedidia.github.io/eget.sh"
    else
      curl https://zyedidia.github.io/eget.sh | sh
      mv ./eget "$HOME/.local/bin/" 2>/dev/null || true
      success "Eget installed"
    fi
  fi

  # Link dotfiles
  info "Linking dotfiles..."
  if $dry_run; then
    info "Would run: dot link"
  else
    # Check if stow is installed
    if ! command -v stow &> /dev/null; then
      warn "GNU Stow not installed - skipping linking"
      echo ""
      info "Install stow and run: dot link"
    else
      source "$COMMANDS_DIR/link.sh"
      cmd_link
    fi
  fi

  # Install mise tools
  if command -v mise &> /dev/null; then
    info "Installing mise tools..."
    if $dry_run; then
      info "Would run: mise install"
    else
      mise install
      success "Mise tools installed"
    fi
  fi

  # Python tools
  if command -v uv &> /dev/null; then
    info "Installing Python tools..."
    if $dry_run; then
      info "Would install: posting (TUI REST API client)"
    else
      uv tool install --python 3.12 posting
      success "Python tools installed"
    fi
  else
    warn "uv not found - skipping Python tools"
    info "Install uv with mise or manually to enable Python tool installation"
  fi

  # Ensure fzf-tmux wrapper is available (required by tmux-sessionx plugin)
  info "Setting up fzf-tmux wrapper..."
  if command -v fzf &> /dev/null; then
    if ! command -v fzf-tmux &> /dev/null; then
      if $dry_run; then
        info "Would download fzf-tmux wrapper to ~/.local/bin"
      else
        curl -fsSL https://raw.githubusercontent.com/junegunn/fzf/master/bin/fzf-tmux -o "$HOME/.local/bin/fzf-tmux"
        chmod +x "$HOME/.local/bin/fzf-tmux"
        success "fzf-tmux wrapper installed"
      fi
    else
      success "fzf-tmux already available"
    fi
  else
    warn "fzf not installed - skipping fzf-tmux setup"
  fi

  # TPM (Tmux Plugin Manager)
  info "Setting up Tmux Plugin Manager..."
  if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    if $dry_run; then
      info "Would clone TPM to ~/.tmux/plugins/tpm"
      info "Would install tmux plugins"
    else
      git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
      success "TPM cloned"

      # Install plugins
      if [[ -f "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]]; then
        info "Installing tmux plugins..."
        tmux start-server 2>/dev/null || true
        tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.tmux/plugins" 2>/dev/null || true
        "$HOME/.tmux/plugins/tpm/bin/install_plugins"
        success "Tmux plugins installed"
      fi
    fi
  else
    success "TPM already installed"

    # Check if plugins are installed
    local plugin_count=$(find "$HOME/.tmux/plugins" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
    if [[ $plugin_count -eq 1 ]]; then
      # Only tpm directory exists, no plugins
      if $dry_run; then
        info "Would install tmux plugins"
      else
        info "Installing tmux plugins..."
        tmux start-server 2>/dev/null || true
        tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.tmux/plugins" 2>/dev/null || true
        "$HOME/.tmux/plugins/tpm/bin/install_plugins"
        success "Tmux plugins installed"
      fi
    else
      success "Tmux plugins already installed ($((plugin_count - 1)) plugins)"
    fi
  fi

  # macOS-specific defaults
  if [[ $OS == "macos" ]]; then
    info "Setting macOS defaults..."
    if $dry_run; then
      info "Would set: NSWindowShouldDragOnGesture = true"
    else
      defaults write -g NSWindowShouldDragOnGesture -bool true
      success "macOS defaults configured"
    fi
  fi

  echo ""
  if $dry_run; then
    warn "DRY RUN complete - No changes were made"
    echo ""
    info "Run 'dot setup' without --dry-run to apply changes"
  else
    success "Setup complete!"
    echo ""
    info "Next steps:"
    echo "  1. Restart your terminal"
    echo "  2. Run 'dot doctor' to verify setup"
    echo "  3. Customize your configs in $DOTFILES/home/"
  fi
}
