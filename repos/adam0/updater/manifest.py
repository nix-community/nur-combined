from __future__ import annotations

import json
import logging
import re
import tempfile
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from typing import Any

from .models import UpdateResult
from .process import ROOT, run_json
from .versions import should_block_downgrade, version_is_older

DEFAULT_URL_TEMPLATE = "https://github.com/{{owner}}/{{repo}}/releases/download/{{tag}}/{{asset}}"
SUPPORTED_UPDATERS = {"github-release-assets", "tangled-tag-artifacts"}
logger = logging.getLogger(__name__)


def manifest_has_release_asset_updater(path: Path) -> bool:
    try:
        data = json.loads(path.read_text())
    except (OSError, json.JSONDecodeError):
        return False
    return data.get("updater", {}).get("type") in SUPPORTED_UPDATERS


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
    data = _read_manifest(manifest)
    if data.get("updater", {}).get("type") == "tangled-tag-artifacts":
        return _update_tangled_tag_artifacts(manifest, data, dry_run=dry_run)
    return _update_github_release_assets(manifest, data, dry_run=dry_run)


def _update_github_release_assets(
    manifest: Path, data: dict[str, Any], *, dry_run: bool
) -> UpdateResult:
    name = str(manifest.relative_to(ROOT))
    logger.info("updating GitHub release asset manifest %s", name)
    updater = data.get("updater", {})
    owner = updater.get("owner")
    repo = updater.get("repo")
    tag_prefix = updater.get("tagPrefix", "")
    current = data.get("version", "")
    assets = updater.get("assets") or {}

    if not owner or not repo or not assets:
        return UpdateResult(name, "skipped", "incomplete release asset manifest")

    latest_tag = latest_github_release_tag(owner, repo)
    latest = strip_tag_prefix(latest_tag or "", tag_prefix)
    if not latest:
        return UpdateResult(
            name, "failed", f"failed to determine latest release for {owner}/{repo}"
        )
    blocked = _blocked_or_current(name, current, latest)
    if blocked:
        return blocked

    hashes = _prefetch_github_asset_hashes(data, latest_tag or latest)
    if dry_run:
        return UpdateResult(name, "updated", f"manifest {current} -> {latest} (dry-run)")

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


def _update_tangled_tag_artifacts(
    manifest: Path, data: dict[str, Any], *, dry_run: bool
) -> UpdateResult:
    name = str(manifest.relative_to(ROOT))
    logger.info("updating Tangled tag artifact manifest %s", name)
    updater = data.get("updater", {})
    did = updater.get("did")
    repo = updater.get("repo")
    expected_assets = [f"{name}.zip" for name in data.get("hashes", {})]
    current = data.get("version", "")

    if not did or not repo or not expected_assets:
        return UpdateResult(name, "skipped", "incomplete Tangled artifact manifest")

    release = _latest_tangled_release(did, repo)
    if not release:
        return UpdateResult(
            name, "failed", f"failed to determine latest Tangled release for {did}/{repo}"
        )
    latest, tag_hash, published_assets = release
    blocked = _blocked_or_current(name, current, latest)
    if blocked:
        return blocked

    missing = sorted(set(expected_assets) - set(published_assets))
    if missing:
        return UpdateResult(
            name,
            "failed",
            f"latest Tangled release is missing artifacts: {', '.join(missing)}",
        )

    base_url = f"https://tangled.org/{did}/{repo}"
    source_hash, hashes = _prefetch_tangled_release_hashes(
        base_url, latest, tag_hash, expected_assets
    )
    if dry_run:
        return UpdateResult(name, "updated", f"manifest {current} -> {latest} (dry-run)")

    updated = dict(data)
    updated["version"] = latest
    updated["tagHash"] = tag_hash
    updated["sourceHash"] = source_hash
    updated["hashes"] = hashes
    _atomic_write_json(manifest, updated)
    return UpdateResult(
        name,
        "updated",
        f"Tangled artifact manifest {current} -> {latest}",
        [manifest],
    )


def _latest_tangled_release(did: str, repo: str) -> tuple[str, str, list[str]] | None:
    url = f"https://tangled.org/{did}/{repo}/tags"
    logger.info("fetching latest Tangled release for %s/%s", did, repo)
    try:
        with urllib.request.urlopen(url, timeout=30) as response:
            html = response.read().decode()
    except OSError as error:
        logger.info("failed to fetch Tangled tags for %s/%s: %s", did, repo, error)
        return None

    # Tangled canonicalizes DID URLs to the current handle in page links.
    base_path = rf'/[^"/]+/{re.escape(repo)}'
    tags = list(re.finditer(rf'href="{base_path}/tags/([^"/]+)"', html))
    if not tags:
        return None

    tag = tags[0]
    next_tag = next((match for match in tags[1:] if match.group(1) != tag.group(1)), None)
    release_html = html[tag.end() : next_tag.start() if next_tag else None]
    artifact_pattern = rf'href="{base_path}/tags/([0-9a-f]{{40}})/download/([^"/]+)"'
    artifacts = re.findall(artifact_pattern, release_html)
    if not artifacts:
        return None
    tag_hash = artifacts[0][0]
    names = [asset for artifact_hash, asset in artifacts if artifact_hash == tag_hash]
    return tag.group(1), tag_hash, names


def _blocked_or_current(name: str, current: str, latest: str) -> UpdateResult | None:
    if should_block_downgrade(current, latest) and version_is_older(latest, current):
        return UpdateResult(name, "skipped", f"apparent downgrade {current} -> {latest}")
    if current == latest:
        return UpdateResult(name, "skipped", f"already up to date at {current}")
    return None


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


def _prefetch_github_asset_hashes(data: dict[str, Any], tag: str) -> dict[str, str]:
    hashes: dict[str, str] = {}
    for system, asset in sorted(data.get("updater", {}).get("assets", {}).items()):
        url = render_asset_url(data, tag, asset)
        logger.info("prefetching %s asset %s", system, asset)
        hashes[system] = _prefetch_url_hash(url)
    return hashes


def _prefetch_tangled_release_hashes(
    base_url: str, tag: str, tag_hash: str, assets: list[str]
) -> tuple[str, dict[str, str]]:
    def prefetch(asset: str) -> tuple[str, str]:
        logger.info("prefetching Tangled artifact %s", asset)
        url = f"{base_url}/tags/{tag_hash}/download/{asset}"
        return Path(asset).stem, _prefetch_url_hash(url)

    with ThreadPoolExecutor(max_workers=8) as executor:
        source = executor.submit(_prefetch_url_hash, f"{base_url}/archive/{tag}", unpack=True)
        hashes = dict(sorted(executor.map(prefetch, assets)))
        return source.result(), hashes


def _prefetch_url_hash(url: str, *, unpack: bool = False) -> str:
    command = ["nix", "store", "prefetch-file", "--json", "--hash-type", "sha256"]
    if unpack:
        command.append("--unpack")
    command.append(url)
    return run_json(command)["hash"]


def _read_manifest(manifest: Path) -> dict[str, Any]:
    return json.loads(manifest.read_text())


def _atomic_write_json(path: Path, data: dict[str, Any]) -> None:
    text = json.dumps(data, indent=2) + "\n"
    with tempfile.NamedTemporaryFile("w", dir=path.parent, delete=False) as tmp:
        tmp.write(text)
        tmp_path = Path(tmp.name)
    tmp_path.replace(path)
