#!/usr/bin/env nix-shell
#!nix-shell -i bash -p prefetch-npm-deps nix-prefetch-github jq nodejs git curl nixfmt
# Regenerate vendored npm lockfiles (upstream ships only bun.lock),
# recompute src + npmDeps hashes and patch default.nix atomically.

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

NEW_REV="$(git ls-remote "https://github.com/$REPO.git" "refs/tags/${TAG_PREFIX}${NEW_VERSION}" 2>/dev/null | cut -f1)"
if [ -z "$NEW_REV" ]; then
  echo "error: no rev for tag ${TAG_PREFIX}${NEW_VERSION}" >&2
  exit 1
fi

curl -fsSL "https://github.com/$REPO/archive/${TAG_PREFIX}${NEW_VERSION}.tar.gz" -o "$TMPDIR_OCX/src.tar.gz"
mkdir -p "$TMPDIR_OCX/src"
tar -xzf "$TMPDIR_OCX/src.tar.gz" -C "$TMPDIR_OCX/src"
SRC="$(find "$TMPDIR_OCX/src" -mindepth 1 -maxdepth 1 -type d | head -n1)"

(
  cd "$SRC"
  awk '!/"bun":/' package.json > package.json.tmp && mv package.json.tmp package.json
  npm install --package-lock-only --ignore-scripts --no-audit --no-fund
)
(
  cd "$SRC/gui"
  npm install --package-lock-only --ignore-scripts --no-audit --no-fund
)

echo "computing hashes..."
SRC_HASH="$(nix-prefetch-github --rev "$NEW_REV" "$(dirname "$REPO")" "$(basename "$REPO")" 2>/dev/null | jq -r '.hash')"
ROOT_DEPS_HASH="$(prefetch-npm-deps "$SRC/package-lock.json")"
GUI_DEPS_HASH="$(prefetch-npm-deps "$SRC/gui/package-lock.json")"

if [ -z "$SRC_HASH" ] || [ -z "$ROOT_DEPS_HASH" ] || [ -z "$GUI_DEPS_HASH" ]; then
  echo "error: failed to compute hashes" >&2
  exit 1
fi

sed -i "s/^  version = \"[^\"]*\";/  version = \"$NEW_VERSION\";/" "$DEFAULT_NIX"
sed -i -E "/rev = \"v/ { n; s#hash = \"sha256-[^\"]*\";#hash = \"$SRC_HASH\";# }" "$DEFAULT_NIX"
sed -i -E "/pname = \"opencodex-gui\";/,/npmDepsHash = / s#npmDepsHash = \"sha256-[^\"]*\";#npmDepsHash = \"$GUI_DEPS_HASH\";#" "$DEFAULT_NIX"
sed -i -E "/pname = \"opencodex\";/,/npmDepsHash = / s#npmDepsHash = \"sha256-[^\"]*\";#npmDepsHash = \"$ROOT_DEPS_HASH\";#" "$DEFAULT_NIX"

for h in "$NEW_VERSION" "$SRC_HASH" "$ROOT_DEPS_HASH" "$GUI_DEPS_HASH"; do
  grep -qF "$h" "$DEFAULT_NIX" || { echo "error: failed to patch $h into default.nix" >&2; exit 1; }
done

cp "$SRC/package-lock.json" "$SCRIPT_DIR/package-lock.json"
cp "$SRC/gui/package-lock.json" "$SCRIPT_DIR/gui-package-lock.json"

nixfmt "$DEFAULT_NIX"

echo "opencodex: updated to $NEW_VERSION"
