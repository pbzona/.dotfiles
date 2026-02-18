#!/usr/bin/env bash
# Manage system packages

# Source lib for OS detection
source "$DOTFILES/scripts/lib.sh"
_PKG_OS=$(detect_os)

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
  if [[ $_PKG_OS == "macos" ]]; then
    local pkg_file="Brewfile"
  else
    local pkg_file="apt.txt"
  fi

  cat << EOF
dot package - Manage system packages

Usage:
  dot package <subcommand> [options]

Subcommands:
  add <package>      Add package to $pkg_file and install
  remove <package>   Remove package from $pkg_file and uninstall
  list               List all packages in $pkg_file
  sync               Sync installed packages with $pkg_file
  cleanup            Update $pkg_file to match currently installed packages (macOS only)

Examples:
  dot package add bat           # Add and install bat
  dot package remove nushell    # Remove and uninstall nushell
  dot package list              # Show all managed packages
  dot package sync              # Install missing packages
EOF
}

# =============================================================================
# Dispatch functions
# =============================================================================

package_add() {
  if [[ $_PKG_OS == "macos" ]]; then
    package_add_brew "$@"
  else
    package_add_apt "$@"
  fi
}

package_remove() {
  if [[ $_PKG_OS == "macos" ]]; then
    package_remove_brew "$@"
  else
    package_remove_apt "$@"
  fi
}

package_list() {
  if [[ $_PKG_OS == "macos" ]]; then
    package_list_brew "$@"
  else
    package_list_apt "$@"
  fi
}

package_sync() {
  if [[ $_PKG_OS == "macos" ]]; then
    package_sync_brew "$@"
  else
    package_sync_apt "$@"
  fi
}

package_cleanup() {
  if [[ $_PKG_OS == "macos" ]]; then
    package_cleanup_brew "$@"
  else
    warn "cleanup is not supported on Linux"
    info "Edit $DOTFILES/packages/apt.txt directly"
  fi
}

# =============================================================================
# apt implementations
# =============================================================================

_apt_txt() { echo "$DOTFILES/packages/apt.txt"; }

# Read apt.txt into an array, stripping comments and blanks
_read_apt_packages() {
  local packages=()
  while IFS= read -r line; do
    line="${line%%#*}"
    line="$(echo "$line" | xargs)"
    [[ -n "$line" ]] && packages+=("$line")
  done < "$(_apt_txt)"
  echo "${packages[@]}"
}

package_add_apt() {
  local package="$1"
  local dry_run=false

  if [[ -z "$package" ]]; then
    error "Package name required"
    echo "Usage: dot package add <package>"
    exit 1
  fi

  if [[ "${2:-}" == "--dry-run" ]] || [[ "$package" == "--dry-run" ]]; then
    dry_run=true
    package="${package/--dry-run/}"
    package=$(echo "$package" | xargs)
  fi

  local apt_file="$(_apt_txt)"
  if [[ ! -f "$apt_file" ]]; then
    error "apt.txt not found at $apt_file"
    exit 1
  fi

  # Check if already listed (ignoring comments)
  if grep -qE "^${package}\s*(#.*)?$" "$apt_file"; then
    warn "Package '$package' already in apt.txt"
    exit 0
  fi

  info "Adding package: $package"

  if $dry_run; then
    warn "DRY RUN - Would add to apt.txt and install"
    exit 0
  fi

  # Verify the package exists in apt
  if ! apt-cache show "$package" &> /dev/null; then
    error "Package '$package' not found in apt repositories"
    exit 1
  fi

  echo "$package" >> "$apt_file"
  sudo apt install -y "$package"

  success "Package '$package' added and installed"
  echo ""
  info "apt.txt updated at: $apt_file"
}

