# Setup Script Validation & Installation Guide

This document validates the setup.sh script and provides the correct order of operations for setting up dotfiles on a fresh Mac.

---

## Prerequisites

Before running any setup scripts, ensure you have:

1. **macOS** (Darwin) or **Linux** (Ubuntu/Debian)
2. **zsh** as your default shell
   ```bash
   echo $SHELL  # Should show: /bin/zsh or similar
   ```
3. **Git** installed (to clone this repo)
4. **Internet connection** (for downloading tools)

---

## Installation Order

### Step 1: Clone the Repository

```bash
cd ~
git clone <your-repo-url> .dotfiles
cd .dotfiles
```

### Step 2: Link Mise Configuration (CRITICAL)

**⚠️ MUST DO THIS FIRST** - The mise config needs to be in place before running setup.sh:

```bash
# Link mise config so setup.sh can find it
mkdir -p ~/.config/mise
ln -sf ~/.dotfiles/.config/mise/config.toml ~/.config/mise/config.toml
```

### Step 3: Run Setup Script

```bash
./scripts/setup.sh
```

**What this does:**
1. Sources `~/.privaterc` if it exists (optional)
2. Creates `~/.local/{bin,share,state}` directories
3. Checks that zsh is your shell
4. **(macOS only)** Installs Homebrew if missing
5. **(macOS only)** Installs nerd fonts via brew
6. Installs mise-en-place and runs `mise install` (uses the config you linked)
7. Installs eget (binary downloader)
8. Installs neovim to `/opt/nvim` (requires sudo password)
9. Installs fzf, zoxide, yazi via eget
10. Installs core packages (brew on macOS, apt on Linux)
11. Installs cheatsheet tool (cht.sh)
12. Installs posting via uv (Python TUI REST client)

### Step 4: Link Dotfiles

```bash
./scripts/link.sh all
```

**What this does:**
1. Creates symlinks from dotfiles to home directory
2. Backs up existing configs to `~/.backup_config/`
3. Special steps:
   - **neovim**: Cleans `~/.local/{share,state}/nvim` before linking
   - **tmux**: Installs tmux plugin manager (tpm)
   - **zsh**: Links .zshrc

### Step 5: Restart Terminal

Close and reopen your terminal to load the new .zshrc configuration.

---

## Script Validation Results

### ✅ Checks That Will NOT Overwrite

These operations check before installing:

- **Homebrew**: Only installs if `brew` command not found
- **mise**: Only installs if `~/.local/bin/mise` doesn't exist
- **.privaterc**: Only sources if file exists (optional)
- **mise tools**: mise handles version management, won't break existing tools
- **brew packages**: brew upgrade if already installed
- **tmux tpm**: Only clones if `~/.tmux/plugins/tpm` doesn't exist

### ⚠️ Operations That WILL Overwrite

These will overwrite existing files/directories without asking:

1. **eget binary** (line 54)
   - Downloads and overwrites `~/.local/bin/eget`
   - Impact: Low (eget is just a downloader)

2. **neovim** (line 57, install-neovim.sh)
   - **Requires sudo password**
   - Removes `/opt/nvim` if exists
   - Uninstalls brew neovim if exists
   - Downloads and extracts latest neovim to `/opt/nvim`
   - Impact: Medium (will replace existing neovim)

3. **fzf, zoxide, yazi binaries** (lines 59-66)
   - Downloads and overwrites files in `~/.local/bin/`
   - Impact: Low (standalone binaries)

4. **cht.sh** (install-cheatsheet-packages.sh)
   - Overwrites `~/.local/bin/cht.sh`
   - Impact: Low

### 🔒 Operations Requiring Sudo

- **install-neovim.sh**: Requires sudo to extract to `/opt/nvim`
- **(Linux only)** apt package installation in install-core-packages.sh

---

## Dependencies Between Scripts

### Script Call Chain

```
setup.sh
├── sources lib.sh (for detect_os function)
├── sources install-neovim.sh
├── sources install-core-packages.sh
│   └── sources lib.sh (for detect_os function)
└── sources install-cheatsheet-packages.sh
```

### External Dependencies

**setup.sh depends on:**
- `curl` (for downloading installers)
- `git` (mise installer uses it, tpm installation)
- `brew` (macOS - installed by script if missing)
- `apt` (Linux - assumed pre-installed)
- `uv` (installed by mise from config)

---

## Special Notes

### 1. Mise Configuration Location

The mise config at `.config/mise/config.toml` needs to be linked to `~/.config/mise/config.toml` BEFORE running setup.sh. Otherwise `mise install` (line 44) won't know what to install.

**Current tools in mise config:**
- **Languages**: bun 1.2, go 1.25, node 24, rust 1.84
- **CLI Tools**: bat, eza, fd, ripgrep, jq, github-cli, pnpm, and 30+ utilities
- **Python Tools**: uv 0.5

### 2. Path Configuration

Tools get installed to multiple locations:
- **mise-managed**: `~/.local/share/mise/installs/`
- **eget binaries**: `~/.local/bin/`
- **neovim**: `/opt/nvim/bin/`
- **brew packages**: `/opt/homebrew/bin/` (macOS)

Your `.zshrc` adds these to PATH:
```zsh
$HOME/bin
$HOME/.opencode/bin
$HOME/.local/share
$HOME/.local/bin
$DOTFILES/bin
$DOTFILES/scripts
```

### 3. Neovim Installation Quirks

**install-neovim.sh** has some unique behavior:

