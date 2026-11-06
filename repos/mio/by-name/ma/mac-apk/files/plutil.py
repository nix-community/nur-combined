#!/usr/bin/env python3
"""Minimal `plutil` stand-in for the Nix build sandbox.

macOS's /usr/bin/plutil is unreachable from the build sandbox, but
scripts/build_launcher.sh runs `plutil -lint <file>` before shipping the system
broker's launch agent. Parsing with plistlib is stricter than Apple's linter,
which is fine here: the same script has its own strict XML check, and this only
needs to reject malformed plists early.
"""
import plistlib
import sys


def main() -> int:
    args = sys.argv[1:]
    if not args or args[0] != "-lint":
        print(f"plutil: unsupported arguments: {' '.join(args)}", file=sys.stderr)
        return 1
    if len(args) == 1:
        print("plutil: -lint needs at least one file", file=sys.stderr)
        return 1

    status = 0
    for path in args[1:]:
        try:
            with open(path, "rb") as handle:
                plistlib.load(handle)
        except Exception as error:
            print(f"{path}: {error}", file=sys.stderr)
            status = 1
        else:
            print(f"{path}: OK")
    return status


if __name__ == "__main__":
    sys.exit(main())
