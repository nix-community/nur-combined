"""Shared helpers for the nur-packages auto-updaters.

Each pkgs/<name>/update.py imports this module by walking up from its own
path, and is expected to be run from the repository root (that is what
passthru.updateScript does) so the working tree it edits is the real
checkout rather than a read-only Nix store copy.
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import tempfile
from pathlib import Path
from typing import Any
from urllib.request import Request, urlopen

# A hash that can never match, used to make a fixed-output derivation fail
# and report the real hash in the resulting error message.
DUMMY_SHA256_HASH = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="


def run(cmd: list[str], **kwargs: Any) -> subprocess.CompletedProcess[str]:
    """Run a command with text I/O; never raises unless check=True."""
    kwargs.setdefault("text", True)
    return subprocess.run(cmd, **kwargs)


def read_json(path: Path) -> dict[str, Any]:
    """Load a JSON object from path."""
    return json.loads(path.read_text())


def write_json(path: Path, data: dict[str, Any]) -> None:
    """Atomically write pretty-printed JSON with a trailing newline."""
    fd, tmp = tempfile.mkstemp(dir=path.parent, prefix=f".{path.name}.", suffix=".tmp")
    try:
        with os.fdopen(fd, "w") as handle:
            json.dump(data, handle, indent=2)
            handle.write("\n")
        os.replace(tmp, path)
    except BaseException:
        Path(tmp).unlink(missing_ok=True)
        raise


def version_key(version: str) -> tuple[tuple[int, ...], bool, str]:
    """Build a sort key for semver-ish versions, ignoring a leading v.

    A release without a prerelease suffix sorts above one with a suffix
    (1.2.3 > 1.2.3-rc.1).
    """
    core, _, suffix = version.removeprefix("v").partition("-")
    numbers = tuple(int(part) for part in core.split(".") if part.isdigit())
    return (numbers, suffix == "", suffix)


def is_newer(latest: str, current: str) -> bool:
    """Whether latest is strictly newer than current."""
    return version_key(latest) > version_key(current)


def github_get(url: str) -> Any:
    """GET a GitHub API URL, authenticating with GITHUB_TOKEN if set."""
    headers = {
        "Accept": "application/vnd.github+json",
        "User-Agent": "nur-packages-updater",
    }
    token = os.environ.get("GITHUB_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    with urlopen(Request(url, headers=headers), timeout=60) as response:
        return json.load(response)


def latest_github_release(owner: str, repo: str, *, tag_prefix: str = "v") -> str:
    """Return the highest version among releases whose tag matches the prefix.

    Listing releases (instead of using /releases/latest) matters for
    repositories that publish several components under separate release lines.
    """
    releases = github_get(
        f"https://api.github.com/repos/{owner}/{repo}/releases?per_page=100"
    )
    versions = [
        release["tag_name"][len(tag_prefix) :]
        for release in releases
        if release.get("tag_name", "").startswith(tag_prefix)
    ]
    if not versions:
        raise SystemExit(f"no releases with tag prefix {tag_prefix!r} in {owner}/{repo}")
    return max(versions, key=version_key)


def npm_latest_version(package: str, *, tag: str = "latest") -> str:
    """Return the version behind an npm dist-tag."""
    result = run(
        ["npm", "view", f"{package}@{tag}", "version"],
        capture_output=True,
        check=True,
    )
    return result.stdout.strip()


def nix_prefetch_file(url: str) -> str:
    """Return the SRI sha256 hash of a URL, as fetchurl computes it."""
    result = run(
        ["nix", "store", "prefetch-file", "--hash-type", "sha256", "--json", url],
        capture_output=True,
        check=True,
    )
    return json.loads(result.stdout)["hash"]


def nix_build(attr: str) -> subprocess.CompletedProcess[str]:
    """Build a flake attribute without linking the result."""
    return run(["nix", "build", "--no-link", attr], capture_output=True)


def extract_hash_from_build_error(output: str) -> str | None:
    """Pull the expected hash out of a fixed-output derivation mismatch."""
    match = re.search(r"got:\s+(sha256-[A-Za-z0-9+/=]+)", output)
    return match.group(1) if match else None
