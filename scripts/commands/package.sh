#!/usr/bin/env bash
# Manage Brewfile packages

cmd_package() {
  local subcommand="${1:-}"
  shift || true

  case "$subcommand" in
    add)
      package_add "$@"
      ;;
    remove|rm)
      package_remove "$@"
      ;;
    list|ls)
      package_list "$@"
      ;;
    sync)
      package_sync "$@"
      ;;
    cleanup)
      package_cleanup "$@"
      ;;
    --help|-h|help|"")
      package_help
      ;;
    *)
      error "Unknown subcommand: $subcommand"
      echo ""
      package_help
      exit 1
      ;;
  esac
}

package_help() {
  cat << EOF
dot package - Manage Brewfile packages

Usage:
  dot package <subcommand> [options]

Subcommands:
  add <package>      Add package to Brewfile and install
  remove <package>   Remove package from Brewfile and uninstall
  list               List all packages in Brewfile
  sync               Sync installed packages with Brewfile
  cleanup            Update Brewfile to match currently installed packages

Examples:
  dot package add bat           # Add and install bat
  dot package remove nushell    # Remove and uninstall nushell
  dot package list              # Show all Brewfile packages
  dot package sync              # Install missing Brewfile packages
  dot package cleanup           # Update Brewfile with current packages
EOF
}

package_add() {
  local package="$1"
  local dry_run=false

  if [[ -z "$package" ]]; then
    error "Package name required"
    echo "Usage: dot package add <package>"
    exit 1
  fi

  # Check if --dry-run flag
  if [[ "$2" == "--dry-run" ]] || [[ "$package" == "--dry-run" ]]; then
    dry_run=true
    package="${package/--dry-run/}"
    package=$(echo "$package" | xargs)  # trim whitespace
  fi

  if [[ ! -f "$DOTFILES/packages/Brewfile" ]]; then
    error "Brewfile not found at $DOTFILES/packages/Brewfile"
    exit 1
  fi

  # Check if package already in Brewfile
  if grep -q "^brew \"$package\"\\|^cask \"$package\"\\|^brew \".*/$package\"" "$DOTFILES/packages/Brewfile"; then
    warn "Package '$package' already in Brewfile"
    exit 0
  fi

  info "Adding package: $package"

  if $dry_run; then
    warn "DRY RUN - Would add to Brewfile and install"
    exit 0
  fi

  # Determine if it's a cask or formula
  if brew info --cask "$package" &> /dev/null; then
    echo "cask \"$package\"" >> "$DOTFILES/packages/Brewfile"
    info "Added as cask"
  elif brew info "$package" &> /dev/null; then
    echo "brew \"$package\"" >> "$DOTFILES/packages/Brewfile"
    info "Added as formula"
  else
    error "Package '$package' not found in Homebrew"
    exit 1
  fi

  # Install the package
  info "Installing $package..."
  brew install "$package" || brew install --cask "$package"

  success "Package '$package' added and installed"
  echo ""
  info "Brewfile updated at: $DOTFILES/packages/Brewfile"
}

package_remove() {
  local package="$1"
  local dry_run=false

  if [[ -z "$package" ]]; then
    error "Package name required"
    echo "Usage: dot package remove <package>"
    exit 1
  fi

  if [[ "$2" == "--dry-run" ]] || [[ "$package" == "--dry-run" ]]; then
    dry_run=true
    package="${package/--dry-run/}"
    package=$(echo "$package" | xargs)
  fi

  if [[ ! -f "$DOTFILES/packages/Brewfile" ]]; then
    error "Brewfile not found at $DOTFILES/packages/Brewfile"
    exit 1
  fi

  # Check if package in Brewfile
  if ! grep -q "^brew \"$package\"\\|^cask \"$package\"\\|^brew \".*/$package\"" "$DOTFILES/packages/Brewfile"; then
    warn "Package '$package' not found in Brewfile"
    exit 0
  fi

  info "Removing package: $package"

  if $dry_run; then
    warn "DRY RUN - Would remove from Brewfile and uninstall"
    exit 0
  fi

  # Remove from Brewfile
  # Use a temp file to safely edit
  local temp_file=$(mktemp)
  grep -v "^brew \"$package\"\\|^cask \"$package\"\\|^brew \".*/$package\"" "$DOTFILES/packages/Brewfile" > "$temp_file"
  mv "$temp_file" "$DOTFILES/packages/Brewfile"

  # Uninstall the package
  info "Uninstalling $package..."
  brew uninstall "$package" 2>/dev/null || brew uninstall --cask "$package" 2>/dev/null || true

  success "Package '$package' removed"
  echo ""
  info "Brewfile updated at: $DOTFILES/packages/Brewfile"
}

package_list() {
  if [[ ! -f "$DOTFILES/packages/Brewfile" ]]; then
    error "Brewfile not found at $DOTFILES/packages/Brewfile"
    exit 1
  fi

  info "Packages in Brewfile:"
  echo ""

  echo "Formulas:"
  grep "^brew " "$DOTFILES/packages/Brewfile" | sed 's/brew "\(.*\)"/  - \1/' | sed 's/".*$//'

  echo ""
  echo "Casks:"
  grep "^cask " "$DOTFILES/packages/Brewfile" | sed 's/cask "\(.*\)"/  - \1/' | sed 's/".*$//'

  echo ""
  local formula_count=$(grep -c "^brew " "$DOTFILES/packages/Brewfile")
  local cask_count=$(grep -c "^cask " "$DOTFILES/packages/Brewfile")
  info "Total: $formula_count formulas, $cask_count casks"
}

package_sync() {
  local dry_run=false

  if [[ "$1" == "--dry-run" ]]; then
    dry_run=true
  fi

  if [[ ! -f "$DOTFILES/packages/Brewfile" ]]; then
    error "Brewfile not found at $DOTFILES/packages/Brewfile"
    exit 1
  fi

  info "Syncing packages with Brewfile..."

  if $dry_run; then
    warn "DRY RUN - Would run: brew bundle install"
    cd "$DOTFILES/packages"
    brew bundle list | while IFS= read -r line; do
      echo "  $line"
    done
  else
    cd "$DOTFILES/packages"
    brew bundle install
    success "Packages synced"
  fi
}

package_cleanup() {
  local dry_run=false

  if [[ "$1" == "--dry-run" ]]; then
    dry_run=true
  fi

  info "Cleaning up Brewfile..."
  warn "This will regenerate Brewfile from currently installed packages"
  echo ""

  if $dry_run; then
    warn "DRY RUN - Would run: brew bundle dump --force"
  else
    cd "$DOTFILES/packages"
    brew bundle dump --force
    success "Brewfile regenerated"
    echo ""
    info "Review changes with: cd $DOTFILES/packages && git diff Brewfile"
  fi
}
