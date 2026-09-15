#!/usr/bin/env python3

import argparse
import base64
import json
import os
import re
import stat
import subprocess
import sys
import tempfile
from pathlib import Path
from urllib.parse import quote

REGISTRY_URL = "https://trev.zip"


class RefreshError(Exception):
    pass


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Refresh the narHash in a Forgejo tarball flake URL."
    )
    parser.add_argument("--file", required=True, type=Path)
    parser.add_argument("--dep-name", required=True)
    return parser.parse_args()


def validate_file(root: Path, path: Path) -> Path:
    if path.is_absolute() or ".." in path.parts:
        raise RefreshError("file must be a repository-relative path without '..'")

    unresolved = root
    for part in path.parts:
        unresolved /= part
        if unresolved.is_symlink():
            raise RefreshError(f"file path contains a symlink: {path}")

    try:
        resolved = (root / path).resolve(strict=True)
        resolved.relative_to(root)
    except (FileNotFoundError, ValueError) as error:
        raise RefreshError(f"file is not inside the repository: {path}") from error

    if not resolved.is_file():
        raise RefreshError(f"file is not a regular file: {path}")

    return resolved


def validate_dep_name(dep_name: str) -> None:
    if re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", dep_name) is None:
        raise RefreshError("dependency name must be an owner/repository path")

    if any(part in {".", ".."} for part in dep_name.split("/")):
        raise RefreshError("dependency name contains an unsafe path component")


def find_archive_url(path: Path, dep_name: str) -> str:
    content = path.read_bytes().decode("utf-8")
    pattern = re.compile(
        rf"(?P<archive>{re.escape(REGISTRY_URL)}/{re.escape(dep_name)}/archive/"
        rf"[a-f0-9]{{40}}\.tar\.gz)\?narHash=[^\"&\s]+(?=\")"
    )
    matches = list(pattern.finditer(content))

    if len(matches) != 1:
        raise RefreshError(
            f"expected exactly one matching Forgejo flake URL, found {len(matches)}"
        )

    return matches[0].group("archive")


def prefetch_hash(archive_url: str) -> str:
    try:
        result = subprocess.run(
            ["nix", "flake", "prefetch", "--json", archive_url],
            check=True,
            capture_output=True,
            text=True,
        )
    except subprocess.CalledProcessError as error:
        detail = error.stderr.strip() or str(error)
        raise RefreshError(f"nix flake prefetch failed: {detail}") from error

    try:
        metadata = json.loads(result.stdout)
    except json.JSONDecodeError as error:
        raise RefreshError("nix flake prefetch returned invalid JSON") from error

    if not isinstance(metadata, dict):
        raise RefreshError("nix flake prefetch returned invalid JSON")

    nar_hash = metadata.get("hash")
    if not isinstance(nar_hash, str) or not nar_hash.startswith("sha256-"):
        raise RefreshError("nix flake prefetch returned an invalid SHA-256 SRI hash")

    try:
        digest = base64.b64decode(nar_hash.removeprefix("sha256-"), validate=True)
    except ValueError as error:
        raise RefreshError(
            "nix flake prefetch returned an invalid SHA-256 SRI hash"
        ) from error

    if len(digest) != 32:
        raise RefreshError("nix flake prefetch returned an invalid SHA-256 SRI hash")

    return nar_hash


def replace_hash(path: Path, archive_url: str, nar_hash: str) -> bool:
    content = path.read_bytes().decode("utf-8")
    pattern = re.compile(
        rf"(?P<prefix>{re.escape(archive_url)}\?narHash=)(?P<hash>[^\"&\s]+)(?=\")"
    )
    matches = list(pattern.finditer(content))

    if len(matches) != 1:
        raise RefreshError(
            f"expected exactly one matching Forgejo flake URL, found {len(matches)}"
        )

    encoded_hash = quote(nar_hash, safe="-._~")
    current_hash = matches[0].group("hash")
    if current_hash == encoded_hash:
        return False

    updated = pattern.sub(rf"\g<prefix>{encoded_hash}", content, count=1).encode(
        "utf-8"
    )
    mode = stat.S_IMODE(path.stat().st_mode)
    descriptor, temporary_name = tempfile.mkstemp(
        dir=path.parent, prefix=f".{path.name}.", suffix=".tmp"
    )
    temporary = Path(temporary_name)

    try:
        with os.fdopen(descriptor, "wb") as temporary_file:
            temporary_file.write(updated)
        os.chmod(temporary, mode)
        os.replace(temporary, path)
    except BaseException:
        temporary.unlink(missing_ok=True)
        raise

    return True


def refresh(file: Path, dep_name: str, root: Path | None = None) -> bool:
    root = (root or Path.cwd()).resolve()
    path = validate_file(root, file)
    validate_dep_name(dep_name)
    archive_url = find_archive_url(path, dep_name)
    nar_hash = prefetch_hash(archive_url)
    return replace_hash(path, archive_url, nar_hash)


def main() -> int:
    args = parse_args()

    try:
        changed = refresh(args.file, args.dep_name)
    except (OSError, UnicodeError, RefreshError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    print("updated narHash" if changed else "narHash is already current")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
