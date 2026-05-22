from __future__ import annotations

import json
import logging
import tempfile
import urllib.request
from pathlib import Path
from typing import Any

from .models import UpdateResult
from .process import ROOT, run_json
from .versions import should_block_downgrade, version_is_older

DEFAULT_URL_TEMPLATE = "https://github.com/{{owner}}/{{repo}}/releases/download/{{tag}}/{{asset}}"
logger = logging.getLogger(__name__)


def manifest_has_release_asset_updater(path: Path) -> bool:
    try:
        data = json.loads(path.read_text())
    except (OSError, json.JSONDecodeError):
        return False
    return data.get("updater", {}).get("type") == "github-release-assets"


def package_has_manifest_updater(file_path: Path) -> Path | None:
    for manifest in sorted(file_path.parent.glob("*.json")):
        if manifest_has_release_asset_updater(manifest):
            return manifest
    return None


def list_release_asset_manifests() -> list[Path]:
    return sorted(
        path
        for path in (ROOT / "pkgs").glob("**/*.json")
        if manifest_has_release_asset_updater(path)
    )


def latest_github_release_tag(owner: str, repo: str) -> str | None:
    url = f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
    logger.info("fetching latest GitHub release for %s/%s", owner, repo)
    try:
        with urllib.request.urlopen(url, timeout=30) as response:
            data = json.loads(response.read().decode())
    except OSError as error:
        logger.info("failed to fetch latest GitHub release for %s/%s: %s", owner, repo, error)
        return None
    return data.get("tag_name") or None


def latest_release_prefix_for_url(src_url: str | None) -> str | None:
    if not src_url or not src_url.startswith("https://github.com/"):
        return None
    parts = src_url.removesuffix(".git").split("/")
    if len(parts) < 5:
        return None
    tag = latest_github_release_tag(parts[3], parts[4])
    if not tag:
        return None
    return strip_tag_prefix(tag, "v")


def update_release_asset_manifest(manifest: Path, *, dry_run: bool = False) -> UpdateResult:
    name = str(manifest.relative_to(ROOT))
    logger.info("updating release asset manifest %s", name)
    data = _read_manifest(manifest)
    updater = data.get("updater", {})
    owner = updater.get("owner")
    repo = updater.get("repo")
    tag_prefix = updater.get("tagPrefix", "")
    current = data.get("version", "")
    assets = updater.get("assets") or {}

    if not owner or not repo or not assets:
        return UpdateResult(
            name,
            "skipped",
            "incomplete release asset manifest",
        )

    latest_tag = latest_github_release_tag(owner, repo)
    latest = strip_tag_prefix(latest_tag or "", tag_prefix)
    if not latest:
        return UpdateResult(
            name,
            "failed",
            f"failed to determine latest release for {owner}/{repo}",
        )
    if should_block_downgrade(current, latest) and version_is_older(latest, current):
        return UpdateResult(
            name,
            "skipped",
            f"apparent downgrade {current} -> {latest}",
        )
    if current == latest:
        return UpdateResult(
            name,
            "skipped",
            f"already up to date at {current}",
        )

    hashes = _prefetch_asset_hashes(data, latest_tag or latest)
    if dry_run:
        return UpdateResult(
            name,
            "updated",
            f"manifest {current} -> {latest} (dry-run)",
        )

    updated = dict(data)
    updated["version"] = latest
    updated["hashes"] = hashes
    _atomic_write_json(manifest, updated)
    return UpdateResult(
        name,
        "updated",
        f"release asset manifest {current} -> {latest}",
        [manifest],
    )


def strip_tag_prefix(tag: str, prefix: str) -> str:
    return tag.removeprefix(prefix) if prefix and tag.startswith(prefix) else tag


def render_asset_url(data: dict[str, Any], tag: str, asset: str) -> str:
    updater = data.get("updater", {})
    template = updater.get("urlTemplate") or DEFAULT_URL_TEMPLATE
    return (
        template.replace("{{owner}}", updater.get("owner", ""))
        .replace("{{repo}}", updater.get("repo", ""))
        .replace("{{tag}}", tag)
        .replace("{{asset}}", asset)
    )


def _prefetch_asset_hashes(data: dict[str, Any], tag: str) -> dict[str, str]:
    hashes: dict[str, str] = {}
    for system, asset in sorted(data.get("updater", {}).get("assets", {}).items()):
        url = render_asset_url(data, tag, asset)
        logger.info("prefetching %s asset %s", system, asset)
        result = run_json(["nix", "store", "prefetch-file", "--json", "--hash-type", "sha256", url])
        hashes[system] = result["hash"]
    return hashes


def _read_manifest(manifest: Path) -> dict[str, Any]:
    return json.loads(manifest.read_text())


def _atomic_write_json(path: Path, data: dict[str, Any]) -> None:
    text = json.dumps(data, indent=2) + "\n"
    with tempfile.NamedTemporaryFile("w", dir=path.parent, delete=False) as tmp:
        tmp.write(text)
        tmp_path = Path(tmp.name)
    tmp_path.replace(path)
