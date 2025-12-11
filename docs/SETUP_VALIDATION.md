# Setup & Installation Guide

This guide walks through setting up dotfiles on a fresh machine using the `./dot` CLI.

---

## Prerequisites

Before starting, ensure you have:

1. **macOS** (Darwin) or **Linux** (Ubuntu/Debian)
2. **zsh** as your default shell
   ```bash
   echo $SHELL  # Should show: /bin/zsh or similar
   # If not, change it:
   chsh -s $(which zsh)
   ```
3. **Git** installed (to clone this repo)
4. **Internet connection** (for downloading tools)

---

## Quick Start

```bash
# 1. Clone dotfiles
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles

# 2. Preview what will be installed
./dot setup --dry-run

# 3. Run full setup
./dot setup

# 4. Restart terminal and verify
./dot doctor
```

---

## What `dot setup` Does

The setup command handles everything automatically:

1. ✓ Creates `~/.local/{bin,share,state}` directories
2. ✓ Verifies zsh is your default shell
3. ✓ Installs Homebrew (macOS only)
4. ✓ Installs all packages from `packages/Brewfile`
5. ✓ Installs mise (runtime version manager)
6. ✓ Installs eget (binary downloader utility)
7. ✓ Ensures fzf-tmux wrapper is available (for tmux sessionx plugin)
8. ✓ Clones and sets up Tmux Plugin Manager (TPM)
9. ✓ Installs all tmux plugins
10. ✓ Links dotfiles using GNU Stow
11. ✓ Installs mise tools (languages and CLI utilities)
12. ✓ Installs Python tools via uv
13. ✓ Sets macOS defaults (macOS only)

### Safety Features

- **Idempotent**: Can be run multiple times safely
- **Checks first**: Won't reinstall if already present
- **Dry-run support**: Preview with `./dot setup --dry-run`
- **Non-destructive**: Uses package managers and symlinks

---

## Installation Steps (Detailed)

### Step 1: Clone Repository

```bash
cd ~
git clone <your-repo-url> .dotfiles
cd .dotfiles
```

### Step 2: Preview Setup (Optional)

```bash
./dot setup --dry-run
```

This shows what would be installed without making any changes.

### Step 3: Run Setup

```bash
./dot setup
```

**What to expect:**
- Homebrew installation will prompt for password (macOS)
- Package installation takes 5-15 minutes depending on network
- Tmux plugin installation may show warnings (safe to ignore)
- You'll see colored output: ✓ (success), ⚠ (warning), ℹ (info)

### Step 4: Restart Terminal

Close and reopen your terminal to load new configurations.

### Step 5: Verify Installation

```bash
./dot doctor
```

This runs comprehensive health checks and reports any issues.

---

## Package Management

All system packages are managed in `packages/Brewfile`:

### View installed packages
```bash
./dot package list
```

### Add a new package
```bash
./dot package add bat
```

### Remove a package
```bash
./dot package remove bat
```

### Sync Brewfile (install missing packages)
```bash
./dot package sync
```

---

## Configuration Management

Dotfiles are symlinked using **GNU Stow**:

```bash
# Link all configs (already done by setup)
./dot link

# Preview links without creating them
./dot link --dry-run

# Remove all symlinks
./dot unlink
```

**What gets linked:**
- `.zshrc` → `~/.dotfiles/home/.zshrc`
- `.tmux.conf` → `~/.dotfiles/home/.tmux.conf`
- `.aerospace.toml` → `~/.dotfiles/home/.aerospace.toml`
- `.config/*` → `~/.dotfiles/home/.config/*`

---

## Tool Installation Locations

| Tool | Installed By | Location |
|------|--------------|----------|
| Homebrew packages | Brewfile | `/opt/homebrew/bin/` (macOS) |
| mise | curl installer | `~/.local/bin/mise` |
| mise-managed tools | mise | `~/.local/share/mise/installs/` |
| fzf-tmux wrapper | curl (setup) | `~/.local/bin/fzf-tmux` |
| Custom bin tools | dotfiles | `~/.dotfiles/bin/` |
| Python tools (uv) | uv | `~/.local/bin/` |
| Tmux plugins | TPM | `~/.tmux/plugins/` |

---

## Updating Everything

```bash
# Update Homebrew packages, mise tools, and pull dotfiles changes
./dot update

# Preview updates without applying
./dot update --dry-run
```

---

## Troubleshooting

### "Please set up zsh and try again"

```bash
chsh -s $(which zsh)
# Log out and back in
```

