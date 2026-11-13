#!/usr/bin/env nix-shell
#!nix-shell -i bash -p python3 coreutils git
# shellcheck shell=bash

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
pkg_dir="$repo_root/pkgs/by-name/bw/bw-ssh-agent-filter"
go_bin="$(timeout 5m nix build --no-link --print-out-paths "$repo_root#bw-ssh-agent-filter.go")/bin/go"

work=$(mktemp -d)
trap 'chmod -R u+w "$work"; rm -rf -- "$work"' EXIT
cp -R -- "$pkg_dir/." "$work/source"
mkdir -p "$work/home"

export HOME="$work/home"
export GOPATH="$work/go"
export GOCACHE="$work/go-cache"
export GOTOOLCHAIN=local
export GOENV=off
export GOWORK=off
export GOFLAGS=

cd "$work/source"
timeout 5m "$go_bin" mod tidy
timeout 5m "$go_bin" mod vendor
vendor_hash=$(nix hash path --type sha256 --sri vendor)

python3 - "$pkg_dir" "$work/source" "$vendor_hash" <<'PY'
import os
import pathlib
import re
import sys
import tempfile

package_dir, prepared = map(pathlib.Path, sys.argv[1:3])
package = package_dir / "package.nix"
updated, count = re.subn(
    r'(?m)^  vendorHash = "sha256-[A-Za-z0-9+/=]+";$',
    f'  vendorHash = "{sys.argv[3]}";',
    package.read_text(),
)
if count != 1:
    raise SystemExit("Expected exactly one vendorHash in package.nix; no files updated")

updates = {package: updated.encode()}
updates.update({package_dir / name: (prepared / name).read_bytes() for name in ("go.mod", "go.sum")})
for path, content in updates.items():
    if path.read_bytes() == content:
        continue
    fd, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(fd, "wb") as output:
            output.write(content)
        os.chmod(temporary, path.stat().st_mode & 0o777)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
PY

printf 'bw-ssh-agent-filter vendorHash: %s\n' "$vendor_hash"
