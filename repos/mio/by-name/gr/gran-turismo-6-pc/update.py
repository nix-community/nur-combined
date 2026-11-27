#!/usr/bin/env python3
"""Update Gran Turismo 6 PC and the RPCS3 revision/patch set it carries."""

from __future__ import annotations

import re
import subprocess
import sys
import tempfile
from pathlib import Path

REPOSITORY = "Mabec-games/Gran-Turismo-6-PC"
UPSTREAM = f"https://github.com/{REPOSITORY}"
RPCS3_SUBMODULES = (
    "fusion/fusion asmjit/asmjit yaml-cpp/yaml-cpp SoundTouch/soundtouch "
    "stblib/stb feralinteractive/feralinteractive wolfssl/wolfssl"
)


def run(argv: list[str], *, check: bool = True) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(argv, capture_output=True, text=True)
    if check and result.returncode != 0:
        raise SystemExit(f"{' '.join(argv)} failed:\n{result.stderr or result.stdout}")
    return result


def prefetch_unpacked_sri(url: str) -> str:
    base32 = run(["nix-prefetch-url", "--unpack", url]).stdout.strip().splitlines()[-1]
    return run(["nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", base32]).stdout.strip()


def replace_once(package: Path, text: str, pattern: str, replacement: str) -> str:
    updated, count = re.subn(pattern, replacement, text, count=1)
    if count != 1:
        raise SystemExit(f"update.py: could not match {pattern!r} in {package}")
    return updated


def rpcs3_source_hash(revision: str) -> str:
    expression = (
        'let p = import <nixpkgs> { config.allowUnfree = true; }; in '
        'p.fetchFromGitHub { owner = "RPCS3"; repo = "rpcs3"; '
        f' rev = "{revision}"; hash = p.lib.fakeHash; '
        f' postCheckout = "cd $out/3rdparty; git submodule update --init {RPCS3_SUBMODULES}"; }}'
    )
    result = run(["nix", "build", "--impure", "--no-link", "--expr", expression], check=False)
    match = re.search(r"got:\s+(sha256-[A-Za-z0-9+/=]+)", result.stderr + result.stdout)
    if match is None:
        raise SystemExit(f"update.py: could not derive the RPCS3 source hash:\n{result.stderr}")
    return match.group(1)


def latest_stable_tag() -> str:
    refs = run(["git", "ls-remote", "--tags", "--refs", f"{UPSTREAM}.git"]).stdout
    tags = [
        ref.split("\t")[1].removeprefix("refs/tags/")
        for ref in refs.splitlines()
        if ref.strip()
    ]
    stable = [tag for tag in tags if re.fullmatch(r"v\d+(\.\d+)*", tag)]
    if not stable:
        raise SystemExit("update.py: upstream has no stable vN.N.N tag")
    return max(stable, key=lambda tag: tuple(int(part) for part in tag[1:].split(".")))


def rpcs3_commit_date(revision: str) -> str:
    with tempfile.TemporaryDirectory(prefix="gt6-rpcs3-") as tmp:
        run(["git", "init", "-q", tmp])
        run(["git", "-C", tmp, "remote", "add", "origin", "https://github.com/RPCS3/rpcs3.git"])
        run(["git", "-C", tmp, "fetch", "-q", "--depth=1", "--filter=blob:none", "origin", revision])
        return run(["git", "-C", tmp, "log", "-1", "--format=%as", "FETCH_HEAD"]).stdout.strip()


def main() -> None:
    root = Path(run(["git", "rev-parse", "--show-toplevel"]).stdout.strip())
    package = root / "by-name/gr/gran-turismo-6-pc/package.nix"

    target_tag = sys.argv[1] if len(sys.argv) > 1 else None
    if target_tag is None:
        target_tag = latest_stable_tag()

    if not target_tag.startswith("v"):
        raise SystemExit("update.py: expected a v-prefixed upstream tag")
    version = target_tag[1:]

    with tempfile.TemporaryDirectory(prefix="gt6-source-") as tmp:
        run(["git", "init", "-q", tmp])
        run(["git", "-C", tmp, "remote", "add", "origin", f"{UPSTREAM}.git"])
        run(["git", "-C", tmp, "fetch", "-q", "--depth=1", "origin", f"refs/tags/{target_tag}"])
        revision = run(["git", "-C", tmp, "rev-parse", "FETCH_HEAD^{commit}"]).stdout.strip()
        run(["git", "-C", tmp, "checkout", "-q", "--detach", "FETCH_HEAD"])
        workflow = (Path(tmp) / ".github/workflows/linux.yml").read_text(encoding="utf-8")
        patch_paths = sorted((Path(tmp) / "emulator/gt6-patches").glob("*.diff"))
        patches = [
            (path.name, run(["nix", "hash", "file", "--type", "sha256", "--sri", str(path)]).stdout.strip())
            for path in patch_paths
        ]

    source_hash = prefetch_unpacked_sri(f"{UPSTREAM}/archive/{revision}.tar.gz")

    rpcs3_match = re.search(r"^\s*RPCS3_COMMIT:\s*([0-9a-f]{40})", workflow, re.MULTILINE)
    if rpcs3_match is None:
        raise SystemExit("update.py: no full RPCS3_COMMIT in .github/workflows/linux.yml")
    rpcs3_revision = rpcs3_match.group(1)
    rpcs3_date = rpcs3_commit_date(rpcs3_revision)
    rpcs3_hash = rpcs3_source_hash(rpcs3_revision)

    text = package.read_text(encoding="utf-8")
    text = replace_once(package, text, r'(?m)^  version = "[^"]+";$', f'  version = "{version}";')
    text = replace_once(package, text, r'(?m)^  sourceRev = "[0-9a-f]+";$', f'  sourceRev = "{revision}";')
    text = replace_once(
        package,
        text,
        r'(?ms)(  src = fetchFromGitHub \{\n    owner = "Mabec-games";\n    repo = "Gran-Turismo-6-PC";\n    rev = [^;]+;\n    hash = ")[^"]+(";)',
        rf'\g<1>{source_hash}\g<2>',
    )
    text = replace_once(package, text, r'(?m)^  rpcs3Rev = "[0-9a-f]+";$', f'  rpcs3Rev = "{rpcs3_revision}";')
    text = replace_once(
        package,
        text,
        r'(?m)^    version = "0\.0\.43-unstable-[0-9-]+";$',
        f'    version = "0.0.43-unstable-{rpcs3_date}";',
    )
    text = replace_once(
        package,
        text,
        r'(?ms)(      owner = "RPCS3";\n      repo = "rpcs3";\n      rev = [^;]+;\n      hash = ")[^"]+(";)',
        rf'\g<1>{rpcs3_hash}\g<2>',
    )
    text = replace_once(
        package,
        text,
        r'(?ms)^  gt6Patches = \[\n(?:.*?\n)*?  \];$',
        "  gt6Patches = [\n"
        + "\n".join(f'    (gt6Patch "{name}" "{patch_hash}")' for name, patch_hash in patches)
        + "\n  ];",
    )
    package.write_text(text, encoding="utf-8")
    run(["nixfmt", str(package)])

    print(f"updated {REPOSITORY} to {target_tag} ({revision})")
    print(f"RPCS3 {rpcs3_revision} ({rpcs3_date}) with {len(patches)} patches")


if __name__ == "__main__":
    main()
