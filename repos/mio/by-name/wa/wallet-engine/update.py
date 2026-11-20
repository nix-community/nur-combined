#!/usr/bin/env python3
"""Update wallet-engine to the tip of upstream's default branch.

The package has three pins that must move together: the source revision (and
its hash), the `cargoHash` of the library build, and the hash of the separate
`bindgen/cpp` vendor tree. Upstream's tags stop at v0.0.7, so the version keeps
the repo convention `<latest-tag>-unstable-<commit-date>`.

The two vendor hashes are fixed-output derivations whose contents are produced
by cargo, so they cannot be prefetched from a URL: force a mismatch with
`lib.fakeHash`, let Nix report the real hash, and write it back.
"""

import re
import subprocess
import tempfile
from pathlib import Path

REPO = "https://github.com/i582/wallet-engine.git"
PKG_REL = Path("by-name/wa/wallet-engine/package.nix")


def run(cmd, check=True):
    return subprocess.run(cmd, check=check, text=True, capture_output=True)


def git(*args):
    return run(["git", *args]).stdout.strip()


def latest_tag():
    out = git("ls-remote", "--tags", REPO)
    tags = [
        line.split("refs/tags/")[1]
        for line in out.splitlines()
        if "refs/tags/" in line and not line.endswith("^{}")
    ]
    versions = [t.lstrip("v") for t in tags if re.fullmatch(r"v\d+(\.\d+)*", t)]
    if not versions:
        raise SystemExit("error: no release tags found upstream")
    return max(versions, key=lambda v: tuple(int(x) for x in v.split(".")))


def head_commit():
    """Latest commit on the default branch, without cloning the history."""
    return git("ls-remote", REPO, "HEAD").split()[0]


def commit_date(sha):
    with tempfile.TemporaryDirectory() as tmp:
        git("init", "-q", tmp)
        git("-C", tmp, "remote", "add", "origin", REPO)
        git("-C", tmp, "fetch", "-q", "--depth=1", "origin", sha)
        return git("-C", tmp, "log", "-1", "--format=%cs", "FETCH_HEAD")


def sri_hash(url):
    raw = run(["nix-prefetch-url", "--unpack", url]).stdout.strip().splitlines()[-1]
    return run(
        ["nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", raw]
    ).stdout.strip()


def system():
    return run(["nix", "eval", "--raw", "--impure", "--expr", "builtins.currentSystem"]).stdout.strip()


def fake_hash_loop(pkg_nix, label, pattern):
    """Replace pattern's `h` group with lib.fakeHash, then with the real hash."""
    text = pkg_nix.read_text()
    match = re.search(pattern, text, re.S)
    if match is None:
        raise SystemExit(f"error: could not find {label} in package.nix")
    start, end = match.span("h")
    old = match.group("h")
    # Replace the quoted value with bare `lib.fakeHash` (package.nix has `lib`
    # in scope); a quoted "lib.fakeHash" would just be an invalid hash string.
    pkg_nix.write_text(text[: start - 1] + "lib.fakeHash" + text[end + 1 :])

    expr = f".#legacyPackages.{system()}.wallet-engine"
    result = run(["nix", "build", expr, "--no-link"], check=False)
    got = re.search(r"got:\s+(sha256-[A-Za-z0-9+/=]+)", result.stderr)
    if got is None:
        pkg_nix.write_text(text)
        raise SystemExit(
            "error: could not determine new hash for "
            f"{label}:\n{result.stderr[-2000:]}"
        )
    new = got.group(1)
    pkg_nix.write_text(pkg_nix.read_text().replace("lib.fakeHash", f'"{new}"', 1))
    return old, new


def main():
    pkg_nix = Path(git("rev-parse", "--show-toplevel")) / PKG_REL
    original = pkg_nix.read_text()
    text = original

    rev = head_commit()
    version = f"{latest_tag()}-unstable-{commit_date(rev)}"

    old_rev = re.search(r'(?m)^\s*rev = "([^"]+)";', text).group(1)
    old_version = re.search(r'(?m)^\s*version = "([^"]+)";', text).group(1)
    print(f"Version: {old_version} -> {version}")
    print(f"Source:  {old_rev} -> {rev}")

    # The vendor hashes are not URL-prefetchable, so they are always re-checked:
    # a revision can stay put while its vendored dependencies change.

    src_hash = sri_hash(f"https://github.com/i582/wallet-engine/archive/{rev}.tar.gz")
    text = re.sub(r'(?m)^(\s*version = )"[^"]+"', rf'\g<1>"{version}"', text, count=1)
    text = re.sub(r'(?m)^(\s*rev = )"[^"]+"', rf'\g<1>"{rev}"', text, count=1)
    text = re.sub(
        r'(?m)^(\s*hash = )"[^"]+"', rf'\g<1>"{src_hash}"', text, count=1
    )
    pkg_nix.write_text(text)
    print(f"Source hash: {src_hash}")

    # Order matters: each build reports the first hash mismatch it hits, so the
    # library vendor tree must be fixed before the bindgen one.
    for label, pattern in [
        ("cargoHash", r'cargoHash = "(?P<h>[^"]+)";'),
        (
            "bindgenCargoDeps",
            r'bindgenCargoDeps = rustPlatform\.fetchCargoVendor \{.*?hash = "(?P<h>[^"]+)";',
        ),
    ]:
        old, new = fake_hash_loop(pkg_nix, label, pattern)
        print(f"{label}: {old} -> {new}")

    # Upstream HEAD is not always buildable (1d6f4a2 broke the uniffi derives),
    # so never leave an unbuildable pin behind: revert to the previous one.
    build = run(
        ["nix", "build", f".#legacyPackages.{system()}.wallet-engine", "--no-link"],
        check=False,
    )
    if build.returncode != 0:
        pkg_nix.write_text(original)
        raise SystemExit(
            f"error: {rev} does not build upstream, keeping the previous pin\n"
            f"{build.stderr[-2000:]}"
        )
    print(f"wallet-engine {version} builds; package.nix updated.")


if __name__ == "__main__":
    main()
