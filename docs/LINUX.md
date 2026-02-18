# Linux Server Setup

Guide for running these dotfiles on a headless Ubuntu LTS server (22.04 or 24.04).

The dotfiles are primarily designed for macOS, but the `dot` CLI, shell config, and dev tools all work on Linux. The main difference is package management: **apt** replaces **Homebrew**, and GUI-only tools (AeroSpace, WezTerm, Ghostty) are ignored.

## Prerequisites

- Ubuntu 22.04 LTS or 24.04 LTS
- `sudo` access
- `git` and `curl` installed (usually present by default)
- zsh as your default shell

```bash
# Install zsh if not present
sudo apt install -y zsh

# Set as default shell
chsh -s $(which zsh)
# Log out and back in for this to take effect
```

## Quick Start

```bash
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles
./dot setup --dry-run    # preview
./dot setup              # install everything
# restart your shell
./dot doctor             # verify
```

`dot setup` will prompt for your sudo password once for apt operations.

## What Gets Installed

### System packages (apt)

Defined in `packages/apt.txt`. These are the apt equivalents of the macOS Brewfile, limited to what's useful on a headless server:

| Category | Packages |
|----------|----------|
| Dev tools | git, git-lfs, curl, wget, build-essential, libssl-dev, unzip |
| Shell | zsh, tmux, fzf, zoxide |
| Editor | neovim |
| File/text | bat, fd-find, ripgrep, jq, tree |
| System | btop, htop, mtr-tiny, nmap, telnet, tldr, lsof |
| Docker | docker.io |
| Data | redis-tools, sqlite3 |
| Network | dnsmasq, lftp |
| Build | libpq-dev, stow |

### Third-party repo packages (apt-extras.sh)

Some packages aren't in the default Ubuntu repos. `packages/apt-extras.sh` handles adding the necessary GPG keys and apt sources, then installing:

| Package | Source | Notes |
|---------|--------|-------|
| **gh** | GitHub's official apt repo | GitHub CLI |
| **eza** | gierens.de apt repo | Modern `ls` replacement |
| **neovim** | neovim-ppa/unstable | Only on 22.04 (24.04 has a recent enough version) |
| **tailscale** | Tailscale install script | VPN mesh network |

The script is idempotent -- it checks whether each package is already installed before doing anything.

### Dev tools (mise)

Language runtimes and version-sensitive CLI tools are managed by **mise**, not apt. This is identical to macOS. See `home/.config/mise/config.toml` for the full list, which includes Node.js, Python, Go, Rust, Bun, delta, lazydocker, and others.

### What's skipped on Linux

These macOS-specific tools from the Brewfile have no Linux equivalent and are not installed:

- GUI apps: WezTerm, AeroSpace, Ghostty, fonts
- macOS-only Homebrew taps and casks
- macOS defaults (`NSWindowShouldDragOnGesture`, etc.)

The corresponding config files (`.aerospace.toml`, `.config/wezterm/`, `.config/ghostty/`) are still symlinked by stow -- they're harmless unused files.

## Package Management

`dot package` works the same on both platforms but dispatches to apt instead of Homebrew:

```bash
dot package add htop       # appends to apt.txt + sudo apt install
dot package remove htop    # removes from apt.txt + sudo apt remove
dot package list           # shows all apt.txt entries with install status
dot package sync           # installs any missing apt.txt packages
```

The `cleanup` subcommand is macOS-only (it regenerates the Brewfile from installed packages). On Linux, edit `packages/apt.txt` directly.

### Adding packages that need third-party repos

For packages that aren't in the default Ubuntu repos, add them to `packages/apt-extras.sh` rather than `apt.txt`. Follow the existing pattern: check if installed, add the repo/key, then install.

## Updating

```bash
dot update
```

On Linux, this runs:

1. `sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y`
2. Checks if `apt.txt` is in sync with installed packages
3. Updates mise tools (`mise upgrade`)
4. Pulls latest dotfiles (`git pull`)

## Health Checks

```bash
dot doctor
```

On Linux, doctor checks:

- zsh is the default shell
- apt is available and `apt.txt` packages are installed
- mise is installed and configured
- Essential tools present (git, stow, curl, tmux, nvim)
- `~/.local/bin` is in PATH
- Dotfile symlinks are valid (skips GUI-only configs)
- Broken symlinks in `$HOME`
- Git configuration
- TPM and tmux plugins

## Linux-Specific Shell Aliases

Defined in `aliases/linux.zsh`, sourced automatically when `$OS == "linux"`:

```bash
alias bat=batcat     # Ubuntu names the binary "batcat"
alias fd=fdfind      # Ubuntu names the binary "fdfind"
alias f2b=fail2ban-client

# xclip-based clipboard (if xclip is installed)
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'
```

## Ubuntu 22.04 vs 24.04

The main difference is neovim. Ubuntu 22.04 ships an older version, so `apt-extras.sh` adds the `neovim-ppa/unstable` PPA to get a recent release. On 24.04 this step is skipped.

Everything else works identically on both versions.

## File Reference

| File | Purpose |
|------|---------|
| `packages/apt.txt` | Core apt packages (one per line, comments allowed) |
| `packages/apt-extras.sh` | Packages needing third-party repos |
| `scripts/lib.sh` | `detect_os()`, `detect_distro()`, `detect_distro_version()` |
| `aliases/linux.zsh` | Linux-specific shell aliases |

## Troubleshooting

### "Cannot obtain sudo"

`dot setup` needs sudo for apt. Make sure your user is in the `sudo` group:

```bash
# As root or another sudoer:
usermod -aG sudo yourusername
# Log out and back in
```

### bat/fd commands not found

Ubuntu uses different binary names. The aliases in `aliases/linux.zsh` handle this, but they only work in zsh. If you're in a bare bash session:

```bash
batcat file.txt    # instead of bat
fdfind pattern     # instead of fd
```

### Neovim is too old on 22.04

If `dot setup` ran before `apt-extras.sh` added the PPA, re-run:

```bash
bash ~/.dotfiles/packages/apt-extras.sh
```

### mise tools not available

mise is installed to `~/.local/bin/mise` and activated in `.zshrc`. If tools aren't available:

```bash
# Verify mise is in PATH
which mise

# Re-activate
eval "$(~/.local/bin/mise activate zsh)"

# Re-install tools
mise install
```

### Docker permission denied

The `docker.io` package requires your user to be in the `docker` group:

```bash
sudo usermod -aG docker $USER
# Log out and back in
```
