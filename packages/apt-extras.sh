#!/usr/bin/env bash
# Install packages that require third-party repos on Ubuntu LTS.
# Idempotent: checks before adding repos or installing.
#
# Usage: sudo bash apt-extras.sh [--dry-run]

set -euo pipefail

source "$(dirname "$0")/../scripts/lib.sh"

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

DISTRO=$(detect_distro)
DISTRO_VERSION=$(detect_distro_version)

info() { echo -e "\033[0;34m\u2139\033[0m $1"; }
success() { echo -e "\033[0;32m\u2713\033[0m $1"; }
warn() { echo -e "\033[1;33m\u26a0\033[0m $1"; }

# ---------- GitHub CLI (gh) ----------
if command -v gh &> /dev/null; then
  success "gh already installed"
else
  info "Installing GitHub CLI (gh)..."
  if $DRY_RUN; then
    warn "DRY RUN - would add GitHub CLI repo and install gh"
  else
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update -qq
    sudo apt install -y gh
    success "gh installed"
  fi
fi

# ---------- eza ----------
if command -v eza &> /dev/null; then
  success "eza already installed"
else
  info "Installing eza..."
  if $DRY_RUN; then
    warn "DRY RUN - would add eza repo and install"
  else
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
      | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
      | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update -qq
    sudo apt install -y eza
    success "eza installed"
  fi
fi

# ---------- Neovim PPA (22.04 only -- 24.04+ has a recent enough version) ----------
if [[ "$DISTRO" == "ubuntu" && "${DISTRO_VERSION%%.*}" -le 22 ]]; then
  if dpkg -s neovim 2>/dev/null | grep -q "Version: 0\.[89]\|Version: 0\.1[0-9]"; then
    success "neovim (recent) already installed via PPA"
  else
    info "Adding Neovim PPA for Ubuntu $DISTRO_VERSION..."
    if $DRY_RUN; then
      warn "DRY RUN - would add neovim-ppa/unstable and upgrade neovim"
    else
      sudo add-apt-repository -y ppa:neovim-ppa/unstable
      sudo apt update -qq
      sudo apt install -y neovim
      success "neovim upgraded via PPA"
    fi
  fi
fi

# ---------- Tailscale ----------
if command -v tailscale &> /dev/null; then
  success "tailscale already installed"
else
  info "Installing Tailscale..."
  if $DRY_RUN; then
    warn "DRY RUN - would install tailscale via official script"
  else
    curl -fsSL https://tailscale.com/install.sh | sh
    success "tailscale installed"
  fi
fi
