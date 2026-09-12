#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p git -p gnused -p nix -p python3
# shellcheck shell=bash
set -euo pipefail

# unstableGitUpdater (update-source-version) is unusable for this package: when
# the version string changes while the rev stays the same (new tag on an old
# commit), its rev replacement is a no-op and it dies mid-run, leaving its
# fixed sha256 temp hash (AzH1rZF...) in the file; every later run then dies at
# the temp hash replacement itself (old hash == temp hash). So version, rev and
# hash are rewritten directly here, and the result is verified by building src.

FILE="$(dirname "$(readlink -f "$0")")/default.nix"
ATTR="${UPDATE_NIX_ATTR_PATH:-uncategorized.openssl-oqs-provider}"

python3 - "$FILE" <<'PYEOF'
import json
import re
import subprocess
import sys

path = sys.argv[1]
content = open(path).read()

feed = subprocess.run(
    ['curl', '-fsSL', 'https://github.com/open-quantum-safe/oqs-provider/commits.atom'],
    capture_output=True, text=True, check=True).stdout
entry = re.search(r'<entry>.*?</entry>', feed, re.S).group(0)
new_rev = re.search(r'<id>[^<]*/([0-9a-f]{40})</id>', entry).group(1)
new_date = re.search(r'<updated>([0-9-]+)T', entry).group(1)

tags = subprocess.run(
    ['git', 'ls-remote', '--tags', 'https://github.com/open-quantum-safe/oqs-provider'],
    capture_output=True, text=True, check=True).stdout
tag_names = re.findall(r'refs/tags/(v?[0-9][0-9a-zA-Z.-]+)$', tags, re.M)


def vkey(t):
    # releases rank above prereleases of the same base version
    # (sort -V would rank 0.12.0-rc1 above 0.12.0)
    m = re.match(r'v?([0-9]+(?:\.[0-9]+)*)(?:-(rc|beta|alpha)\.?(\d+)?)?$', t)
    base = [int(x) for x in m.group(1).split('.')]
    base += [0] * (3 - len(base))
    pre = {'alpha': 0, 'beta': 1, 'rc': 2}.get(m.group(2), 3)
    return base + [pre, int(m.group(3) or 0)]


new_tag = sorted(tag_names, key=vkey)[-1].lstrip('v')

seg_match = re.search(r'src = fetchFromGitHub \{[^}]*\}', content)
seg = seg_match.group(0)
old_rev = re.search(r'rev = "([0-9a-f]{40})"', seg).group(1)
old_hash = re.search(r'hash = "([^"]+)"', seg).group(1)

# rev unchanged and hash not poisoned -> nothing to do
if new_rev == old_rev and old_hash != 'sha256-AzH1rZFqEH8sovZZfJykvsEmCedEZWigQFHWHl6/PdE=':
    print(f'openssl-oqs-provider already at {new_rev}')
    sys.exit(0)

url = f'https://github.com/open-quantum-safe/oqs-provider/archive/{new_rev}.tar.gz'
prefetch = subprocess.run(['nix', 'store', 'prefetch-file', '--json', '--unpack', url],
                          capture_output=True, text=True, check=True)
new_hash = json.loads(prefetch.stdout)['hash']

new_version = f'{new_tag}-unstable-{new_date}'
old_version = re.search(r'version = "([^"]+)"', content).group(1)

seg = re.sub(r'rev = "[0-9a-f]{40}"', f'rev = "{new_rev}"', seg)
seg = re.sub(r'hash = "sha256-[^"]+"', f'hash = "{new_hash}"', seg)
content = content.replace(seg_match.group(0), seg)
content = re.sub(r'version = "[^"]+"', f'version = "{new_version}"', content, count=1)
open(path, 'w').write(content)
print(f'openssl-oqs-provider: {old_version} -> {new_version}')
PYEOF

nix build --no-link ".#$ATTR.src"