### "brew: command not found" (after setup on macOS)

```bash
# Add Homebrew to PATH
eval "$(/opt/homebrew/bin/brew shellenv)"
# Then restart terminal
```

### "mise: command not found" (after setup)

```bash
export PATH="$HOME/.local/bin:$PATH"
eval "$(~/.local/bin/mise activate zsh)"
# Then restart terminal
```

### Stow conflicts with existing files

```bash
# Check what conflicts exist
./dot link --dry-run

# Backup conflicting files
mv ~/.zshrc ~/.zshrc.backup
mv ~/.tmux.conf ~/.tmux.conf.backup

# Try linking again
./dot link
```

### Tmux sessionx plugin not working

The setup script automatically installs the `fzf-tmux` wrapper script required by the sessionx plugin. If it's not working:

```bash
# Verify fzf-tmux is installed
which fzf-tmux

# If not found, install manually:
curl -fsSL https://raw.githubusercontent.com/junegunn/fzf/master/bin/fzf-tmux -o ~/.local/bin/fzf-tmux
chmod +x ~/.local/bin/fzf-tmux
```

### Neovim/mise tools not working

```bash
# Check mise installation
mise doctor

# Reinstall mise tools
mise install

# Verify PATH includes mise
echo $PATH | grep mise
```

---

## Validation Checklist

After setup, verify these work:

**Basic Environment:**
- [ ] `brew --version` (macOS)
- [ ] `mise --version`
- [ ] `mise list` (shows installed tools)
- [ ] `nvim --version`
- [ ] `tmux -V`

**Shell Features:**
- [ ] `l` command (eza alias)
- [ ] `v` command (nvim alias)
- [ ] `z <dir>` (zoxide)
- [ ] `Ctrl+R` (fzf history search)

**Tmux:**
- [ ] Start tmux: `tmux`
- [ ] Prefix + o (sessionx plugin)
- [ ] Tmux plugins loaded: `ls ~/.tmux/plugins/`

**Symlinks:**
- [ ] `ls -la ~/.zshrc` (should point to dotfiles)
- [ ] `ls -la ~/.config/nvim` (should point to dotfiles)

**Development Tools:**
- [ ] `node --version`
- [ ] `python --version`
- [ ] `go version`
- [ ] `cargo --version`

---

## Fresh Mac Installation Flow

For a completely new Mac from scratch:

1. **Initial OS setup:**
   ```bash
   # Install Command Line Tools
   xcode-select --install

   # Change default shell to zsh
   chsh -s /bin/zsh

   # Log out and log back in
   ```

2. **Clone and setup:**
   ```bash
   cd ~
   git clone <your-repo-url> .dotfiles
   cd .dotfiles
   ./dot setup
   ```

3. **Restart terminal and verify:**
   ```bash
   ./dot doctor
   ```

4. **Optional: Restore encrypted assets**
   ```bash
   # If you have encrypted fonts or other assets
   ./bin/decrypt-assets
   ```

---

## Directory Structure

```
~/.dotfiles/
├── dot                    # Main CLI entry point
├── home/                  # Configs (Stow-managed → ~)
│   ├── .zshrc
│   ├── .tmux.conf
│   └── .config/
├── packages/
│   ├── Brewfile          # All system packages
│   └── Brewfile.work     # Work-specific (optional)
├── scripts/
│   ├── commands/         # CLI command implementations
│   └── lib.sh            # Shared utilities
├── bin/                  # Custom tools
└── docs/                 # Documentation
```

---

## Additional Commands

```bash
# Show all available commands
./dot --help

# Get help for specific command
./dot setup --help
./dot package --help

# Run comprehensive diagnostics
./dot doctor
```

---

## See Also

- [ARCHITECTURE.md](ARCHITECTURE.md) - System design and architecture
- [BIN_TOOLS.md](BIN_TOOLS.md) - Custom binary tools
- [ASSET_ENCRYPTION.md](ASSET_ENCRYPTION.md) - Encrypted asset management

---

## Summary

The `./dot` CLI provides a complete dotfiles management system:

- ✅ **Simple**: One command to set up everything
- ✅ **Safe**: Idempotent, dry-run support, uses symlinks
- ✅ **Fast**: Parallel installation, efficient package managers
- ✅ **Maintainable**: Modular design, clear structure
- ✅ **Reproducible**: Version-controlled Brewfile and mise configs

Start with `./dot setup --dry-run` to see what would happen, then `./dot setup` to install everything!
