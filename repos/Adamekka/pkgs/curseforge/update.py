#!/usr/bin/env python3

import base64
import hashlib
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path


def main():
    source_path = Path(__file__).with_name("source.json")
    current = json.loads(source_path.read_text())
    if not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+-[0-9]+", current["version"]):
        raise RuntimeError(f"Unexpected pinned version: {current['version']!r}")

    with tempfile.TemporaryDirectory(prefix="curseforge-update-") as temporary:
        archive = Path(temporary) / "curseforge.deb"
        # Follow the public download, since the in-app feed can advertise a staged release.
        with archive.open("wb") as output:
            subprocess.run(
                [
                    "curl", "--fail", "--location", "--silent", "--show-error",
                    "--proto", "=https", "--proto-redir", "=https",
                    "--retry", "3", "--retry-max-time", "600",
                    "--connect-timeout", "30", "--max-time", "600",
                    "https://curseforge.overwolf.com/downloads/curseforge-latest-linux.deb",
                ],
                stdout=output, check=True,
            )
        metadata = subprocess.check_output(
            ["dpkg-deb", "--field", str(archive), "Package", "Version", "Architecture"],
            text=True,
        )
        fields = dict(line.split(": ", 1) for line in metadata.splitlines())
        if fields.get("Package") != "curseforge" or fields.get("Architecture") != "amd64":
            raise RuntimeError(f"Unexpected Debian package identity: {fields!r}")
        version_match = re.fullmatch(r"([0-9]+\.[0-9]+\.[0-9]+)~([0-9]+)-\2", fields.get("Version", ""))
        if version_match is None:
            raise RuntimeError(f"Unexpected Debian version: {fields.get('Version')!r}")
        version = f"{version_match[1]}-{version_match[2]}"
        if tuple(map(int, re.split(r"[.-]", version))) < tuple(map(int, re.split(r"[.-]", current["version"]))):
            raise RuntimeError(f"Refusing to downgrade CurseForge from {current['version']} to {version}")

        digest = hashlib.sha256()
        with archive.open("rb") as download:
            while chunk := download.read(1024 * 1024):
                digest.update(chunk)
        updated = {
            "hash": "sha256-" + base64.b64encode(digest.digest()).decode(),
            # The candidate Nix build verifies this versioned URL serves the public download's bytes.
            "url": f"https://curseforge.overwolf.com/electron/linux/CurseForge_{version}_amd64.deb",
            "version": version,
        }

    if version == current["version"] and updated["hash"] != current["hash"]:
        raise RuntimeError(f"Archive changed without a version bump for CurseForge {version}; review manually")
    if updated == current:
        print(f"CurseForge {version} is up to date")
        return
    source_path.write_text(json.dumps(updated, indent=2, sort_keys=True) + "\n")
    print(f"Updated CurseForge to {version}")


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, ValueError, subprocess.CalledProcessError) as error:
        print(f"CurseForge update failed: {error}", file=sys.stderr)
        sys.exit(1)
