#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p jq -p gnused -p nix -p python3
# shellcheck shell=bash
set -euo pipefail

FILE="$(dirname "$(readlink -f "$0")")/default.nix"
NEW_VERSION=$(curl -fsSL 'https://api.github.com/repos/netbootxyz/netboot.xyz/releases?per_page=20' |
  jq -r '.[].tag_name' | grep -v '^v' | sort -V | tail -n1 || true)
[ -n "$NEW_VERSION" ] || {
  echo "Failed to detect new version"
  exit 1
}
OLD=$(grep -oP 'netboot\.xyz/releases/download/\K[0-9.]+' "$FILE" | head -n1)
if [ "$NEW_VERSION" = "$OLD" ]; then
  echo "netboot-xyz already at $OLD"
  exit 0
fi

URLS=()
while read -r U; do URLS+=("$U"); done < <(
  grep -oP 'https://github\.com/netbootxyz/netboot\.xyz/releases/download/[^"]*' "$FILE" |
    sed "s|download/$OLD/|download/$NEW_VERSION/|g" | sort -u
)

HASHES=()
for U in "${URLS[@]}"; do
  HASHES+=("$(nix store prefetch-file --json "$U" | jq -r .hash)")
done

sed -i "s|download/$OLD/|download/$NEW_VERSION/|g" "$FILE"
sed -i "s/version = \"$OLD\";/version = \"$NEW_VERSION\";/g" "$FILE"

python3 - "$FILE" "${URLS[@]}" -- "${HASHES[@]}" <<'PYEOF'
import re
import sys

path = sys.argv[1]
sep = sys.argv.index('--')
urls, hashes = sys.argv[2:sep], sys.argv[sep + 1:]
by_url = dict(zip(urls, hashes))
lines = open(path).read().split('\n')
url_re = re.compile(r'url = "([^"]+)";')
for i, ln in enumerate(lines):
    m = url_re.search(ln)
    if not m or m.group(1) not in by_url:
        continue
    for j in range(i + 1, min(i + 4, len(lines))):
        hm = re.match(r'^(\s*)hash = "sha256-[^"]+"', lines[j])
        if hm:
            lines[j] = f'{hm.group(1)}hash = "{by_url[m.group(1)]}";'
            break
open(path, 'w').write('\n'.join(lines))
PYEOF
echo "netboot-xyz updated to $NEW_VERSION"
