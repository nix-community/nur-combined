#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p jq -p gnused -p nix -p python3
# shellcheck shell=bash
set -euo pipefail

FILE="$(dirname "$(readlink -f "$0")")/default.nix"
ATTR="${UPDATE_NIX_ATTR_PATH:-lantianCustomized.qemu}"

# Both overlays are written against one exact QEMU release: their patch series
# is only guaranteed to apply to that release, so a pin that targets a
# different QEMU is skipped rather than committed.
QEMU_VERSION="$(nix eval --raw ".#${ATTR}.version" 2>/dev/null || true)"
if [ -z "$QEMU_VERSION" ]; then
  echo "WARN: cannot determine the QEMU version of $ATTR; skipping update" >&2
  exit 0
fi

# marker|repo|file in the release archive naming its QEMU release|extraction pattern
TABLE=(
  'qemuVmvgaSrc|qemus/qemu-vmvga|readme.md|QEMU \K[0-9.]+'
  'nvkvmSrc|reindertpelsma/nvkvm-pv|scripts/build_qemu.sh|QEMU_VERSION="\K[0-9.]+'
)

for ROW in "${TABLE[@]}"; do
  IFS='|' read -r MARKER REPO PROBE PATTERN <<<"$ROW"

  TAG="$(curl -fsSL "https://github.com/$REPO/releases.atom" |
    grep -oP 'releases/tag/\K[^"]+' | head -n1 || true)"
  if [ -z "$TAG" ]; then
    echo "WARN: cannot detect the latest release of $REPO" >&2
    continue
  fi

  OLD_TAG="$(
    python3 - "$FILE" "$MARKER" <<'PYEOF'
import re
import sys

path, marker = sys.argv[1:]
m = re.search(re.escape(marker) + r'.*?tag = "([^"]+)"', open(path).read(), re.S)
print(m.group(1) if m else "")
PYEOF
  )"
  if [ "$TAG" = "$OLD_TAG" ]; then
    echo "$MARKER is already at $TAG"
    continue
  fi

  INFO="$(nix store prefetch-file --json --unpack \
    "https://github.com/$REPO/archive/refs/tags/$TAG.tar.gz")"
  TAG_QEMU_VERSION="$(grep -oP "$PATTERN" "$(jq -r .storePath <<<"$INFO")/$PROBE" | head -n1 || true)"
  if [ "$TAG_QEMU_VERSION" != "$QEMU_VERSION" ]; then
    echo "WARN: $REPO $TAG targets QEMU ${TAG_QEMU_VERSION:-unknown} but this" \
      "package builds QEMU $QEMU_VERSION; skipping" >&2
    continue
  fi

  python3 - "$FILE" "$MARKER" "$TAG" "$(jq -r .hash <<<"$INFO")" <<'PYEOF'
import re
import sys

path, marker, new_tag, new_hash = sys.argv[1:]
content = open(path).read()
m = re.search(
    re.escape(marker) + r'.*?tag = "([^"]+)".*?hash = "sha256-[^"]+"',
    content,
    re.S,
)
if not m:
    print(f"WARN: pin not found for {marker}")
    sys.exit(0)
seg = re.sub(r'tag = "[^"]+"', 'tag = "' + new_tag + '"', m.group(0))
seg = re.sub(r'hash = "sha256-[^"]+"', 'hash = "' + new_hash + '"', seg)
open(path, 'w').write(content.replace(m.group(0), seg))
PYEOF
  echo "$MARKER: $OLD_TAG -> $TAG"
done