**On macOS:**
- Removes `/opt/nvim` if it exists
- Uninstalls brew neovim if installed
- Downloads arm64 tarball
- Runs `xattr -c` to remove quarantine flag
- Extracts to `/opt/nvim` (requires sudo)
- Creates symlink: `~/.local/bin/nvim -> /opt/nvim/bin/nvim`
- Cleans up tarball

**On Linux:**
- Extracts to `/opt/nvim-linux-x86_64`
- Creates symlink: `~/.local/bin/nvim -> /opt/nvim-linux-x86_64/bin/nvim`

### 4. Tool Installation Summary

| Tool | Installed By | Location | Overwrite |
|------|--------------|----------|-----------|
| mise | curl installer | `~/.local/bin/mise` | No (checks first) |
| eget | curl installer | `~/.local/bin/eget` | Yes |
| neovim | manual install | `/opt/nvim` + symlink in `~/.local/bin` | Yes (removes first) |
| fzf | eget | `~/.local/bin/fzf` | Yes |
| zoxide | eget | `~/.local/bin/zoxide` | Yes |
| yazi | eget | `~/.local/bin/yazi` | Yes |
| cht.sh | curl | `~/.local/bin/cht.sh` | Yes |
| bat, eza, fd, etc. | mise | `~/.local/share/mise/` | No (mise managed) |
| docker, tmux, etc. | brew/apt | system paths | No (pkg manager) |
| posting | uv tool | `~/.local/bin/posting` | No (uv managed) |

---

## Validation Checklist

Before running on a fresh Mac, verify:

- [ ] Repository cloned to `~/.dotfiles`
- [ ] Mise config linked: `~/.config/mise/config.toml` → `~/.dotfiles/.config/mise/config.toml`
- [ ] Default shell is zsh: `echo $SHELL`
- [ ] Git is installed: `git --version`
- [ ] Internet connection works
- [ ] Comfortable entering sudo password (for neovim install)

After running setup.sh, verify:

- [ ] Homebrew installed (macOS): `brew --version`
- [ ] Mise installed: `mise --version`
- [ ] Mise tools installed: `mise list`
- [ ] Neovim installed: `nvim --version`
- [ ] Core tools: `fzf --version`, `zoxide --version`, `gh --version`

After running link.sh all, verify:

- [ ] `.zshrc` is symlink: `ls -la ~/.zshrc`
- [ ] `.tmux.conf` is symlink: `ls -la ~/.tmux.conf`
- [ ] Neovim config is symlink: `ls -la ~/.config/nvim`
- [ ] Backups created: `ls ~/.backup_config/`
- [ ] TPM installed: `ls ~/.tmux/plugins/tpm`

After restarting terminal, verify:

- [ ] Mise activated: `mise current`
- [ ] Zinit loaded: `zinit list`
- [ ] Aliases work: `l` (should be eza), `v` (should be nvim)
- [ ] Zoxide works: `z` (should be cd replacement)
- [ ] FZF works: `Ctrl+R` (should show history search)

---

## Dry Run Testing

To test without overwriting anything:

```bash
# Check what mise would install
mise ls --missing

# Check what brew would install (macOS)
brew bundle check --file=/dev/stdin <<EOF
brew "font-geist-mono-nerd-font"
brew "font-lilex-nerd-font"
EOF

# Check if binaries exist before overwriting
ls -la ~/.local/bin/{eget,fzf,zoxide,yazi,nvim,cht.sh}

# Check if neovim exists
ls -la /opt/nvim
```

---

## Troubleshooting

### "Please set up zsh and try again"
```bash
# Change shell to zsh
chsh -s $(which zsh)
# Log out and back in
```

### "mise: command not found" after setup
```bash
# Add to PATH manually
export PATH="$HOME/.local/bin:$PATH"
eval "$(~/.local/bin/mise activate zsh)"
```

### Neovim install fails with permission denied
```bash
# Ensure sudo works
sudo -v
# Run setup again
./scripts/setup.sh
```

### Missing PATH after linking .zshrc
```bash
# Restart terminal or
source ~/.zshrc
```

### Mise tools not installing
```bash
# Verify mise config is linked
ls -la ~/.config/mise/config.toml
# Should point to ~/.dotfiles/.config/mise/config.toml

# Manually install mise tools
mise install
```

---

## Recommended Installation Flow

For a completely fresh Mac:

1. **Initial setup** (don't need dotfiles yet):
   ```bash
   # Install Command Line Tools
   xcode-select --install

   # Change shell to zsh (if not default)
   chsh -s /bin/zsh

   # Log out and log back in
   ```

2. **Clone and prepare**:
   ```bash
   cd ~
   git clone <your-repo> .dotfiles
   cd .dotfiles

   # Critical: Link mise config first
   mkdir -p ~/.config/mise
   ln -sf ~/.dotfiles/.config/mise/config.toml ~/.config/mise/config.toml
   ```

3. **Run setup**:
   ```bash
   ./scripts/setup.sh
   # Enter sudo password when prompted for neovim
   ```

4. **Link configurations**:
   ```bash
   ./scripts/link.sh all
   ```

5. **Restart terminal** and enjoy!

---

## Summary

The setup script is **mostly safe** but will:
- ✅ Check before installing most things
- ⚠️ Overwrite some binaries in `~/.local/bin/`
- ⚠️ Require sudo for neovim installation
- ⚠️ Require mise config to be linked first

**Critical step:** Link mise config before running setup.sh!

The linking script is **completely safe** because it:
- Backs up all existing configs with timestamps
- Only creates symlinks (easily reversible)
- Checks for existing files before linking
