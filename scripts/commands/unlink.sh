#!/usr/bin/env bash
# Unlink dotfiles (remove symlinks)

cmd_unlink() {
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
dot unlink - Remove dotfile symlinks

Usage:
  dot unlink [options]

Options:
  --dry-run   Show what would be removed without making changes
  --help      Show this help message

Description:
  Uses GNU Stow to remove symlinks created by 'dot link'.
  This will NOT delete your actual configuration files, only the symlinks.

Examples:
  dot unlink              # Remove all dotfile symlinks
  dot unlink --dry-run    # Preview what would be removed
EOF
    exit 0
  fi

  info "Unlinking dotfiles with GNU Stow..."

  # Check if stow is installed
  if ! command -v stow &> /dev/null; then
    error "GNU Stow is not installed!"
    exit 1
  fi

  cd "$DOTFILES"

  # Build stow command
  local stow_cmd="stow --dotfiles --target=$HOME --delete home"

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
      success "Dotfiles unlinked successfully!"
      echo ""
      info "Symlinks have been removed. Your actual config files remain in:"
      echo "  $DOTFILES/home/"
    else
      error "Stow failed! See error messages above."
      exit 1
    fi
  fi
}
