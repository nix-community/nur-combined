#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p nodejs -p nix-update -p prefetch-npm-deps
# shellcheck shell=bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

nix-update "$UPDATE_NIX_ATTR_PATH" --version "$(npm view @waline/vercel version)" --src-only

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

tar xzf "$(nix build --no-link --print-out-paths .#waline.src)" -C "$TMPDIR"
cd "$TMPDIR/package" || exit 1
rm -rf node_modules
sed -i '/"@waline\/core":/d' package.json
npm install --ignore-scripts --no-audit --no-fund
cp package-lock.json "$SCRIPT_DIR/package-lock.json"
NEW_HASH=$(prefetch-npm-deps "$SCRIPT_DIR/package-lock.json")
sed -i "s|npmDepsHash = \"sha256-[^\"]*\";|npmDepsHash = \"$NEW_HASH\";|" "$SCRIPT_DIR/default.nix"
