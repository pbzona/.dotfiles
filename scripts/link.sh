#!/usr/bin/env bash

DOTFILES="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"
BACKUP_CONFIG="$HOME/.backup_config"
MANIFEST="$DOTFILES/links.manifest"

# Make dirs if they don't already exist
mkdir -p $CONFIG_DIR
mkdir -p "$BACKUP_CONFIG/.config"

# Usage: create_backup_config <original config> <backup filename>
create_backup_config() {
  if [ -e $1 ]; then
    echo "Creating backup of $1 in $BACKUP_CONFIG"
    mv $1 "$BACKUP_CONFIG/$2.bak-$(date +%s)"
  fi
}

# Link entries from manifest file, optionally filtered by tag
# Usage: link_from_manifest [tag]
link_from_manifest() {
  local filter_tag="$1"

  if [[ ! -f "$MANIFEST" ]]; then
    echo "Error: Manifest file not found at $MANIFEST"
    echo "Expected location: $MANIFEST"
    return 1
  fi

  echo "Reading manifest from $MANIFEST"
  if [[ -n "$filter_tag" ]]; then
    echo "Filtering by tag: $filter_tag"
  fi
  echo ""

  local linked_count=0
  local skipped_count=0

  while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    # Parse line: source destination [tags]
    read -r source dest tags <<< "$line"

    # Skip if filtering and tags don't match
    if [[ -n "$filter_tag" ]]; then
      if [[ -z "$tags" ]] || [[ ! ",$tags," =~ ,"$filter_tag", ]]; then
        ((skipped_count++))
        continue
      fi
    fi

    # Expand tilde in destination
    dest="${dest/#\~/$HOME}"

    # Create parent directory if needed
    dest_dir=$(dirname "$dest")
    mkdir -p "$dest_dir"

    # Create the link
    echo "Linking: $source -> $dest"
    create_backup_config "$dest" "$(basename "$dest")"

    if [[ -e "$DOTFILES/$source" ]]; then
      ln -sf "$DOTFILES/$source" "$dest"
      echo "  ✓ Linked successfully"
      ((linked_count++))
    else
      echo "  ✗ Warning: Source does not exist: $DOTFILES/$source"
    fi
    echo ""

  done < "$MANIFEST"

  echo "Summary: $linked_count linked"
  if [[ $skipped_count -gt 0 ]]; then
    echo "         $skipped_count skipped (tag mismatch)"
  fi
}

# Functions for each application (includes special setup steps)
link_neovim() {
  echo "=== Setting up Neovim ==="
  echo ""

  # Clean neovim state for fresh start
  if [[ -d "$HOME/.local/share/nvim" ]] || [[ -d "$HOME/.local/state/nvim" ]]; then
    echo "Cleaning neovim state directories..."
    rm -rf "$HOME/.local/share/nvim" "$HOME/.local/state/nvim"
    echo "  ✓ Cleaned"
    echo ""
  fi

  # Link from manifest
  link_from_manifest "nvim"
}

link_tmux() {
  echo "=== Setting up tmux ==="
  echo ""

  # Install tpm (tmux plugin manager) if not already present
  if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    echo "Installing tmux plugin manager (tpm)..."
    mkdir -p "$HOME/.tmux/plugins"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "  ✓ Installed tpm"
    echo ""
  fi

  # Link from manifest
  link_from_manifest "tmux"

  echo "Note: Press c-space + I inside tmux to install plugins"
}

link_zsh() {
  echo "=== Setting up zsh ==="
  echo ""
  link_from_manifest "zsh"
}

# Show usage information
show_usage() {
  echo "Usage: $0 {nvim|neovim|tmux|zsh|all|manifest} [--help]"
  echo ""
  echo "Options:"
  echo "  nvim, neovim  - Link neovim config (cleans state directories first)"
  echo "  tmux          - Link tmux config (installs tpm if needed)"
  echo "  zsh           - Link zsh config"
  echo "  all           - Link all configs with special setup steps"
  echo "  manifest      - Link all configs from manifest (basic linking only)"
  echo ""
  echo "Run without arguments to link everything from manifest."
  echo ""
  echo "The manifest file is located at: $MANIFEST"
  echo "Edit it to add or remove configurations."
}

# Parse arguments
case "$1" in
  nvim | neovim)
    link_neovim
    ;;
  tmux)
    link_tmux
    ;;
  zsh)
    link_zsh
    ;;
  mac)
    echo "TODO: put macos specific configs here"
    ;;
  all)
    echo "=== Linking all configurations ==="
    echo ""
    link_neovim
    echo ""
    link_tmux
    echo ""
    link_zsh
    ;;
  manifest)
    # Link everything in manifest without filtering
    link_from_manifest
    ;;
  --help | -h | help)
    show_usage
    ;;
  "")
    # No arguments: link everything from manifest
    echo "=== Linking all configurations from manifest ==="
    echo ""
    link_from_manifest
    ;;
  *)
    echo "Error: Unknown option '$1'"
    echo ""
    show_usage
    exit 1
  ;;
esac
