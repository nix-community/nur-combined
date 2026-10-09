#!/usr/bin/env bash
set -euo pipefail

# Fetch all platform hashes before changing the package, so failed downloads
# never leave a partially updated derivation. FORCE_VERSION refreshes a release.
REPO="steipete/CodexBar"
NIX_FILE="pkgs/codexbar-cli/default.nix"

if [[ -f "$NIX_FILE" ]]; then
  REPO_ROOT=$(pwd -P)
else
  REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
fi
cd "$REPO_ROOT"

for tool in curl python3 nix; do
  command -v "$tool" >/dev/null || { echo "error: $tool is required" >&2; exit 1; }
done

current=$(sed -n -E 's/^[[:space:]]*version[[:space:]]*=[[:space:]]*"([^"]+)";$/\1/p' "$NIX_FILE")
version=${FORCE_VERSION:-}
if [[ -z "$version" ]]; then
  version=$(curl -fsSL -H 'Accept: application/vnd.github+json' \
    "https://api.github.com/repos/${REPO}/releases/latest" \
    | python3 -c 'import json, sys; print(json.load(sys.stdin)["tag_name"].removeprefix("v"))')
fi

[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "error: invalid version: $version" >&2; exit 1; }
if [[ "$version" == "$current" && -z "${FORCE_VERSION:-}" ]]; then
  echo "codexbar-cli is already up-to-date ($version)."
  exit 0
fi

echo "Updating codexbar-cli: $current -> $version"
declare -A hashes
for arch in x86_64 aarch64; do
  url="https://github.com/${REPO}/releases/download/v${version}/CodexBarCLI-v${version}-linux-musl-${arch}.tar.gz"
  echo "Prefetching ${arch}-linux from $url ..." >&2
  hashes[$arch]=$(nix --extra-experimental-features 'nix-command flakes' \
    store prefetch-file --json "$url" \
    | python3 -c 'import json, sys; print(json.load(sys.stdin)["hash"])')
done

NEW_VERSION="$version" H_X86_64="${hashes[x86_64]}" H_AARCH64="${hashes[aarch64]}" \
NIX_FILE="$NIX_FILE" python3 <<'PY'
from pathlib import Path
import os
import re

path = Path(os.environ["NIX_FILE"])
text = path.read_text()
replacements = {
    r'(^\s*version\s*=\s*")[^"]+(";)': os.environ["NEW_VERSION"],
    r'("x86_64-linux"\s*=\s*")[^"]+(";)': os.environ["H_X86_64"],
    r'("aarch64-linux"\s*=\s*")[^"]+(";)': os.environ["H_AARCH64"],
}
for pattern, value in replacements.items():
    text, count = re.subn(pattern, lambda match: match[1] + value + match[2], text, flags=re.MULTILINE)
    if count != 1:
        raise SystemExit(f"expected one match for {pattern}, found {count}")

path.write_text(text)
PY

echo "Update complete."
