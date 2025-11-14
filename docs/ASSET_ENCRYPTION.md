# Age Encryption for Static Assets

Quick reference for encrypting/decrypting private assets (fonts, credentials, etc.) using age.

## Prerequisites

```bash
# age is installed via mise (see .config/mise/config.toml)
age --version
```

## Key Management

### Generate New Keys

**Only do this once, on your primary machine:**

```bash
# Generate keypair
age-keygen -o ~/.dotfiles/age.txt

# Extract public key and save to recipients file
grep "public key:" ~/.dotfiles/age.txt | cut -d: -f2 | tr -d ' ' > ~/.dotfiles/.age-recipients.txt

# Important: Add age.txt to .gitignore (should already be there)
echo "age.txt" >> ~/.dotfiles/.gitignore
```

### Export Keys to New Machine

**From existing machine:**

```bash
# Copy private key somewhere secure (use encrypted USB, 1Password, etc.)
cat ~/.dotfiles/age.txt
# Save this output securely
```

**On new machine:**

```bash
# Restore private key
cat > ~/.dotfiles/age.txt <<'EOF'
# AGE SECRET KEY: age1...
your-private-key-here
EOF

chmod 600 ~/.dotfiles/age.txt
```

**Important:** Never commit `age.txt` to git. Only `.age-recipients.txt` (public key) should be in the repo.

## Encrypting Assets

### Encrypt a Single File

```bash
cd ~/.dotfiles/static

# Encrypt file
age --encrypt --recipients-file ../.age-recipients.txt \
  -o myfile.tar.gz.age myfile.tar.gz

# Verify it worked
ls -lh myfile.tar.gz.age

# Delete unencrypted original
rm myfile.tar.gz
```

### Encrypt Directory (as tarball)

```bash
cd ~/.dotfiles/static

# Create tarball
tar czf fonts.tar.gz fonts/

# Encrypt tarball
age --encrypt --recipients-file ../.age-recipients.txt \
  -o fonts.tar.gz.age fonts.tar.gz

# Clean up
rm fonts.tar.gz
rm -rf fonts/

# Commit encrypted file
git add fonts.tar.gz.age
```

## Decrypting Assets

### Using the decrypt-assets Script

```bash
# Decrypt fonts (built-in script)
decrypt-assets
```

**What it does:**
- Decrypts `static/fonts.tar.gz.age` → `static/fonts.tar.gz`
- Extracts tarball to `static/fonts/`
- Requires `age.txt` private key in `~/.dotfiles/`

### Manual Decryption

```bash
cd ~/.dotfiles/static

# Decrypt file
age --decrypt -i ../age.txt \
  -o fonts.tar.gz fonts.tar.gz.age

# Extract if tarball
tar xzf fonts.tar.gz

# Clean up tarball (keep encrypted version)
rm fonts.tar.gz
```

## Current Encrypted Assets

| File | Contents | Script |
|------|----------|--------|
| `static/fonts.tar.gz.age` | Nerd fonts (commercial/licensed) | `bin/decrypt-assets` |

## Workflow for Adding New Assets

1. **Create asset:**
   ```bash
   cd ~/.dotfiles/static
   tar czf mynewasset.tar.gz mynewasset/
   ```

2. **Encrypt:**
   ```bash
   age --encrypt --recipients-file ../.age-recipients.txt \
     -o mynewasset.tar.gz.age mynewasset.tar.gz
   ```

3. **Clean up unencrypted files:**
   ```bash
   rm mynewasset.tar.gz
   rm -rf mynewasset/
   ```

4. **Commit:**
   ```bash
   git add static/mynewasset.tar.gz.age
   git commit -m "add encrypted mynewasset"
   ```

5. **(Optional) Create decrypt script** in `bin/` similar to `decrypt-assets`

## Troubleshooting

### "age.txt: no such file"

You're on a new machine without the private key:
```bash
# Get private key from secure storage (1Password, etc.)
# Create the file:
cat > ~/.dotfiles/age.txt <<'EOF'
# Paste private key here
EOF
chmod 600 ~/.dotfiles/age.txt
```

### "no identity matched"

The private key doesn't match the public key used to encrypt:
- Verify you're using the correct `age.txt`
- Check `.age-recipients.txt` matches your public key:
  ```bash
  grep "public key:" ~/.dotfiles/age.txt
  cat ~/.dotfiles/.age-recipients.txt
  ```

### Re-encrypt with New Key

If you generate a new keypair and need to re-encrypt:

```bash
cd ~/.dotfiles/static

# Decrypt with old key
age --decrypt -i ../age.txt.old -o fonts.tar.gz fonts.tar.gz.age

# Re-encrypt with new key
age --encrypt --recipients-file ../.age-recipients.txt \
  -o fonts.tar.gz.age fonts.tar.gz

# Clean up
rm fonts.tar.gz
```

## Security Notes

- **Private key location:** `~/.dotfiles/age.txt` (gitignored, never commit)
- **Public key location:** `~/.dotfiles/.age-recipients.txt` (committed to repo)
- Private key should be backed up in secure location (password manager, encrypted backup)
- `chmod 600` your private key to restrict access
- Encrypted assets can be safely committed to public repos

## Quick Reference

```bash
# Encrypt
age -e -R .age-recipients.txt -o file.age file

# Decrypt
age -d -i age.txt -o file file.age

# Generate keys
age-keygen -o age.txt
```
