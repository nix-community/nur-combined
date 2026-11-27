#!/usr/bin/env python3
"""Update futo-notes and its Cargo-lock-coupled wasm-bindgen CLI pin."""

from __future__ import annotations

import os
import re
import subprocess
import sys
import urllib.request
from pathlib import Path


ATTR = "futo-notes"
PACKAGE = Path("by-name/fu/futo-notes/package.nix")
RAW_LOCK = "https://gitlab.futo.org/futo-notes/futo-notes/-/raw/v{version}/Cargo.lock"
WASM_ATTR_RE = re.compile(r"wasm-bindgen-cli_0_2_[0-9]+")


def run(*args: str) -> str:
    return subprocess.check_output(args, text=True).strip()


def main() -> None:
    root = Path(run("git", "rev-parse", "--show-toplevel"))
    package = root / PACKAGE
    original = package.read_text()

    try:
        subprocess.run(
            ["nix-update", os.environ.get("UPDATE_NIX_ATTR_PATH", ATTR), *sys.argv[1:]],
            cwd=root,
            check=True,
        )

        text = package.read_text()
        match = re.search(r'(?m)^    version = "([^"]+)";', text)
        if match is None:
            raise SystemExit("error: could not find the futo-notes version")
        version = match.group(1)

        with urllib.request.urlopen(RAW_LOCK.format(version=version), timeout=60) as response:
            lockfile = response.read().decode()
        wasm_match = re.search(
            r'name = "wasm-bindgen"\nversion = "([^"]+)"',
            lockfile,
        )
        if wasm_match is None:
            raise SystemExit("error: Cargo.lock has no wasm-bindgen package")
        wasm_version = wasm_match.group(1)
        wasm_attr = f"wasm-bindgen-cli_{wasm_version.replace('.', '_')}"

        text, count = WASM_ATTR_RE.subn(wasm_attr, text)
        if count != 3:
            raise SystemExit(
                f"error: expected three wasm-bindgen-cli references, found {count}"
            )
        package.write_text(text)

        system = run("nix", "eval", "--impure", "--raw", "--expr", "builtins.currentSystem")
        run("nix", "eval", "--raw", f".#legacyPackages.{system}.{ATTR}.drvPath")
        print(f"futo-notes {version}: wasm-bindgen {wasm_version} ({wasm_attr})")
    except BaseException:
        if package.read_text() != original:
            package.write_text(original)
        raise


if __name__ == "__main__":
    main()
