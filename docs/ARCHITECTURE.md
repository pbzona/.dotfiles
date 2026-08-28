# Dotfiles Architecture

This document explains how the dotfiles system is organized and how all the pieces fit together.

## 🏗️ Structure

```
~/.dotfiles/
├── dot                    # Main CLI dispatcher
├── home/                  # Stow-managed configs (symlinked to ~)
│   ├── .zshrc
│   ├── .tmux.conf
│   ├── .aerospace.toml
│   └── .config/
│       ├── aerospace/
│       ├── mise/
│       ├── nvim/
│       ├── wezterm/
│       └── herdr/
├── packages/             # Package management
│   ├── Brewfile          # Main Homebrew packages
│   └── Brewfile.work     # Work-specific packages (optional)
├── scripts/
│   ├── commands/         # Modular CLI commands
│   │   ├── setup.sh
│   │   ├── link.sh
│   │   ├── unlink.sh
│   │   ├── doctor.sh
│   │   ├── update.sh
│   │   └── package.sh
│   └── lib.sh            # Shared utilities
├── bin/                  # Custom tools
├── aliases/              # Shell aliases
├── docs/                 # Documentation
└── static/               # Static assets (fonts, etc.)
```

## 🔧 Core Components

### 1. The `dot` CLI

The main entry point for all dotfiles operations. It's a bash script that routes commands to modular implementations in `scripts/commands/`.

**Key features:**
- Modular architecture (easy to extend)
- Colored output for clarity
- Consistent error handling
- Built-in help system

**Commands:**
- `setup` - Initial machine setup
- `link` - Symlink configs with Stow
- `unlink` - Remove symlinks
- `doctor` - Health diagnostics
- `update` - Update all packages/tools
- `package` - Manage Brewfile

### 2. GNU Stow for Linking

We use **GNU Stow** instead of custom manifest scripts. Stow is:
- Industry-standard
- Simple and robust
- Well-documented
- Handles conflicts automatically

**How it works:**
```bash
# All configs live in home/
~/.dotfiles/home/.zshrc
~/.dotfiles/home/.config/nvim/

# Stow creates symlinks
~/.zshrc -> ~/.dotfiles/home/.zshrc
~/.config/nvim -> ~/.dotfiles/home/.config/nvim/
```

**Commands:**
```bash
dot link          # Create all symlinks
dot link --dry-run  # Preview without changes
dot unlink        # Remove symlinks
```

### 3. Brewfile for Package Management

All Homebrew packages are declared in `packages/Brewfile`. This provides:
- Single source of truth
- Easy synchronization
- Version control
- Reproducible environments

**Structure:**
```ruby
# Taps
tap "nikitabobko/tap"

# Formulas (CLI tools)
brew "git"
brew "neovim"
brew "fzf"

# Casks (GUI apps)
cask "wezterm"
cask "nikitabobko/tap/aerospace"

# Fonts
cask "font-geist-mono-nerd-font"
```

**Commands:**
```bash
dot package add bat       # Add and install
dot package remove tmux   # Remove and uninstall
dot package list          # Show all packages
dot package sync          # Install missing packages
```

### 4. mise for Runtime Management

**mise** handles language runtimes and dev tools (defined in `home/.config/mise/config.toml`):
- Node.js, Python, Go, Rust, Elixir
- CLI tools: bat, eza, ripgrep, jq, etc.
- Auto-switching based on directory

**Why mise?**
- Faster than asdf
- Single binary
- Auto-activates in shell
- Per-project versions

### 5. Helper Tools

**eget** - Binary downloader (kept for edge cases)
- Used for tools not in Homebrew
- Most tools now in Brewfile
- Installed during setup but optional

**Custom bin tools** (`bin/`):
- `tmux-sessionizer` - Quick tmux session management
- `colorcat` - Syntax-highlighted cat
- `mkbin` / `mkscript` - Script generators
- etc.

## 🔄 Workflows

### Initial Setup (New Machine)

```bash
# 1. Clone dotfiles
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles

# 2. Preview setup
./dot setup --dry-run

# 3. Run full setup
./dot setup

# 4. Restart terminal
# 5. Verify
./dot doctor
```

