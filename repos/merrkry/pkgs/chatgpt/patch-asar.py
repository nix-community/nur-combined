"""Apply byte-length-preserving source patches inside app.asar.

The asar header records file offsets, so every replacement is padded with
spaces to the original's exact byte length instead of re-packing the archive.
Minified identifiers change between releases, so patterns are regexes that
capture the identifiers they need instead of hard-coding them.
"""

import argparse
import re
import sys
from collections.abc import Callable
from pathlib import Path

# ASAR patching and writable plugin copies adapted from:
# https://github.com/numtide/llm-agents.nix/blob/main/packages/chatgpt/patch-asar.py
# The glibc watcher workaround follows https://github.com/NixOS/nixpkgs/pull/551713.
# autoPatchelf moves PT_INTERP beyond detect-libc's 2 KiB scan range.
# Its process.report fallback trips Electron's CFI guard, so select glibc directly.
GLIBC_WATCHER = (
    re.compile(rb"const family = familySync\(\);"),
    lambda _m: b"const family = 'glibc';",
)

# The app copies bundled plugins to ~/.codex with fs.cp, which preserves the
# store's read-only modes, and then fails to rewrite manifests there. `exec` is
# the promisified execFile helper from the darwin `ditto` branch; hoisting
# `platform` into a local buys the bytes to stay inside the byte budget.
COPY_PLUGINS_WRITABLE = re.compile(
    rb"(?P<fn>async function [\w$]+\(e,t\)\{)"
    rb"if\((?P<plat>[\w$]+\.default\.platform)===`darwin`\)"
    rb"(?P<ditto>\{await (?P<exec>[\w$]+)\(`/usr/bin/ditto`,\[`--noqtn`,e,t\]\);return\})"
    rb"if\((?P=plat)!==`win32`\)\{"
    rb"await [\w$]+\.default\.cp\(e,t,\{recursive:!0,verbatimSymlinks:!0\}\);return\}"
)


def _copy_writable(m: re.Match[bytes]) -> bytes:
    return (
        m["fn"]
        + b"let r="
        + m["plat"]
        + b";if(r===`darwin`)"
        + m["ditto"]
        + b"if(r!==`win32`){await "
        + m["exec"]
        + b"(`cp`,[`-r`,e+`/.`,t]);await "
        + m["exec"]
        + b"(`chmod`,[`-R`,`u+w`,t]);return}"
    )


PATCHES: list[tuple[re.Pattern[bytes], Callable[[re.Match[bytes]], bytes]]] = [
    GLIBC_WATCHER,
    (COPY_PLUGINS_WRITABLE, _copy_writable),
]


def main() -> None:
    """Patch the asar archive in place."""
    parser = argparse.ArgumentParser()
    parser.add_argument("asar", type=Path)
    args = parser.parse_args()
    asar: Path = args.asar

    data = asar.read_bytes()
    for pattern, build in PATCHES:
        matches = list(pattern.finditer(data))
        if len(matches) != 1:
            sys.exit(
                f"expected 1 match for {pattern.pattern[:60]!r} in {asar}, got {len(matches)}"
            )
        m = matches[0]
        original = m.group(0)
        replacement = build(m)
        if len(replacement) > len(original):
            sys.exit(f"replacement longer than original: {replacement[:60]!r}...")
        data = (
            data[: m.start()] + replacement.ljust(len(original), b" ") + data[m.end() :]
        )
    asar.write_bytes(data)


if __name__ == "__main__":
    main()
