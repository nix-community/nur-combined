from __future__ import annotations

import logging
import re
import subprocess
from pathlib import Path

from .manifest import latest_release_prefix_for_url, package_has_manifest_updater
from .models import PackageRef, PackageState, ResultStatus, UpdateResult
from .nix import read_state
from .process import CommandError, run
from .transactions import FileTransaction, paths_owned_by
from .validation import validate_transition
from .versions import branch_parts

logger = logging.getLogger(__name__)


def update_package(
    ref: PackageRef, *, dry_run: bool = False, timeout: str | None = None
) -> UpdateResult:
    logger.info("updating %s from %s", ref.attr_path, ref.file_path)
    if package_update_disabled(ref.file_path):
        logger.info("skipping %s: package disables updater", ref.attr_path)
        return UpdateResult(ref.attr_path, "skipped", "package disables updater")

    manifest = package_has_manifest_updater(ref.file_path)
    if manifest:
        logger.info("skipping %s: manifest updater owns %s", ref.attr_path, manifest)
        return UpdateResult(ref.attr_path, "skipped", f"manifest updater owns {manifest}")

    owned_roots = package_owned_roots(ref.file_path)
    before = read_state(ref.source_kind, ref.attrset, ref.attr)

    with FileTransaction(owned_roots) as transaction:
        try:
            _run_nix_update(ref, before.version_mode, timeout=timeout)
        except CommandError as error:
            transaction.restore()
            logger.info("nix-update failed for %s:\n%s", ref.attr_path, error.details)
            return UpdateResult(ref.attr_path, "skipped", f"nix-update failed: {error}")

        after = read_state(ref.source_kind, ref.attrset, ref.attr)
        changed = transaction.new_changed_files()
        owned_changed, unrelated = paths_owned_by(changed, owned_roots)
        release_prefix = latest_release_prefix_for_url(after.src_url)
        if _preserve_unproven_branch_prefix(ref.file_path, before, after, release_prefix):
            after = read_state(ref.source_kind, ref.attrset, ref.attr)
            changed = transaction.new_changed_files()
            owned_changed, unrelated = paths_owned_by(changed, owned_roots)
        validation = validate_transition(
            before,
            after,
            package_files_changed=bool(owned_changed),
            unrelated_files_changed=bool(unrelated),
            release_prefix=release_prefix,
        )
        if not validation.accepted:
            transaction.restore()
            return UpdateResult(
                ref.attr_path, _rejected_status(validation.reason), validation.reason
            )

        if validation.dependency_hash_refresh_allowed:
            try:
                _refresh_dependency_hashes(ref, timeout=timeout)
            except CommandError as error:
                transaction.restore()
                logger.info(
                    "dependencyHash refresh failed for %s:\n%s", ref.attr_path, error.details
                )
                return UpdateResult(
                    ref.attr_path, "failed", f"dependencyHash refresh failed: {error}"
                )

        changed_after_refresh = transaction.new_changed_files()
        owned_changed, unrelated = paths_owned_by(changed_after_refresh, owned_roots)
        if unrelated:
            transaction.restore()
            return UpdateResult(
                ref.attr_path,
                "invalid",
                "hash refresh changed files outside package ownership",
            )

        if dry_run:
            transaction.restore()
            return UpdateResult(
                ref.attr_path,
                "updated",
                f"{validation.reason} (dry-run)",
                sorted(owned_changed),
            )
        return UpdateResult(ref.attr_path, "updated", validation.reason, sorted(owned_changed))


def package_owned_roots(file_path: Path) -> list[Path]:
    roots = [file_path]
    if file_path.name == "default.nix":
        roots.append(file_path.parent)
    roots.extend(sorted(file_path.parent.glob("*.json")))
    return roots


def package_update_disabled(file_path: Path) -> bool:
    return bool(re.search(r"\bupdateScript\s*=\s*null\s*;", file_path.read_text()))


