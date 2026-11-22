#!/usr/bin/env nix-shell
#!nix-shell -i bash -p gnused gnugrep
# Normalize `version` after `nix-update-script --version=branch`: upstream
# tags are per-npm-package (`@strudel/codemirror@1.3.0`, …), so force the
# snapshot form `0-unstable-YYYY-MM-DD`, keeping the date nix-update wrote.
# Usage: fixup-version.sh <package-dir>

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
