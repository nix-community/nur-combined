#!/usr/bin/env python3
"""Update LYNX SHARE and the upstream-pinned JUCE/ONNX Runtime dependencies."""

from __future__ import annotations

import json
import re
import subprocess
import urllib.request
from pathlib import Path


ROOT = Path(subprocess.check_output(["git", "rev-parse", "--show-toplevel"], text=True).strip())
PACKAGE = ROOT / "by-name/ly/lynx-share/package.nix"


def run(*args: str) -> str:
    return subprocess.check_output(args, cwd=ROOT, text=True).strip()


def sri_hash(url: str, *, unpack: bool = True) -> str:
    args = ["nix-prefetch-url"]
    if unpack:
        args.append("--unpack")
    args.append(url)
    base32 = run(*args).splitlines()[-1]
    return run("nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", base32)


def replace_pin(source: str, name: str, value: str) -> str:
    pattern = rf'({re.escape(name)}\s*=\s*)"[^"]+";'
    updated, count = re.subn(pattern, rf'\g<1>"{value}";', source)
    if count != 1:
        raise RuntimeError(f"expected exactly one {name} pin in package.nix")
    return updated


def github_file(rev: str, path: str) -> str:
    url = f"https://raw.githubusercontent.com/Ka1-S/LYNX-SHARE/{rev}/{path}"
    request = urllib.request.Request(url, headers={"User-Agent": "nix-update-lynx-share"})
    with urllib.request.urlopen(request) as response:
        return response.read().decode()


def commit_date(rev: str) -> str:
    url = f"https://api.github.com/repos/Ka1-S/LYNX-SHARE/commits/{rev}"
    request = urllib.request.Request(
        url,
        headers={"Accept": "application/vnd.github+json", "User-Agent": "nix-update-lynx-share"},
    )
    with urllib.request.urlopen(request) as response:
        payload = json.load(response)
    return payload["commit"]["committer"]["date"][:10]


def main() -> None:
    run("nix-update", "--version=branch", "lynx-share")

    package = PACKAGE.read_text()
    rev_match = re.search(r'\brev = "([0-9a-f]{40})";', package)
    if not rev_match:
        raise RuntimeError("could not find the updated source revision in package.nix")
    rev = rev_match.group(1)

    cmake = github_file(rev, "CMakeLists.txt")
    project_match = re.search(r"project\(LYNX VERSION ([0-9.]+)", cmake)
    if not project_match:
        raise RuntimeError("could not find LYNX's project version in CMakeLists.txt")
    upstream_version = project_match.group(1)

    juce_match = re.search(
        r"FetchContent_Declare\(\s*JUCE\s+.*?GIT_TAG\s+([0-9.]+)",
        cmake,
        re.DOTALL,
    )
    if not juce_match:
        raise RuntimeError("could not find JUCE's GIT_TAG in CMakeLists.txt")
    juce_version = juce_match.group(1)

    ort_script = github_file(rev, "scripts/fetch-onnxruntime.sh")
    ort_version_match = re.search(r"^VERSION=([0-9.]+)$", ort_script, re.MULTILINE)
    ort_hash_match = re.search(r"^NUGET_SHA=([0-9a-f]{64})$", ort_script, re.MULTILINE)
    if not ort_version_match or not ort_hash_match:
        raise RuntimeError("could not find ONNX Runtime's version and NuGet hash")
    ort_version = ort_version_match.group(1)
    ort_hex_hash = ort_hash_match.group(1)
    ort_sri = run("nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", ort_hex_hash)

    package = replace_pin(
        package,
        "version",
        f"{upstream_version}-unstable-{commit_date(rev)}",
    )
    package = replace_pin(package, "juceVersion", juce_version)
    package = replace_pin(
        package,
        "juceHash",
        sri_hash(f"https://github.com/juce-framework/JUCE/archive/refs/tags/{juce_version}.tar.gz"),
    )
    package = replace_pin(package, "onnxRuntimeVersion", ort_version)
    package = replace_pin(package, "onnxRuntimeHash", ort_sri)
    PACKAGE.write_text(package)


if __name__ == "__main__":
    main()