def _preserve_unproven_branch_prefix(
    file_path: Path,
    before: PackageState,
    after: PackageState,
    release_prefix: str | None,
) -> bool:
    before_parts = branch_parts(before.version)
    after_parts = branch_parts(after.version)
    if not before_parts or not after_parts:
        return False

    before_prefix, _ = before_parts
    after_prefix, after_date = after_parts
    source_changed = before.src_rev != after.src_rev or before.src_url != after.src_url
    if not source_changed or before_prefix == after_prefix or after_prefix == release_prefix:
        return False

    version = f"{before_prefix}-unstable-{after_date}"
    text = file_path.read_text()
    updated = re.sub(r'version = "[^"]+";', f'version = "{version}";', text, count=1)
    if updated == text:
        return False
    file_path.write_text(updated)
    return True


def _rejected_status(reason: str) -> ResultStatus:
    skipped_prefixes = (
        "no package-owned files changed",
        "rejected apparent downgrade",
        "rejected branch version change without source change",
        "rejected dependency-hash-only diff",
        "rejected version-only branch prefix change",
    )
    return "skipped" if reason.startswith(skipped_prefixes) else "invalid"


def _run_nix_update(ref: PackageRef, version_mode: str, *, timeout: str | None) -> None:
    if ref.source_kind == "flake":
        command = [
            "nix",
            "run",
            "nixpkgs#nix-update",
            "--",
            "--flake",
            "--use-github-releases",
            f"--version={version_mode}",
            ref.attr_path,
        ]
    else:
        command = [
            "nix",
            "run",
            "nixpkgs#nix-update",
            "--",
            "-f",
            "default.nix",
            f"--version={version_mode}",
            ref.attr_path,
        ]
    run(command, timeout=timeout)


def _refresh_dependency_hashes(ref: PackageRef, *, timeout: str | None) -> None:
    replacements = [
        (
            r'dependencyHash = "sha256-[^"]+";',
            "dependencyHash = lib.fakeHash;",
            r"dependencyHash = lib\.fakeHash;",
            'dependencyHash = "{hash}";',
        ),
        (
            r'(fetchYarnDeps\s*\{[^}]*?hash\s*=\s*)"sha256-[^"]+";',
            r"\1lib.fakeHash;",
            r"(fetchYarnDeps\s*\{[^}]*?hash\s*=\s*)lib\.fakeHash;",
            '{prefix}"{hash}";',
        ),
    ]

    for pattern, replacement, fake_pattern, final_template in replacements:
        text, count = re.subn(pattern, replacement, ref.file_path.read_text(), count=1, flags=re.S)
        if not count:
            continue
        ref.file_path.write_text(text)
        refreshed = ref.file_path.read_text()
        got_hash = _last_got_hash(ref, timeout=timeout)
        updated, count = re.subn(
            fake_pattern,
            lambda found: final_template.format(
                prefix=found.group(1) if found.groups() else "", hash=got_hash
            ),
            refreshed,
            count=1,
            flags=re.S,
        )
        if count:
            ref.file_path.write_text(updated)


def _last_got_hash(ref: PackageRef, *, timeout: str | None) -> str:
    result = _build_with_fake_hash(ref, timeout=timeout)
    match = re.search(r"^\s*got:\s*(sha256-[A-Za-z0-9+/=]+)$", result.stderr + result.stdout, re.M)
    if not match:
        raise CommandError(["refresh-dependency-hash", ref.attr_path], result)
    return match.group(1)


def _build_with_fake_hash(
    ref: PackageRef, *, timeout: str | None
) -> subprocess.CompletedProcess[str]:
    if ref.source_kind == "flake":
        result = run(
            ["nix", "build", f".#{ref.attr_path}", "--no-link"],
            timeout=timeout,
            check=False,
        )
    else:
        result = run(
            ["nix-build", "-A", ref.attr_path, "--no-out-link"],
            timeout=timeout,
            check=False,
        )
    return result
