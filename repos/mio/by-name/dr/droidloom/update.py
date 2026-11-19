#!/usr/bin/env python3
# Update droidloom's host source and the prebuilt Android image package.
#
# Upstream publishes both from the same rolling release cycle: the host source
# is the tip of `main`, and the image is an asset on the rolling `packages`
# release. Keep the two in sync.
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

REPO = "https://github.com/denialwm/droidloom.git"
ASSETS = "https://github.com/denialwm/droidloom/releases/expanded_assets/packages"
IMAGE_NAME = "droidloom-image-{base}-{build}-x86_64.pkg.tar.zst"


# Some hosts preload an allocator debug runtime (Scudo) through LD_PRELOAD,
# which makes the hardened nix binaries abort while they add store paths.
CHILD_ENV = {k: v for k, v in os.environ.items() if k != "LD_PRELOAD"}


def run(cmd):
    return subprocess.check_output(cmd, text=True, env=CHILD_ENV).strip()


def latest_rev():
    with tempfile.TemporaryDirectory() as td:
        run(["git", "init", "-q", td])
        run(["git", "-C", td, "remote", "add", "origin", REPO])
        run(["git", "-C", td, "fetch", "-q", "--depth=1", "--filter=blob:none", "origin", "HEAD"])
        rev = run(["git", "-C", td, "rev-parse", "FETCH_HEAD"])
        date = run(["git", "-C", td, "log", "-1", "--format=%cs", "FETCH_HEAD"])
    return rev, date


def latest_image():
    html = run(["curl", "-fsSL", ASSETS])
    found = re.findall(r"droidloom-image-(\d+\.\d+\.\d+)-(\d+)-x86_64\.pkg\.tar\.zst", html)
    if not found:
        raise SystemExit("error: no x86_64 image package found on the packages release")
    base, build = max(found, key=lambda m: (tuple(map(int, m[0].split("."))), int(m[1])))
    return base, int(build)


def prefetch(url, unpack):
    cmd = ["nix-prefetch-url"] + (["--unpack"] if unpack else []) + [url]
    raw = run(cmd).splitlines()[-1]
    return run(["nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", raw])


def replace_block(content, pattern, updates):
    """Rewrite attrs inside the first block matching `pattern`."""
    m = re.search(pattern, content, re.DOTALL)
    if not m:
        raise SystemExit(f"error: could not find block /{pattern}/ in package.nix")
    block = m.group(0)
    for attr, value in updates.items():
        block, n = re.subn(
            rf'(?m)^(\s*{attr}\s*=\s*)"[^"]+"',
            rf'\g<1>"{value}"',
            block,
            count=1,
        )
        if n != 1:
            raise SystemExit(f"error: could not update {attr} in block /{pattern}/")
    return content[: m.start()] + block + content[m.end():]


def main():
    try:
        repo_root = Path(run(["git", "rev-parse", "--show-toplevel"]))
    except subprocess.CalledProcessError:
        repo_root = Path(__file__).resolve().parents[3]
    pkg_nix = repo_root / "by-name/dr/droidloom/package.nix"
    content = pkg_nix.read_text(encoding="utf-8")

    rev, date = latest_rev()
    base, build = latest_image()
    version = f"{base}-unstable-{date}"
    image = IMAGE_NAME.format(base=base, build=build)
    image_url = f"https://github.com/denialwm/droidloom/releases/download/packages/{image}"

    old = re.search(r'(?m)^\s*rev = "([^"]+)";', content)
    old_rev = old.group(1) if old else None
    old_image = re.search(r'droidloom-image-[\d.]+-\d+-x86_64\.pkg\.tar\.zst', content)
    old_image = old_image.group(0) if old_image else None

    print(f"Source: {old_rev} -> {rev} ({date})")
    print(f"Image:  {old_image} -> {image}")

    if old_rev != rev:
        content, n = re.subn(
            r'(?m)^(\s*version = )"[^"]+"',
            rf'\g<1>"{version}"',
            content,
            count=1,
        )
        if n != 1:
            raise SystemExit("error: could not update version in package.nix")
        src_hash = prefetch(f"https://github.com/denialwm/droidloom/archive/{rev}.tar.gz", True)
        content = replace_block(
            content,
            r"src = fetchFromGitHub \{.*?\n  \};",
            {"rev": rev, "hash": src_hash},
        )
        # Keep the "same release cycle" comment in the header accurate.
        content = re.sub(
            r"(host source rev of )\d{4}-\d{2}-\d{2}(, image )[\d.]+-\d+",
            rf"\g<1>{date}\g<2>{base}-{build}",
            content,
            count=1,
        )

    if old_image != image:
        image_hash = prefetch(image_url, False)
        content = replace_block(
            content,
            r"imagePackage = fetchurl \{.*?\n  \};",
            {"url": image_url, "hash": image_hash},
        )

    pkg_nix.write_text(content, encoding="utf-8")
    print(f"Successfully updated droidloom to {version} (image {base}-{build})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
