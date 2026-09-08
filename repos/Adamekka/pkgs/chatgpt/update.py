#!/usr/bin/env python3

import base64
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tempfile


def main():
    base_url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/"
    source_path = Path(__file__).with_name("source.json")
    current = json.loads(source_path.read_text())
    updated = {}
    versions = set()
    # The download host rejects Python's HTTPS client; use curl for repository requests.
    curl = ["curl", "--fail", "--location", "--silent", "--show-error", "--retry", "3", "--max-time", "600"]

    for system, architecture in [("aarch64-linux", "arm64"), ("x86_64-linux", "amd64")]:
        url = f"{base_url}dists/stable/main/binary-{architecture}/Packages"
        index = subprocess.check_output([*curl, url], text=True)
        packages = []
        for paragraph in index.strip().split("\n\n"):
            fields = dict(
                line.split(": ", 1)
                for line in paragraph.splitlines()
                if line and not line[0].isspace() and ": " in line
            )
            if fields.get("Package") == "chatgpt" and fields.get("Architecture") == architecture:
                packages.append(fields)
        # Refuse ambiguous indexes rather than silently choosing an arbitrary release.
        if len(packages) != 1:
            raise RuntimeError(f"Expected one ChatGPT package for {architecture}, got {len(packages)}")
        package = packages[0]
        version = package["Version"]
        if not re.fullmatch(r"[0-9]+(?:\.[0-9]+)+", version):
            raise RuntimeError(f"Unexpected version: {version!r}")
        filename = f"pool/main/c/chatgpt/chatgpt_{version}_{architecture}.deb"
        if package["Filename"] != filename:
            raise RuntimeError(f"Unexpected package filename: {package['Filename']!r}")
        if not re.fullmatch(r"[0-9a-f]{64}", package["SHA256"]):
            raise RuntimeError(f"Invalid SHA256 for {architecture}")
        versions.add(version)
        updated[system] = {
            "hash": "sha256-" + base64.b64encode(bytes.fromhex(package["SHA256"])).decode(),
            "url": base_url + filename,
        }
        if current.get(system) != updated[system]:
            digest = hashlib.sha256()
            size = 0
            with tempfile.TemporaryFile() as download:
                subprocess.run([*curl, updated[system]["url"]], stdout=download, check=True)
                download.seek(0)
                while chunk := download.read(1024 * 1024):
                    digest.update(chunk)
                    size += len(chunk)
            if digest.hexdigest() != package["SHA256"] or size != int(package["Size"]):
                raise RuntimeError(f"Download does not match repository metadata for {architecture}")

    # Architectures can publish at different times. Keep the current pin until they agree.
    if len(versions) != 1:
        raise RuntimeError(f"Architecture versions differ: {sorted(versions)}")
    updated["version"] = versions.pop()
    if tuple(map(int, updated["version"].split("."))) < tuple(map(int, current["version"].split("."))):
        raise RuntimeError("Refusing to downgrade ChatGPT")
    if updated == current:
        print(f"ChatGPT {current['version']} is up to date")
        return
    source_path.write_text(json.dumps(updated, indent=2, sort_keys=True) + "\n")
    print(f"Updated ChatGPT to {updated['version']}")


if __name__ == "__main__":
    main()
