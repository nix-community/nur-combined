#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p nodejs -p python3 -p prefetch-npm-deps -p nix-update
# shellcheck shell=bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

NEW_VERSION=$(npm view @agegr/pi-web version)
CURRENT_VERSION=$(nix eval --raw ".#$UPDATE_NIX_ATTR_PATH.version")
if [ "$NEW_VERSION" = "$CURRENT_VERSION" ]; then
  exit 0
fi
nix-update "$UPDATE_NIX_ATTR_PATH" --version "$NEW_VERSION" --src-only

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

cp -r "$(nix build --no-link --print-out-paths .#pi-web.src)" "$TMPDIR/source"
chmod -R u+w "$TMPDIR/source"
cd "$TMPDIR/source" || exit 1
rm -f package-lock.json npm-shrinkwrap.json
npm install --ignore-scripts --force
python3 <<'EOF'
import base64, hashlib, json, urllib.request
lock = json.load(open('package-lock.json'))
for meta in lock['packages'].values():
    url = meta.get('resolved')
    if url and not url.startswith('file:') and 'integrity' not in meta:
        meta['integrity'] = 'sha512-' + base64.b64encode(hashlib.sha512(urllib.request.urlopen(url, timeout=120).read()).digest()).decode()
json.dump(lock, open('package-lock.json', 'w'), indent=2)
open('package-lock.json', 'a').write('\n')
EOF
cp package-lock.json "$SCRIPT_DIR/package-lock.json"
NEW_HASH=$(prefetch-npm-deps "$SCRIPT_DIR/package-lock.json")
sed -i "s|npmDepsHash = \"sha256-[^\"]*\";|npmDepsHash = \"$NEW_HASH\";|" "$SCRIPT_DIR/default.nix"
