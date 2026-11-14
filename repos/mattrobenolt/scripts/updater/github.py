"""GitHub release helpers for package update scripts."""

from typing import Any, cast

from .hash import hex_to_sri
from .http import fetch_json


def fetch_release(owner: str, repo: str, tag: str | None = None) -> dict[str, Any]:
    """Fetch a release, or the latest release when tag is omitted."""
    suffix = "latest" if tag is None else f"tags/{tag}"
    return cast(
        dict[str, Any],
        fetch_json(f"https://api.github.com/repos/{owner}/{repo}/releases/{suffix}"),
    )


def release_asset_hashes(
    release: dict[str, Any], assets: dict[str, str]
) -> dict[str, str]:
    """Return the SRI hash of each release asset digest, keyed by target."""
    by_name = {cast(str, asset["name"]): asset for asset in release["assets"]}
    hashes: dict[str, str] = {}
    for target, name in assets.items():
        asset = by_name.get(name)
        if asset is None:
            raise ValueError(f"Missing release asset: {name}")
        digest = cast(str, asset.get("digest") or "")
        if not digest.startswith("sha256:"):
            raise ValueError(f"Missing sha256 digest for release asset: {name}")
        hashes[target] = hex_to_sri(digest.removeprefix("sha256:"))
    return hashes
