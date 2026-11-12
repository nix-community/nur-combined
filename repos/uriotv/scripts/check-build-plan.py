#!/usr/bin/env python3
"""Fail fast when a package build would compile a toolchain from source.

Reads `nix build --dry-run` stderr on stdin. nixpkgs-unstable only advances after
Hydra has built its toolchains, so a local compiler/SDK bootstrap means a package
selected a non-cached variant (e.g. a source-built .NET SDK -> dotnet-vmr). Such
a build takes hours and only ends in the CI job timeout; report it in seconds.

Exit 0: plan acceptable. Exit 3: heavy derivations listed on stdout.
"""
import re
import sys

HEAVY = re.compile(
    r"^[a-z0-9]{32}-(?:dotnet-vmr|rustc|ghc|llvm|clang|gcc|openjdk|nodejs|"
    r"webkitgtk|qtwebengine|chromium|electron-unwrapped)-[0-9][^/]*\.drv$"
)


def planned_builds(text):
    builds, in_section = [], False
    for line in text.splitlines():
        if re.match(r"^(?:this derivation|these \d+ derivations) will be built:", line.strip()):
            in_section = True
            continue
        if in_section and line.startswith("  /nix/store/"):
            builds.append(line.strip())
            continue
        in_section = False
    return builds


def main():
    heavy = [p for p in planned_builds(sys.stdin.read()) if HEAVY.match(p.removeprefix("/nix/store/"))]
    if heavy:
        print("\n".join(heavy))
        return 3
    return 0


if __name__ == "__main__":
    sys.exit(main())
