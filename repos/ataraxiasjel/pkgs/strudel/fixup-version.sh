#!/usr/bin/env nix-shell
#!nix-shell -i bash -p gnused gnugrep
# Normalize `version` after `nix-update-script --version=branch`.
#
# Upstream tags are per-npm-package (e.g. `@strudel/codemirror@1.3.0`,
# `superdough@1.3.0`) with independent versioning, so nix-update derives
# versions like `@strudel/codemirror@1.3.0-unstable-YYYY-MM-DD` from whatever
# tag the Codeberg API returns first. This package tracks the whole repo
# (website build), not one npm subpackage, so the version must stay
# `0-unstable-YYYY-MM-DD`. Rewrite the version line in place, preserving the
# date nix-update just wrote.
#
# It is executed via passthru.updateScript sequence as a plain subprocess
# in the user's environment (with network for the nix-update step, but this
# fixup itself is a pure local rewrite), not inside a Nix build sandbox.
#
# Usage: fixup-version.sh <package-dir>   (e.g. ./pkgs/strudel)

set -euo pipefail

PKG_DIR="${1:?usage: fixup-version.sh <package-dir>}"
FILE="$PKG_DIR/default.nix"

if [[ ! -f "$FILE" ]]; then
  echo "error: $FILE not found" >&2
  exit 1
fi

# Strip any tag-derived prefix (scoped `@strudel/...@1.3.0` or plain `1.3.0`),
# forcing the `0-` base nixpkgs uses for snapshot packages without a single
# release version. Anchored to the version line only; a no-op unless the
# version contains `-unstable-`.
sed -i -E 's/^(\s*version = ")[^"]*-unstable-/\10-unstable-/' "$FILE"

VERSION="$(grep -oP '^\s*version = "\K[^"]+' "$FILE" | head -n 1 || true)"
if [[ -z "$VERSION" ]]; then
  echo "error: could not parse version from $FILE" >&2
  exit 1
fi

echo "strudel: normalized version to $VERSION"