**What happens:**
1. Creates `~/.local/{bin,share,state}` directories
2. Verifies zsh is default shell
3. Installs Homebrew (macOS)
4. Installs Brewfile packages
5. Installs mise
6. Links dotfiles with Stow
7. Installs mise tools
8. Sets macOS defaults

### Adding New Config Files

```bash
# 1. Add file to home/
cp ~/.myconfig ~/.dotfiles/home/.myconfig

# 2. Link it
dot link

# 3. Commit
cd ~/.dotfiles
git add home/.myconfig
git commit -m "Add myconfig"
```

### Adding Packages

```bash
# Add to Brewfile and install
dot package add neofetch

# Or manually edit Brewfile and sync
echo 'brew "neofetch"' >> packages/Brewfile
dot package sync
```

### Updating Everything

```bash
# Update Homebrew, mise, and dotfiles
dot update

# Or with preview
dot update --dry-run
```

### Troubleshooting

```bash
# Run comprehensive health check
dot doctor

# Check specific issues:
brew doctor          # Homebrew
mise doctor          # mise
stow --help          # Stow installed?
```

## 🎯 Design Principles

### 1. **Idempotent Operations**
All commands can be run multiple times safely. Re-running `dot setup` won't break things.

### 2. **Dry-Run Support**
Critical commands support `--dry-run` to preview changes:
- `dot setup --dry-run`
- `dot link --dry-run`
- `dot update --dry-run`

### 3. **Clear Feedback**
- ✓ Green for success
- ⚠ Yellow for warnings
- ✗ Red for errors
- ℹ Blue for info

### 4. **Modular Design**
Each command is a separate file in `scripts/commands/`. Easy to:
- Understand
- Modify
- Extend
- Test

### 5. **Minimal Dependencies**
Core requirements:
- bash
- git
- curl
- GNU Stow (for linking)

Everything else is managed via `packages/Brewfile` or mise.

## 📦 Package Organization

### packages/Brewfile (System Packages)
- CLI tools (git, tmux, neovim)
- GUI apps (wezterm, aerospace)
- System utilities (docker, mkcert)
- Fonts

**Variants:**
- `packages/Brewfile` - Main packages for all machines
- `packages/Brewfile.work` - Optional work-specific packages

### mise (Language Runtimes)
- Node.js, Python, Go, Rust
- Language-specific tools
- Version-managed utilities

### Custom bins
- Project-specific tools
- Convenience scripts
- Not in Homebrew/mise

## 🔍 Key Files

| File | Purpose |
|------|---------|
| `dot` | Main CLI entry point |
| `packages/Brewfile` | All Homebrew packages |
| `packages/Brewfile.work` | Work-specific packages |
| `home/.zshrc` | Shell configuration |
| `home/.config/mise/config.toml` | Tool versions |
| `home/.config/nvim/` | Neovim config |
| `home/.config/wezterm/` | Terminal config |
| `home/.config/herdr/config.toml` | Optional Herdr keybindings |
| `home/.aerospace.toml` | Window manager |
| `scripts/commands/*.sh` | CLI command implementations |
| `scripts/lib.sh` | Shared utilities |

## 🚀 Extending

### Adding a New Command

1. Create `scripts/commands/mycommand.sh`:
```bash
#!/usr/bin/env bash

cmd_mycommand() {
  local show_help=false

  # Parse args...

  if $show_help; then
    cat << EOF
dot mycommand - Description

Usage:
  dot mycommand [options]
EOF
    exit 0
  fi

  # Implementation...
  info "Doing something..."
  success "Done!"
}
```

2. Add to `dot` dispatcher:
```bash
mycommand)
  source "$COMMANDS_DIR/mycommand.sh"
  cmd_mycommand "$@"
  ;;
```

3. Test it:
```bash
./dot mycommand --help
./dot mycommand
```

## 🔒 Security Notes

- Private data goes in `~/.privaterc` (sourced but not committed)
- Secrets encrypted with `age` (see `ASSET_ENCRYPTION.md`)
- `.gitignore` excludes sensitive files
- SSH keys never in repo

## 📚 Further Reading

- [Setup & Validation Guide](SETUP_VALIDATION.md)
- [Linux Server Setup](LINUX.md)
- [Binary Tools](BIN_TOOLS.md)
- [Asset Encryption](ASSET_ENCRYPTION.md)
- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/)
- [mise Documentation](https://mise.jdx.dev/)
