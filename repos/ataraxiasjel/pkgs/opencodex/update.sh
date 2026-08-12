#!/usr/bin/env nix-shell
#!nix-shell -i bash -p prefetch-npm-deps nix-prefetch-github jq nodejs git curl nixfmt
# Update script for opencodex.
#
# Why not plain `nix-update-script`? The upstream repo ships only `bun.lock`
# (which nixpkgs cannot consume) and no `package-lock.json`, so the Nix package
# vendors generated npm lockfiles. Running `nix-update` alone would bump version
# and src/npmDeps hashes but could not regenerate those vendored lockfiles. This
# script therefore does the whole job: fetch the new source, regenerate both
# lockfiles with npm, recompute the src + npmDeps hashes, and patch default.nix.
#
# It is executed by update.nix / nix-update as a plain subprocess in the user's
# environment (with network + tooling), not inside a Nix build sandbox.
#
# The `#!nix-shell` shebang populates a hermetic PATH with the tools this script
# needs (prefetch-npm-deps, nix-prefetch-github, jq, nodejs/npm, git, curl,
# nixfmt); awk/sed/grep/tar/find come from the nix-shell base environment.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_NIX="$SCRIPT_DIR/default.nix"
TMPDIR_OCX="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_OCX"' EXIT

REPO=lidge-jun/opencodex
TAG_PREFIX=v

current_version() {
  grep -oP '^  version = "\K[^"]+' "$DEFAULT_NIX"
}

new_version() {
  if [ $# -ge 1 ] && [ -n "$1" ]; then
    printf '%s\n' "$1"
  else
    # Latest stable vX.Y.Z tag from the remote (excludes -preview.*).
    git ls-remote --tags "https://github.com/$REPO.git" 2>/dev/null \
      | grep -oP "${TAG_PREFIX}\K[0-9]+\.[0-9]+\.[0-9]+$" \
      | sort -V | tail -n1
  fi
}

OLD_VERSION="$(current_version)"
NEW_VERSION="$(new_version "${1:-}")"

if [ -z "$NEW_VERSION" ]; then
  echo "error: could not determine a new version" >&2
  exit 1
fi

if [ "$OLD_VERSION" = "$NEW_VERSION" ]; then
  echo "opencodex is already at version $NEW_VERSION"
  exit 0
fi

echo "opencodex: $OLD_VERSION -> $NEW_VERSION"

# --- fetch the new source tarball ------------------------------------------
NEW_REV="$(git ls-remote "https://github.com/$REPO.git" "refs/tags/${TAG_PREFIX}${NEW_VERSION}" 2>/dev/null | cut -f1)"
if [ -z "$NEW_REV" ]; then
  echo "error: no rev for tag ${TAG_PREFIX}${NEW_VERSION}" >&2
  exit 1
fi

curl -fsSL "https://github.com/$REPO/archive/${TAG_PREFIX}${NEW_VERSION}.tar.gz" -o "$TMPDIR_OCX/src.tar.gz"
mkdir -p "$TMPDIR_OCX/src"
tar -xzf "$TMPDIR_OCX/src.tar.gz" -C "$TMPDIR_OCX/src"
SRC="$(find "$TMPDIR_OCX/src" -mindepth 1 -maxdepth 1 -type d | head -n1)"

# --- regenerate the root lockfile (bun stripped) ----------------------------
(
  cd "$SRC"
  awk '!/"bun":/' package.json > package.json.tmp && mv package.json.tmp package.json
  npm install --package-lock-only --ignore-scripts --no-audit --no-fund
)
cp "$SRC/package-lock.json" "$SCRIPT_DIR/package-lock.json"

# --- regenerate the gui lockfile ---------------------------------------------
(
  cd "$SRC/gui"
  npm install --package-lock-only --ignore-scripts --no-audit --no-fund
)
cp "$SRC/gui/package-lock.json" "$SCRIPT_DIR/gui-package-lock.json"

# --- recompute hashes --------------------------------------------------------
echo "computing hashes..."
SRC_HASH="$(nix-prefetch-github --rev "$NEW_REV" "$(dirname "$REPO")" "$(basename "$REPO")" 2>/dev/null | jq -r '.hash')"
ROOT_DEPS_HASH="$(prefetch-npm-deps "$SCRIPT_DIR/package-lock.json")"
GUI_DEPS_HASH="$(prefetch-npm-deps "$SCRIPT_DIR/gui-package-lock.json")"

if [ -z "$SRC_HASH" ]; then
  echo "error: failed to compute src hash" >&2
  exit 1
fi

# --- patch default.nix -------------------------------------------------------
# version
sed -i "s/^  version = \"[^\"]*\";/  version = \"$NEW_VERSION\";/" "$DEFAULT_NIX"

# src hash (the `hash = "sha256-..."` that immediately follows `rev = "v...";`)
awk -v newhash="$SRC_HASH" '
  { lines[NR] = $0 }
  END {
    for (i = 1; i <= NR; i++) {
      print lines[i]
      if (lines[i] ~ /rev = "v/) {
        # next line is the src hash; edit it in-place on output
        if (i < NR && lines[i + 1] ~ /hash = "sha256-/) {
          sub(/hash = "sha256-[^"]*";/, "hash = \"" newhash "\";", lines[i + 1])
        }
      }
    }
  }
' "$DEFAULT_NIX" > "$DEFAULT_NIX.tmp" && mv "$DEFAULT_NIX.tmp" "$DEFAULT_NIX"

# npmDepsHash: the two occurrences are gui (first) and root (second) in order.
OLD_ROOT="$(grep -oP 'npmDepsHash = "\K[^"]+' "$DEFAULT_NIX" | sed -n '2p')"
OLD_GUI="$(grep -oP 'npmDepsHash = "\K[^"]+' "$DEFAULT_NIX" | sed -n '1p')"
sed -i "s#npmDepsHash = \"$OLD_GUI\";#npmDepsHash = \"$GUI_DEPS_HASH\";#" "$DEFAULT_NIX"
sed -i "s#npmDepsHash = \"$OLD_ROOT\";#npmDepsHash = \"$ROOT_DEPS_HASH\";#" "$DEFAULT_NIX"

# format
nixfmt "$DEFAULT_NIX"

echo "opencodex: updated to $NEW_VERSION"
