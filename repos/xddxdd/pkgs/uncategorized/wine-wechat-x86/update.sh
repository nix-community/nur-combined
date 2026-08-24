#!/usr/bin/env bash
NEW_VERSION=$(curl -fsSL 'https://api.github.com/repos/tom-snow/wechat-windows-versions/releases?per_page=20' |
  jq -r '.[].tag_name' | sed 's/^v//' | grep -E '^[0-9]+\.' | sort -V | tail -n1 || true)
[ -n "$NEW_VERSION" ] || {
  echo "Failed to detect new version"
  exit 1
}
OLD=$(grep -oP 'wechat-windows-versions/releases/download/v\K[0-9.]+' "$FILE" | head -n1)
if [ "$NEW_VERSION" = "$OLD" ]; then
  echo "wine-wechat-x86 already at $OLD"
  exit 0
fi

OLD_URL=$(grep -oP 'https://github\.com/tom-snow/wechat-windows-versions/releases/download/[^"]*\.exe' "$FILE" | head -n1)
NEW_HASH=$(nix store prefetch-file --json "${OLD_URL//"$OLD"/"$NEW_VERSION"}" | jq -r .hash)
sed -i "s|$OLD|$NEW_VERSION|g" "$FILE"

python3 - "$FILE" "$OLD_URL" "$NEW_URL" "$NEW_HASH" <<'PYEOF'
import re
import sys

path, old_url, new_url, h = sys.argv[1:]
lines = open(path).read().split('\n')
for i, ln in enumerate(lines):
    if old_url in ln:
        lines[i] = ln.replace(old_url, new_url)
        for j in range(i + 1, min(i + 4, len(lines))):
            hm = re.match(r'^(\s*)hash = "sha256-[^"]+"', lines[j])
            if hm:
                lines[j] = f'{hm.group(1)}hash = "{h}";'
                break
        break
open(path, 'w').write('\n'.join(lines))
PYEOF
echo "wine-wechat-x86 updated to $NEW_VERSION"
