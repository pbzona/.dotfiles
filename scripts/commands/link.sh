#!/usr/bin/env bash
# Link dotfiles using GNU Stow

cmd_link() {
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
dot link - Link dotfiles using GNU Stow

Usage:
  dot link [options]

Options:
  --dry-run   Show what would be linked without making changes
  --help      Show this help message

Description:
  Uses GNU Stow to create symlinks from ~/dotfiles/home/ to your home directory.
  This will link all configuration files, including:
  - Shell configs (.zshrc, .tmux.conf)
  - Application configs (.config/nvim, .config/wezterm, .config/opencode, etc.)
  - Aerospace window manager config

  Stow will skip files that already exist and are identical.

Examples:
  dot link              # Link all dotfiles
  dot link --dry-run    # Preview what would be linked
EOF
    exit 0
  fi

  info "Linking dotfiles with GNU Stow..."

  # Check if stow is installed
  if ! command -v stow &> /dev/null; then
    error "GNU Stow is not installed!"
    echo ""
    info "Install it with:"
    echo "  macOS:  brew install stow"
    echo "  Linux:  sudo apt install stow"
    exit 1
  fi

  cd "$DOTFILES"

  # Build stow command
  local stow_cmd="stow --dotfiles --target=$HOME home"

  if $dry_run; then
    stow_cmd="$stow_cmd --simulate --verbose"
    warn "DRY RUN - No changes will be made"
    echo ""
  fi

  # Run stow
  if $dry_run; then
    info "Running: $stow_cmd"
    echo ""
    $stow_cmd 2>&1 | while IFS= read -r line; do
      echo "  $line"
    done
    echo ""
    warn "DRY RUN complete - No changes were made"
  else
    if $stow_cmd; then
      success "Dotfiles linked successfully!"
      echo ""
      info "Configuration files are now symlinked to:"
      echo "  ~/.zshrc"
      echo "  ~/.tmux.conf"
      echo "  ~/.aerospace.toml"
      echo "  ~/.config/nvim"
      echo "  ~/.config/wezterm"
      echo "  ~/.config/opencode"
      echo "  ~/.config/mise"
      echo ""
      info "You may need to restart your terminal for changes to take effect"
    else
      error "Stow failed! See error messages above."
      echo ""
      info "Common issues:"
      echo "  - Files already exist and conflict (backup and remove them first)"
      echo "  - Permission issues (check file ownership)"
      echo ""
      info "Run 'dot doctor' to diagnose issues"
      exit 1
    fi
  fi
}
