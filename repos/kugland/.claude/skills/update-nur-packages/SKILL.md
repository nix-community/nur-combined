---
name: update-nur-packages
description: Use when updating musescore or cursor packages in the nur-packages repo
---

# Update NUR Packages

Packages live in `pkgs/<name>/default.nix`. After updating, build both arches, then commit as `package: old -> new`.

## Musescore

```bash
# 1. Find latest release
gh api repos/musescore/MuseScore/releases/latest \
  --jq '{tag: .tag_name, assets: [.assets[] | select(.name | test("AppImage")) | .name]}'

# 2. Fetch hashes (version = e.g. 4.7.3.260608135, tag = v4.7.3)
nix-prefetch-url --type sha256 "https://github.com/musescore/MuseScore/releases/download/<tag>/MuseScore-Studio-<version>-x86_64.AppImage" 2>/dev/null
nix-prefetch-url --type sha256 "https://github.com/musescore/MuseScore/releases/download/<tag>/MuseScore-Studio-<version>-aarch64.AppImage" 2>/dev/null

# 3. Convert to SRI
nix hash convert --hash-algo sha256 --to sri <hash>
```

Update `version`, both `url`s and both `hash`es in `pkgs/musescore/default.nix`.

## Cursor

```bash
# 1. Get latest version and build hash from redirect URL (HEAD only, no download)
curl -sIL "https://api2.cursor.sh/updates/download/golden/linux-x64-appimage/cursor/latest" \
  -o /dev/null -w "%{url_effective}\n"
curl -sIL "https://api2.cursor.sh/updates/download/golden/linux-arm64-appimage/cursor/latest" \
  -o /dev/null -w "%{url_effective}\n"
# URLs contain version (e.g. 3.7.27) and production build hash

# 2. Fetch hashes
nix-prefetch-url --type sha256 "<x64-url>" 2>/dev/null
nix-prefetch-url --type sha256 "<arm64-url>" 2>/dev/null

# 3. Convert to SRI
nix hash convert --hash-algo sha256 --to sri <hash>
```

Update `version`, both `url`s and both `hash`es in `pkgs/cursor/default.nix`.

## Build & Commit

```bash
# Build both arches
nix build 'path:.#musescore'
nix build 'path:.#packages.aarch64-linux.musescore'

# Cursor is unfree
NIXPKGS_ALLOW_UNFREE=1 nix build 'path:.#cursor' --impure
NIXPKGS_ALLOW_UNFREE=1 nix build 'path:.#packages.aarch64-linux.cursor' --impure

# Commit format
git commit pkgs/<name>/default.nix -m "<name>: <old-version> -> <new-version>"
```
