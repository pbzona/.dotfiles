# Manifest-Based Linking System

A simple, extensible system for managing dotfile symlinks using a manifest file.

## Quick Start

```bash
# Link all configs from manifest
./scripts/link.sh

# Link specific config (with special setup steps)
./scripts/link.sh nvim
./scripts/link.sh tmux
./scripts/link.sh zsh

# Link all with special setup
./scripts/link.sh all

# Show help
./scripts/link.sh --help
```

## The Manifest File

**Location:** `~/.dotfiles/links.manifest`

### Format

```
# Comments start with #
source destination [tags]
```

- **source**: Path relative to `$DOTFILES`
- **destination**: Absolute path (supports `~` expansion)
- **tags**: Optional, comma-separated (for selective linking)

### Example

```manifest
# Shell configuration
.zshrc ~/.zshrc zsh

# Terminal multiplexer
.tmux.conf ~/.tmux.conf tmux

# Neovim
.config/nvim ~/.config/nvim nvim,neovim

# Git (multiple tags example)
.gitconfig ~/.gitconfig git,vcs
```

## How It Works

### Basic Linking

When you run `./scripts/link.sh` (or `./scripts/link.sh manifest`):

1. Reads `links.manifest`
2. For each entry:
   - Backs up existing file/dir to `~/.backup_config/` with timestamp
   - Creates symlink from dotfiles to destination
   - Creates parent directories as needed
3. Shows summary of what was linked

### Tag Filtering

When you run `./scripts/link.sh nvim`:

1. Reads manifest and filters for entries tagged with `nvim`
2. Only links matching entries
3. Runs any special setup steps (e.g., cleaning neovim state)

### Special Setup Functions

Some configs need more than just linking:

- **nvim**: Cleans `~/.local/share/nvim` and `~/.local/state/nvim` before linking
- **tmux**: Installs tpm (tmux plugin manager) if not present
- **zsh**: Basic linking (placeholder for future special setup)

## Adding New Configs

### Simple Case (Just Linking)

1. Edit `links.manifest`:
   ```
   .gitconfig ~/.gitconfig git
   ```

2. Run:
   ```bash
   ./scripts/link.sh manifest
   ```

### With Tags (Selective Linking)

1. Edit `links.manifest`:
   ```
   .config/wezterm ~/.config/wezterm wezterm,terminal
   .config/aerospace ~/.config/aerospace aerospace,wm
   ```

2. Add case to `link.sh` if you want shortcuts:
   ```bash
   wezterm)
     link_from_manifest "wezterm"
     ;;
   ```

3. Now you can:
   ```bash
   ./scripts/link.sh wezterm  # Link just wezterm
   ./scripts/link.sh          # Link everything
   ```

### With Special Setup Steps

If a config needs special setup (like installing plugins, cleaning cache, etc.):

1. Add to manifest with tags:
   ```
   .config/my-app ~/.config/my-app myapp
   ```

2. Create function in `link.sh`:
   ```bash
   link_myapp() {
     echo "=== Setting up My App ==="
     echo ""

     # Do special setup
     mkdir -p ~/.cache/myapp
     echo "  ✓ Created cache directory"

     # Link from manifest
     link_from_manifest "myapp"
   }
   ```

3. Add case:
   ```bash
   myapp)
     link_myapp
     ;;
   ```

4. Update `all` case:
   ```bash
   all)
     link_neovim
     link_tmux
     link_zsh
     link_myapp
     ;;
   ```

## Extensibility

The manifest format is designed to be extended. Future possibilities:

### Add Link Types
```
symlink .zshrc ~/.zshrc zsh
copy .secrets ~/.secrets secrets
```

### Add OS-Specific Entries
```
.config/nvim ~/.config/nvim nvim
.config/aerospace ~/.config/aerospace aerospace,macos
.config/i3 ~/.config/i3 i3,linux
```

### Add Conditions
```
.zshrc ~/.zshrc zsh required
.config/optional ~/.config/optional optional
```

### Add Descriptions
```
.zshrc ~/.zshrc zsh "Main shell configuration"
```

## Migration from Old System

The old system still works! Both approaches coexist:

**Old way (still works):**
```bash
./scripts/link.sh nvim  # Calls link_neovim()
```

**New way (same result):**
```bash
./scripts/link.sh nvim  # Now uses link_from_manifest() internally
```

The special setup functions (cleaning state, installing tpm) are preserved.

## Benefits

1. **Easy to add configs**: Just edit one text file
2. **No code changes**: Don't need to modify bash script for simple additions
3. **Selective linking**: Use tags to link subsets
4. **Automatic backups**: Existing configs are saved with timestamps
5. **Extensible**: Easy to add new features to manifest format
6. **Documentation**: Manifest file serves as inventory of what's linked
7. **Version control**: Track what gets linked in git

## Troubleshooting

### "Manifest file not found"
```bash
# Check location
ls -la ~/.dotfiles/links.manifest

# Create if missing
cp ~/.dotfiles/links.manifest.example ~/.dotfiles/links.manifest
```

### "Source does not exist"
The manifest references a file that doesn't exist in your dotfiles:
```
✗ Warning: Source does not exist: /Users/phil/.dotfiles/.gitconfig
```

Fix: Either add the file or remove/comment out the line in manifest.

### Nothing gets linked with tag filter
Make sure tags are comma-separated without spaces:
```
# Good
.zshrc ~/.zshrc zsh,shell

# Bad (won't match "zsh")
.zshrc ~/.zshrc zsh, shell
```

### Symlink already exists
The script uses `ln -sf` (force) so it will overwrite existing symlinks. Real files are backed up first.

## Examples

### Link everything
```bash
./scripts/link.sh
```

### Link just shell config
```bash
./scripts/link.sh zsh
```

### Link editor configs
```bash
# Add tag to multiple entries in manifest
.config/nvim ~/.config/nvim editor,nvim
.config/helix ~/.config/helix editor,helix

# Then link all editor configs
# (Would need to add editor case to script)
```

### Fresh install workflow
```bash
cd ~/.dotfiles
./scripts/link.sh all  # Links everything with special setup
```
