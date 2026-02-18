#!/usr/bin/env bash
# Update packages and tools

cmd_update() {
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
dot update - Update packages and tools

Usage:
  dot update [options]

Options:
  --dry-run   Show what would be updated without making changes
  --help      Show this help message

Description:
  Updates all managed packages and tools:
  1. Homebrew packages (from Brewfile)
  2. mise-managed tools
  3. Dotfiles repository (git pull)

  This command ensures all your tools stay up to date.

Examples:
  dot update              # Update everything
  dot update --dry-run    # Preview updates
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

  # Update Homebrew packages (macOS)
  if [[ $OS == "macos" ]]; then
    if command -v brew &> /dev/null; then
      info "Updating Homebrew..."
      if $dry_run; then
        info "Would run: brew update && brew upgrade && brew cleanup"
        if [[ -f "$DOTFILES/Brewfile" ]]; then
          info "Would run: brew bundle check --file=$DOTFILES/Brewfile"
        fi
      else
        brew update
        brew upgrade
        brew cleanup
        success "Homebrew updated"

        # Check Brewfile sync
        if [[ -f "$DOTFILES/packages/Brewfile" ]]; then
          info "Checking Brewfile sync..."
          cd "$DOTFILES/packages"
          if brew bundle check &> /dev/null; then
            success "Brewfile in sync"
          else
            warn "Brewfile out of sync"
            echo ""
            info "Run 'brew bundle install' from packages/ to sync"
            echo "Or run 'dot package sync' to install missing packages"
          fi
        fi
      fi
      echo ""
    fi
  fi

  # Update apt packages (Linux)
  if [[ $OS == "linux" ]]; then
    info "Updating apt packages..."
    if $dry_run; then
      info "Would run: sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y"
    else
      sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
      success "apt packages updated"

      # Check apt.txt sync
      if [[ -f "$DOTFILES/packages/apt.txt" ]]; then
        info "Checking apt.txt sync..."
        local missing=()
        while IFS= read -r line; do
          line="${line%%#*}"
          line="$(echo "$line" | xargs)"
          [[ -z "$line" ]] && continue
          if ! dpkg -s "$line" &> /dev/null; then
            missing+=("$line")
          fi
        done < "$DOTFILES/packages/apt.txt"

        if [[ ${#missing[@]} -eq 0 ]]; then
          success "apt.txt in sync"
        else
          warn "apt.txt out of sync - missing: ${missing[*]}"
          echo ""
          info "Run 'dot package sync' to install missing packages"
        fi
      fi
    fi
    echo ""
  fi

  # Update mise tools
  if command -v mise &> /dev/null; then
    info "Updating mise tools..."
    if $dry_run; then
      info "Would run: mise upgrade"
    else
      mise upgrade
      success "Mise tools updated"
    fi
    echo ""
  fi

  # Update dotfiles repository
  if [[ -d "$DOTFILES/.git" ]]; then
    info "Updating dotfiles repository..."
    cd "$DOTFILES"

    if $dry_run; then
      info "Would run: git pull"
      local remote=$(git remote get-url origin 2>/dev/null || echo "unknown")
      echo "  Remote: $remote"
    else
      local before=$(git rev-parse HEAD)
      git pull

      local after=$(git rev-parse HEAD)
      if [[ "$before" != "$after" ]]; then
        success "Dotfiles updated"
        echo ""
        info "Changes:"
        git log --oneline --decorate --graph "$before..$after"
        echo ""
        warn "Dotfiles changed - you may need to:"
        echo "  1. Run 'dot link' to update symlinks"
        echo "  2. Restart your terminal"
      else
        success "Dotfiles already up to date"
      fi
    fi
    echo ""
  fi

  if $dry_run; then
    warn "DRY RUN complete - No changes were made"
  else
    success "Update complete!"
    echo ""
    info "Run 'dot doctor' to verify everything is healthy"
  fi
}