package_remove_apt() {
  local package="$1"
  local dry_run=false

  if [[ -z "$package" ]]; then
    error "Package name required"
    echo "Usage: dot package remove <package>"
    exit 1
  fi

  if [[ "${2:-}" == "--dry-run" ]] || [[ "$package" == "--dry-run" ]]; then
    dry_run=true
    package="${package/--dry-run/}"
    package=$(echo "$package" | xargs)
  fi

  local apt_file="$(_apt_txt)"
  if [[ ! -f "$apt_file" ]]; then
    error "apt.txt not found at $apt_file"
    exit 1
  fi

  if ! grep -qE "^${package}\s*(#.*)?$" "$apt_file"; then
    warn "Package '$package' not found in apt.txt"
    exit 0
  fi

  info "Removing package: $package"

  if $dry_run; then
    warn "DRY RUN - Would remove from apt.txt and uninstall"
    exit 0
  fi

  # Remove from apt.txt
  local temp_file=$(mktemp)
  grep -vE "^${package}\s*(#.*)?$" "$apt_file" > "$temp_file"
  mv "$temp_file" "$apt_file"

  sudo apt remove -y "$package"

  success "Package '$package' removed"
  echo ""
  info "apt.txt updated at: $apt_file"
}

package_list_apt() {
  local apt_file="$(_apt_txt)"
  if [[ ! -f "$apt_file" ]]; then
    error "apt.txt not found at $apt_file"
    exit 1
  fi

  info "Packages in apt.txt:"
  echo ""

  local count=0
  while IFS= read -r line; do
    local stripped="${line%%#*}"
    stripped="$(echo "$stripped" | xargs)"
    [[ -z "$stripped" ]] && continue
    if dpkg -s "$stripped" &> /dev/null; then
      echo "  - $stripped (installed)"
    else
      echo "  - $stripped (missing)"
    fi
    ((count++))
  done < "$apt_file"

  echo ""
  info "Total: $count packages"
}

package_sync_apt() {
  local dry_run=false
  if [[ "${1:-}" == "--dry-run" ]]; then
    dry_run=true
  fi

  local apt_file="$(_apt_txt)"
  if [[ ! -f "$apt_file" ]]; then
    error "apt.txt not found at $apt_file"
    exit 1
  fi

  info "Syncing packages with apt.txt..."

  local packages=()
  while IFS= read -r line; do
    line="${line%%#*}"
    line="$(echo "$line" | xargs)"
    [[ -n "$line" ]] && packages+=("$line")
  done < "$apt_file"

  # Find missing packages
  local missing=()
  for pkg in "${packages[@]}"; do
    if ! dpkg -s "$pkg" &> /dev/null; then
      missing+=("$pkg")
    fi
  done

  if [[ ${#missing[@]} -eq 0 ]]; then
    success "All packages already installed"
    return
  fi

  info "Missing packages: ${missing[*]}"

  if $dry_run; then
    warn "DRY RUN - Would install: ${missing[*]}"
  else
    sudo apt install -y "${missing[@]}"
    success "Packages synced"
  fi
}

# =============================================================================
# Homebrew implementations (macOS)
# =============================================================================

package_add_brew() {
  local package="$1"
  local dry_run=false

  if [[ -z "$package" ]]; then
    error "Package name required"
    echo "Usage: dot package add <package>"
    exit 1
  fi

  # Check if --dry-run flag
  if [[ "${2:-}" == "--dry-run" ]] || [[ "$package" == "--dry-run" ]]; then
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

package_remove_brew() {
  local package="$1"
  local dry_run=false

  if [[ -z "$package" ]]; then
    error "Package name required"
    echo "Usage: dot package remove <package>"
    exit 1
  fi

  if [[ "${2:-}" == "--dry-run" ]] || [[ "$package" == "--dry-run" ]]; then
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

package_list_brew() {
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

package_sync_brew() {
  local dry_run=false

  if [[ "${1:-}" == "--dry-run" ]]; then
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

package_cleanup_brew() {
  local dry_run=false

  if [[ "${1:-}" == "--dry-run" ]]; then
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
