#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p jq -p gnused -p nix -p python3
# shellcheck shell=bash
set -euo pipefail

DIR="$(dirname "$(readlink -f "$0")")"

python3 - "$DIR/sources.json" <<'PYEOF'
import json
import re
import subprocess
import sys

path = sys.argv[1]
sources = json.load(open(path))


def prefetch_unpack(url):
    r = subprocess.run(['nix', 'store', 'prefetch-file', '--json', '--unpack', url],
                       capture_output=True, text=True)
    return json.loads(r.stdout)['hash'] if r.returncode == 0 else None


def prefetch_file(url):
    r = subprocess.run(['nix', 'store', 'prefetch-file', '--json', url],
                       capture_output=True, text=True)
    return json.loads(r.stdout)['hash'] if r.returncode == 0 else None


# --- openresty core ---------------------------------------------------------
page = sys.stdin if False else None
html = subprocess.run(['curl', '-fsSL', 'https://openresty.org/en/download.html'],
                      capture_output=True, text=True, check=True).stdout
m = re.findall(r'openresty-([0-9.]+)\.tar\.gz', html)
new_ver = max(set(m), key=lambda v: [int(x) for x in v.split('.')]) if m else None
o = sources['openresty']
if new_ver and new_ver != o['version']:
    url = o['url'].replace(o['version'], new_ver)
    h = prefetch_file(url)
    if h:
        print(f"openresty: {o['version']} -> {new_ver}")
        o.update(version=new_ver, url=url, hash=h)
    else:
        print(f"openresty: failed to prefetch {url}, keeping {o['version']}")
else:
    print(f"openresty already at {o['version']}")

# --- github modules ----------------------------------------------------------
for name, s in sources.items():
    if name == 'openresty':
        continue
    repo = f"{s['owner']}/{s['repo']}"
    if 'rev' in s:
        feed = f"https://github.com/{repo}/commits.atom"
        html = subprocess.run(['curl', '-fsSL', feed], capture_output=True, text=True).stdout
        revs = re.findall(r'<id>[^<]*/([0-9a-f]{40})</id>', html)
        new_rev = revs[0] if revs else None
        if not new_rev:
            print(f"WARN: failed to detect new revision for {name}")
            continue
        if new_rev == s['rev']:
            print(f"{name} already at {new_rev}")
            continue
        url = f"https://github.com/{repo}/archive/{new_rev}.tar.gz"
        h = prefetch_unpack(url)
        if not h:
            print(f"WARN: failed to prefetch {name} {new_rev}")
            continue
        print(f"{name}: {s['rev'][:12]} -> {new_rev[:12]}")
        s['rev'] = new_rev
        s['hash'] = h
    else:  # tag-based
        feed = subprocess.run(
            ['curl', '-fsSL', f'https://github.com/{repo}/releases.atom'],
            capture_output=True, text=True)
        tags = re.findall(r'releases/tag/([^"<>]+)', feed.stdout) \
            if feed.returncode == 0 else []
        if not tags:
            print(f"WARN: failed to detect new tag for {name}")
            continue
        # releases feed is newest-first; lexicographic sort would pick wrong
        # versions (e.g. 0.9.0 over 0.15.0)
        new_tag = tags[0]
        if new_tag == s['tag']:
            print(f"{name} already at {new_tag}")
            continue
        url = f"https://github.com/{repo}/archive/refs/tags/{new_tag}.tar.gz"
        h = prefetch_unpack(url)
        if not h:
            print(f"WARN: failed to prefetch {name} {new_tag}")
            continue
        print(f"{name}: {s['tag']} -> {new_tag}")
        s['tag'] = new_tag
        s['hash'] = h

with open(path, 'w') as f:
    json.dump(sources, f, indent=2, sort_keys=True)
    f.write('\n')
PYEOF
