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
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import urlsplit


class RefreshError(Exception):
    pass


@dataclass(frozen=True)
class ForgejoFlake:
    content: str
    archive_url: str
    hash_start: int
    hash_end: int
    current_hash: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Refresh the hash in a getForgejoFlake call."
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


def validate_hash(nar_hash: str) -> None:
    if not nar_hash.startswith("sha256-"):
        raise RefreshError("invalid SHA-256 SRI hash")

    try:
        digest = base64.b64decode(nar_hash.removeprefix("sha256-"), validate=True)
    except ValueError as error:
        raise RefreshError("invalid SHA-256 SRI hash") from error

    if len(digest) != 32:
        raise RefreshError("invalid SHA-256 SRI hash")


def validate_url(url: str, dep_name: str) -> None:
    try:
        parsed = urlsplit(url)
        port = parsed.port
    except ValueError as error:
        raise RefreshError("invalid Forgejo repository URL") from error

    if (
        parsed.scheme not in {"http", "https"}
        or parsed.hostname is None
        or parsed.username is not None
        or parsed.password is not None
        or parsed.path != f"/{dep_name}"
        or parsed.query
        or parsed.fragment
        or url.endswith("/")
        or any(character.isspace() for character in url)
        or (port is not None and not 1 <= port <= 65535)
    ):
        raise RefreshError("invalid Forgejo repository URL")


def find_flake(path: Path, dep_name: str) -> ForgejoFlake:
    content = path.read_bytes().decode("utf-8")
    pattern = re.compile(
        r"getForgejoFlake\s*\{\s*"
        r'url\s*=\s*"(?P<url>[^\"]+)"\s*;\s*'
        r'rev\s*=\s*"(?P<rev>[^\"]+)"\s*;'
        r"[ \t]*(?:#[^\r\n]*)?\s*"
        r'hash\s*=\s*"(?P<hash>[^\"]+)"\s*;\s*'
        r"\}"
    )
    matches = [
        match
        for match in pattern.finditer(content)
        if urlsplit(match.group("url")).path == f"/{dep_name}"
    ]

    if len(matches) != 1:
        raise RefreshError(
            f"expected exactly one matching getForgejoFlake call, found {len(matches)}"
        )

    match = matches[0]
    url = match.group("url")
    rev = match.group("rev")
    current_hash = match.group("hash")

    validate_url(url, dep_name)
    if re.fullmatch(r"[a-f0-9]{40}", rev) is None:
        raise RefreshError("revision must be 40 lowercase hexadecimal characters")
    validate_hash(current_hash)

    return ForgejoFlake(
        content=content,
        archive_url=f"{url}/archive/{rev}.tar.gz",
        hash_start=match.start("hash"),
        hash_end=match.end("hash"),
        current_hash=current_hash,
    )


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

    if not isinstance(metadata, dict) or not isinstance(metadata.get("hash"), str):
        raise RefreshError("nix flake prefetch returned invalid JSON")

    nar_hash = metadata["hash"]
    validate_hash(nar_hash)
    return nar_hash


def replace_hash(path: Path, flake: ForgejoFlake, nar_hash: str) -> bool:
    if flake.current_hash == nar_hash:
        return False

    updated = (
        flake.content[: flake.hash_start] + nar_hash + flake.content[flake.hash_end :]
    ).encode("utf-8")
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
    flake = find_flake(path, dep_name)
    nar_hash = prefetch_hash(flake.archive_url)
    return replace_hash(path, flake, nar_hash)


def main() -> int:
    args = parse_args()

    try:
        changed = refresh(args.file, args.dep_name)
    except (OSError, UnicodeError, RefreshError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    print("updated hash" if changed else "hash is already current")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
