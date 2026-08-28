# .dotfiles

These are the files that make me better at using the computer.

## ⚡ Quick Start

```bash
# Clone the repo
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles

# Preview setup (dry run)
./dot setup --dry-run

# Run full setup
./dot setup

# Verify everything works
./dot doctor
```

## 🎮 The `dot` CLI

All dotfiles operations are managed through the `dot` command:

```bash
dot setup       # Initial setup for new machine
dot link        # Link configs with GNU Stow
dot unlink      # Remove symlinks
dot doctor      # Run health diagnostics
dot update      # Update all packages and tools
dot package     # Manage Brewfile packages
```

Most commands support `--dry-run` to preview changes:
```bash
dot setup --dry-run
dot link --dry-run
dot update --dry-run
```

## 📦 Package Management

All Homebrew packages are declared in `packages/Brewfile`:

```bash
# Add a package
dot package add bat

# Remove a package
dot package remove nushell

# List all packages
dot package list

# Sync installed packages with Brewfile
dot package sync
```

For work-specific packages, use `packages/Brewfile.work`.

## 🔗 Configuration Linking

Uses **GNU Stow** to symlink configs from `home/` to `~`:

```
home/.zshrc           → ~/.zshrc
home/.tmux.conf       → ~/.tmux.conf
home/.aerospace.toml  → ~/.aerospace.toml
home/.config/nvim     → ~/.config/nvim
home/.config/wezterm  → ~/.config/wezterm
home/.config/herdr/config.toml → ~/.config/herdr/config.toml
```

## 📋 What's Included

### Core Tools
- **Shell**: zsh with custom configuration
- **Terminal**: WezTerm with custom config
- **Editor**: Neovim (LazyVim + Bamboo theme)
- **Multiplexer**: tmux with comprehensive keybinds
- **Optional multiplexer**: Herdr with tmux-inspired keybinds
- **Window Manager**: AeroSpace (macOS tiling)

### Package Management
- **Homebrew**: System packages (via Brewfile)
- **mise**: Language runtimes and dev tools
- **eget**: Binary downloads (edge cases)

### Custom Tools
See [BIN_TOOLS](docs/BIN_TOOLS.md) for details:
- `tmux-sessionizer` - Quick tmux project switching
- `colorcat` - Syntax-highlighted file viewing
- `mkbin` / `mkscript` - Script generators
- And more...

## 🩺 Troubleshooting

Run comprehensive diagnostics:
```bash
dot doctor
```

This checks:
- Shell configuration (zsh)
- Package managers (Homebrew, mise)
- Required tools (git, stow, tmux, nvim)
- Symlink integrity
- PATH configuration
- Broken links detection

## 📚 Documentation

- [**ARCHITECTURE.md**](docs/ARCHITECTURE.md) - How everything fits together (⭐ **START HERE**)
- [SETUP_VALIDATION.md](docs/SETUP_VALIDATION.md) - Detailed setup guide
- [LINUX.md](docs/LINUX.md) - Linux (Ubuntu LTS) server setup
- [BIN_TOOLS.md](docs/BIN_TOOLS.md) - Custom command-line utilities
- [ASSET_ENCRYPTION.md](docs/ASSET_ENCRYPTION.md) - Encryption workflow

## 🎯 Key Features

### 1. **Idempotent Operations**
All commands can be run multiple times safely. No fear of breaking things.

### 2. **Dry-Run Support**
Preview changes before applying:
```bash
dot setup --dry-run
dot link --dry-run
dot update --dry-run
```

### 3. **Health Monitoring**
`dot doctor` provides comprehensive diagnostics:
- ✓ Everything working
- ⚠ Warnings for issues
- ✗ Errors with fix instructions

### 4. **Modular Architecture**
Each command is a separate, easy-to-understand script in `scripts/commands/`.

### 5. **Single Source of Truth**
- **packages/Brewfile**: All Homebrew packages
- **mise config**: All language runtimes
- **home/**: All config files
- **Git**: Version control for everything

## 🔐 Security

- Private data goes in `~/.privaterc` (sourced but not committed)
- Secrets encrypted with `age` (see [ASSET_ENCRYPTION.md](docs/ASSET_ENCRYPTION.md))
- Fonts are encrypted (pay your designers!)
- `.gitignore` excludes sensitive files

## 📝 Applications

### neovim
Hey... \*lowers sunglasses\* I use neovim, you know. It's a pretty basic LazyVim setup with a couple tweaks. The theme is called Bamboo, and it matches my default WezTerm config.

### tmux
I've actually been using tmux for a while so this one is pretty comprehensive. Having experimented with Zellij (which is also very cool!) I still find that I prefer tmux.

### Herdr
Herdr is tracked as an optional tmux alternative. Its config keeps the same `Ctrl-Space` prefix, Vim-style pane movement, tab shortcuts, and pane split workflow without changing the tmux setup. Install Herdr separately, run `dot link`, and reload it with `herdr server reload-config`.

### .zshrc
I found that Oh My Zsh became pretty slow, which I'm sure is a skill issue. The way I solved it was to use zinit and handle a lot more configuration myself, so there's quite a bit going on here. I added some profiling behavior so I can keep a better eye on this.

### WezTerm
Fast, GPU-accelerated terminal emulator with great config flexibility. My setup includes custom key bindings, tab bar styling, and integration with the Bamboo color scheme.

### AeroSpace
Tiling window manager for macOS. Configured for keyboard-driven window management with vim-style navigation.

## 🚀 Quick Tips

```bash
# Update everything at once
dot update

# Check if dotfiles are healthy
dot doctor

# Preview package installation
dot package sync --dry-run

# Re-link configs after changes
dot link

# View all available commands
dot --help
```

## 🤝 Contributing

This is my personal dotfiles repo, but feel free to:
- Fork it for your own use
- Submit issues for bugs
- Suggest improvements via PRs

## 📜 License

Do whatever you want with this. MIT licensed (see LICENSE file if I remember to add one).

---

**Inspiration**: This setup was inspired by [dmmulroy's dotfiles](https://github.com/dmmulroy/.dotfiles) and various other dotfile repos in the community.
