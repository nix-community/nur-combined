#!/usr/bin/env python3
"""Update UTM, its Swift package cache, and the CI sysroot it links against.

UTM's native dependencies (QEMU, SPICE, GStreamer, ...) are only published as
the `Sysroot-macos-universal` artifact of the tag's build run. Artifacts expire
after 90 days, so the run id and the artifact hash must move together with the
source revision on every update.
"""

from __future__ import annotations

import base64
import json
import os
import re
import subprocess
import sys
import urllib.parse
import urllib.request
from pathlib import Path

ATTR = "utm"
PKG_REL = Path("by-name/ut/utm/package.nix")
OWNER = "utmapp"
REPO = "UTM"
WORKFLOW_NAME = "Build"
ARTIFACT = "Sysroot-macos-universal"
VERSION_RE = re.compile(r'(?m)^\s*version = "([^"]+)";')
SYSROOT_RUN_RE = re.compile(r'(?m)^(\s*sysrootRun = )"([0-9]+)";')


def run(cmd: list[str], cwd: Path, *, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, cwd=cwd, text=True, capture_output=True, check=check)


def repo_root() -> Path:
    result = run(["git", "rev-parse", "--show-toplevel"], Path.cwd(), check=False)
    if result.returncode != 0:
        raise SystemExit(f"error: not in a git checkout:\n{result.stderr}")
    return Path(result.stdout.strip())


def http_json(url: str) -> dict:
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    headers = {
        "Accept": "application/vnd.github+json",
        "User-Agent": "nixpkgs-utm-updater",
    }
    if token:
        headers["Authorization"] = f"Bearer {token}"
    request = urllib.request.Request(
        url,
        headers=headers,
    )
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            return json.loads(response.read().decode("utf-8"))
    except Exception as error:
        raise SystemExit(f"error: could not fetch {url}: {error}") from error


def set_sysroot_run(text: str, value: str) -> str:
    updated, count = SYSROOT_RUN_RE.subn(lambda match: f'{match.group(1)}"{value}";', text, count=1)
    if count != 1:
        raise SystemExit("error: could not update sysrootRun in package.nix")
    return updated


def set_sysroot_hash(text: str, value: str) -> str:
    start = re.search(r'(?m)^([ \t]*)sysroot = fetchurl \{', text)
    if start is None:
        raise SystemExit("error: could not find the sysroot fetchurl block")
    indent = start.group(1)
    end_marker = f"\n{indent}}};"
    end = text.find(end_marker, start.end())
    if end < 0:
        raise SystemExit("error: unterminated sysroot fetchurl block")
    end += len(end_marker)

    block = text[start.start() : end]
    updated, count = re.subn(
        r'(?m)^(\s*hash = )"[^"]+";',
        lambda match: f'{match.group(1)}"{value}";',
        block,
        count=1,
    )
    if count != 1:
        raise SystemExit("error: could not update the sysroot hash")
    return text[: start.start()] + updated + text[end:]


def digest_to_sri(digest: str) -> str:
    try:
        algorithm, value = digest.split(":", 1)
        if algorithm != "sha256":
            raise ValueError(f"unsupported digest algorithm {algorithm}")
        raw_digest = bytes.fromhex(value)
        if len(raw_digest) != 32:
            raise ValueError("SHA-256 digest is not 32 bytes")
    except ValueError as error:
        raise SystemExit(f"error: invalid GitHub artifact digest: {error}") from error
    return f"sha256-{base64.b64encode(raw_digest).decode('ascii')}"


def sysroot_pin(tag: str) -> tuple[str, str]:
    branch = urllib.parse.quote(tag, safe="")
    runs = http_json(
        f"https://api.github.com/repos/{OWNER}/{REPO}/actions/runs?branch={branch}&per_page=20"
    )["workflow_runs"]
    candidates = [
        run
        for run in runs
        if run.get("name") == WORKFLOW_NAME and run.get("conclusion") == "success"
    ]
    if not candidates:
        raise SystemExit(f"error: no successful {WORKFLOW_NAME} run for {tag}")
    run_id = candidates[0]["id"]

    artifacts = http_json(
        f"https://api.github.com/repos/{OWNER}/{REPO}/actions/runs/{run_id}/artifacts?per_page=100"
    )["artifacts"]
    for artifact in artifacts:
        if artifact["name"] != ARTIFACT:
            continue
        if artifact["expired"]:
            raise SystemExit(f"error: {ARTIFACT} of run {run_id} has expired")
        digest = artifact.get("digest")
        if not isinstance(digest, str):
            raise SystemExit(f"error: {ARTIFACT} of run {run_id} has no digest")
        return str(run_id), digest_to_sri(digest)
    raise SystemExit(f"error: run {run_id} has no {ARTIFACT} artifact")


def main() -> int:
    root = repo_root()
    package = root / PKG_REL
    original = package.read_text(encoding="utf-8")

    try:
        for command in (
            ["nix-update", os.environ.get("UPDATE_NIX_ATTR_PATH", ATTR), *sys.argv[1:]],
            [
                "nix-update",
                "--no-src",
                "--subpackage",
                "spmDeps",
                *sys.argv[1:],
                os.environ.get("UPDATE_NIX_ATTR_PATH", ATTR),
            ],
        ):
            status = subprocess.run(command, cwd=root, check=False).returncode
            if status != 0:
                raise SystemExit(status)

        text = package.read_text(encoding="utf-8")
        match = VERSION_RE.search(text)
        if match is None:
            raise SystemExit("error: could not find the UTM version")
        version = match.group(1)

        run_id, sysroot_hash = sysroot_pin(f"v{version}")
        text = set_sysroot_run(text, run_id)
        text = set_sysroot_hash(text, sysroot_hash)

        if text != original:
            package.write_text(text, encoding="utf-8")
        print(f"utm {version}: sysroot from run {run_id}")
    except BaseException:
        package.write_text(original, encoding="utf-8")
        raise

    return 0


if __name__ == "__main__":
    sys.exit(main())
