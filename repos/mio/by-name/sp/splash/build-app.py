#!/usr/bin/env python3
"""Assemble Splash.app from SwiftPM's products and this package's runtime.

Upstream's `make app` uses dev/tools/package_app.py, which downloads a
standalone Python distribution, pip-installs install/requirements.txt, and
takes CFBundleVersion from the checkout's git history. Nix cannot use those
steps: the source tree has no .git, and this package already builds the
runtime's Python environment. This driver reuses package_app's bundle layout,
icon compilation, signing and verification, replacing only the runtime it
copies and the build number it derives.
"""

import argparse
import re
import shutil
import stat
import sys
import tempfile
from pathlib import Path


def version_build_number(version: str) -> str:
    match = re.fullmatch(r"(\d+)\.(\d+)\.(\d+)(?:[-+].*)?", version)
    if match is None:
        raise SystemExit(f"cannot derive a build number from {version!r}")
    major, minor, patch = (int(part) for part in match.groups())
    return str(major * 1_000_000 + minor * 1_000 + patch)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--products", type=Path, required=True)
    parser.add_argument("--runtime", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--macos-min", default="26.4")
    args = parser.parse_args()

    sys.path.insert(0, str(args.source))
    from dev.tools import package_app

    number = version_build_number(args.version)

    def build_number(_commit: str = "HEAD") -> str:
        return number

    # package_app reads the checkout's commit count, which Nix's source has no
    # git history for. The caller passes a version-derived number instead.
    package_app.build_number = build_number

    def copy_runtime(destination: Path, _version: str) -> None:
        # assemble() has already created destination; merge the staged runtime
        # into it rather than replacing the directory.
        shutil.copytree(args.runtime, destination, symlinks=True, dirs_exist_ok=True)
        # The staged runtime comes from the read-only Nix store; codesign
        # rewrites the signatures of its Mach-O files.
        for path in destination.rglob("*"):
            if not path.is_symlink():
                path.chmod(path.stat().st_mode | stat.S_IWUSR)

    package_app.package.build_runtime = copy_runtime

    if args.output.is_dir():
        shutil.rmtree(args.output)
    elif args.output.exists():
        args.output.unlink()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=args.output.parent) as temporary:
        bundle = Path(temporary) / args.output.name
        package_app.assemble(bundle, args.products, args.version, args.macos_min)
        signed = package_app.sign(bundle, "-")
        package_app.check_signed(bundle)
        bundle.replace(args.output)
    print(f"Built {args.output}; signed it and the {signed} Mach-O files of its runtime.")


if __name__ == "__main__":
    main()
