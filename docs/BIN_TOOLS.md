# bin/ Directory Tools

Custom command-line utilities for everyday development tasks.

## What is bin/?

The `bin/` directory contains executable scripts that are added to your `$PATH` via `.zshrc`. These tools can be invoked directly from anywhere in your terminal.

---

## Available Tools

### colorcat

**Purpose:** Display hex colors inline with preview swatches

**Usage:**
```bash
# Show hex color with preview
colorcat "#ff0000"

# Cat a file and preview any hex colors found
colorcat colors.css
```

**Example:**
```
#ff0000  [red swatch]
#00ff00  [green swatch]
```

**Source:** [sebastiancarlos gist](https://gist.github.com/sebastiancarlos/f712954caa8914032f6ebc867e9f8e4f)

---

### decrypt-assets

**Purpose:** Decrypt age-encrypted files and directories

**Usage:**
```bash
# Decrypt fonts (default)
decrypt-assets

# Decrypt specific file
decrypt-assets fonts.tar.gz.age
decrypt-assets secrets.env.age

# List all encrypted assets
decrypt-assets --list

# Decrypt all encrypted files
decrypt-assets --all
```

**What it does:**
- Decrypts age-encrypted files using your private key (`age.txt`)
- Automatically extracts `.tar.gz` archives after decryption
- Cleans up intermediate files
- Preserves encrypted originals

**Options:**
- `--list, -l` - Show all encrypted assets in `static/`
- `--all, -a` - Decrypt all encrypted files at once
- `--help, -h` - Show help message

**Arguments:**
- `file` - Specific encrypted file to decrypt (optional)
- If no file specified, defaults to `fonts.tar.gz.age`

**Examples:**
```bash
# Decrypt default (fonts)
decrypt-assets

# Decrypt specific asset
decrypt-assets credentials.tar.gz.age

# See what's available
decrypt-assets --list

# Decrypt everything
decrypt-assets --all
```

**Prerequisites:**
- age must be installed (`mise install age`)
- `age.txt` (private key) must exist in dotfiles root
- Encrypted `.age` files must exist in `static/`

**Error Handling:**
- Checks for age installation
- Verifies private key exists with helpful instructions
- Gracefully falls back when `gum` isn't available
- Lists available files if default not found

**Dependencies:** age, gum (optional)

**See also:** [ASSET_ENCRYPTION.md](ASSET_ENCRYPTION.md)

---

### encrypt-assets

**Purpose:** Encrypt files or directories using age for secure storage in git

**Usage:**
```bash
# Encrypt a directory (creates tarball automatically)
encrypt-assets fonts/

# Encrypt a single file
encrypt-assets credentials.json

# Encrypt with custom output name
encrypt-assets fonts/ myfonts
```

**What it does:**
- Encrypts files/directories using age and `.age-recipients.txt` (public key)
- Automatically creates `.tar.gz` for directories
- Cleans up unencrypted originals after encryption
- Provides git commit instructions

**Arguments:**
- `file|directory` - Path to encrypt (relative to `static/`)
- `output-name` - Optional custom name for encrypted file

**Examples:**
```bash
# Encrypt fonts directory
encrypt-assets fonts/
# → Creates static/fonts.tar.gz.age

# Encrypt a config file
encrypt-assets secrets.env
# → Creates static/secrets.env.age

# Custom output name
encrypt-assets fonts/ licensed-fonts
# → Creates static/licensed-fonts.tar.gz.age
```

**Dependencies:** age

**Prerequisites:**
- `.age-recipients.txt` must exist (contains public key)
- Run from dotfiles directory or set `$DOTFILES`
- age must be installed (`mise install age`)

**Security:**
- Uses public key encryption (age)
- Encrypted files safe to commit to public repos
- Original files deleted after encryption
- Never commits `age.txt` (private key)

**See also:** [ASSET_ENCRYPTION.md](ASSET_ENCRYPTION.md)

---

### figlet-preview

**Purpose:** Preview text in all available figlet fonts

**Usage:**
```bash
figlet-preview "Your Text"
```

**What it does:**
- Shows your text rendered in every installed figlet font
- Useful for choosing ASCII art fonts

**Dependencies:** figlet

**Example output:**
```
========================================
FONT: banner
----------------------------------------
 #     #
  #   #  ####  #    # #####
   # #  #    # #    # #    #
    #   #    # #    # #    #
    #   #    # #    # #####
    #    ####   ####  #
```

---

### mkbin

**Purpose:** Create a new executable in `bin/` directory

**Usage:**
```bash
mkbin mycommand [python|node|bash]
```

**What it does:**
- Creates executable file in `$DOTFILES/bin/mycommand`
- Sets shebang to specified interpreter (default: bash)
- Makes it executable (`chmod +x`)
- Opens in `$EDITOR` for you to write the script

**Dependencies:** lib.sh (uses `create_executable` function)

---

### mkscript

**Purpose:** Create a new script in `scripts/` directory

**Usage:**
```bash
mkscript myscript [python|node|bash]
```

**What it does:**
- Same as `mkbin` but creates in `$DOTFILES/scripts/`
- For scripts meant to be sourced or called by other scripts
- Not automatically in `$PATH` (use for library/helper scripts)

**Dependencies:** lib.sh (uses `create_executable` function)

---

### repo-history

**Purpose:** Quick overview of git commits and tags

**Usage:**
```bash
cd /path/to/git/repo
repo-history
```

**What it does:**
- Lists recent commits with short hash, date, and message
- Lists all tags sorted by creation date (newest first)

**Dependencies:** git, node

**Example output:**
```
Commits:
a1b2c3d 2024-01-15 Add new feature
e4f5g6h 2024-01-14 Fix bug in parser

Tags:
v2.0.0
v1.9.5
v1.9.4
```

---

### tmux-sessionizer

**Purpose:** Fuzzy-find and switch to project tmux sessions

**Usage:**
```bash
# Interactive fuzzy find
tmux-sessionizer

# Or provide path directly
tmux-sessionizer ~/projects/myapp
```

**What it does:**
- Searches configured directories for projects
- Uses `fzf` to let you select a project
- Creates or switches to tmux session named after the project
- If tmux not running, starts new session
- If already in tmux, switches to the session

**Search paths:** (edit line 7 to customize)
- `~/work/builds`
- `~/projects`
- `~/`
- `~/work`
- `~/personal`
- `~/personal/yt`

**Dependencies:** tmux, fzf

**Keybinding:** Aliased as `ts` in `aliases/common.zsh`

**Source:** [ThePrimeagen's dotfiles](https://github.com/ThePrimeagen/.dotfiles)

---

## How to Add New Tools

### Quick Method (Using mkbin)

```bash
mkbin mytool
# Opens editor, write your script, save and close
# Tool is now available system-wide
```

### Manual Method

1. Create file:
   ```bash
   touch ~/.dotfiles/bin/mytool
   chmod +x ~/.dotfiles/bin/mytool
   ```

2. Add shebang:
   ```bash
   #!/usr/bin/env bash
   ```

3. Write your script

4. Test it:
   ```bash
   mytool
   ```

5. Commit:
   ```bash
   git add bin/mytool
   git commit -m "add mytool command"
   ```

---

## PATH Configuration

Tools in `bin/` are added to `$PATH` in `.zshrc`:

```zsh
path=(
  $path
  $DOTFILES/bin
  # ...
)
```

This means any executable in `bin/` is available system-wide without specifying the full path.

---

## Tool Categories

**Development Utilities:**
- mkbin, mkscript
- repo-history
- tmux-sessionizer

**Asset Management:**
- decrypt-assets

**Display/Preview:**
- colorcat
- figlet-preview

---

## Dependencies

Most tools require:
- ✅ Standard Unix tools (bash, cat, etc.)
- ✅ Tools installed via mise (see `.config/mise/config.toml`)

Specific requirements per tool listed in tool descriptions above.

---

## Best Practices

1. **Keep tools focused:** One tool, one job
2. **Add usage info:** Include help text with `-h` or `--help`
3. **Check dependencies:** Use `command -v tool &>/dev/null` before calling external commands
4. **Use environment variables:** `$DOTFILES`, `$EDITOR`, `$HOME`
5. **Make them portable:** Avoid hardcoded paths or user-specific config
6. **Document in this file:** Update this doc when adding new tools
