#!/usr/bin/env python3
"""Append GTA 2 Recompiled's first-start payload to the launcher.

The launcher reads a zip at the offset stored in the 48-byte trailer.  The
payload contains the build tools and the libraries that are linked with the
code lifted from the player's own GTA2.exe.
"""

import argparse
import os
import shutil
import struct
import sys
import zipfile


TRAILER_MAGIC = b"XRPAYLD1"
TRAILER_SIZE = 48


def write_zip(payload_dir, zip_path):
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
        for root, dirs, files in os.walk(payload_dir):
            dirs.sort()
            for name in sorted(files):
                path = os.path.join(root, name)
                if not os.path.isfile(path):
                    continue
                rel = os.path.relpath(path, payload_dir)
                archive.write(path, rel)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--launcher", required=True)
    parser.add_argument("--payload", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--release", required=True)
    args = parser.parse_args()

    release = args.release.encode()
    if len(release) > 32:
        raise SystemExit("release version must fit in 32 bytes")

    zip_path = args.output + ".zip"
    launcher = args.launcher
    copied_launcher = False
    if os.path.abspath(args.launcher) == os.path.abspath(args.output):
        launcher = args.output + ".plain"
        shutil.copyfile(args.launcher, launcher)
        copied_launcher = True
    try:
        write_zip(args.payload, zip_path)
        shutil.copyfile(launcher, args.output)
        offset = os.path.getsize(args.output)
        with open(args.output, "ab") as output, open(zip_path, "rb") as archive:
            shutil.copyfileobj(archive, output, 1 << 20)
            output.write(
                TRAILER_MAGIC
                + struct.pack("<Q", offset)
                + release.ljust(32, b"\0")
            )
        os.chmod(args.output, 0o755)
    finally:
        try:
            os.remove(zip_path)
        except FileNotFoundError:
            pass
        if copied_launcher:
            os.remove(launcher)


if __name__ == "__main__":
    sys.exit(main())
