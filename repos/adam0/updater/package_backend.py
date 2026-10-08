from __future__ import annotations

import logging
import re
import subprocess
import tempfile
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

    update_mode = before.version_mode
    with FileTransaction(owned_roots) as transaction:
        try:
            if (
                before.version_mode == "branch"
                and before.src_rev
                and before.src_url
                and before.src_url.startswith("https://tangled.org/")
            ):
                if _update_tangled_revision(ref.file_path, before, timeout=timeout):
                    update_mode = "skip"
                    _run_nix_update(ref, update_mode, timeout=timeout)
            else:
                _run_nix_update(ref, update_mode, timeout=timeout)
        except CommandError as error:
            transaction.restore()
            logger.info("nix-update failed for %s:\n%s", ref.attr_path, error.details)
            return UpdateResult(ref.attr_path, "skipped", f"nix-update failed: {error}")

        verification = _update_source_with_verification(ref, before, update_mode, timeout=timeout)
        if verification:
            transaction.restore()
            logger.info("source hash verification failed for %s", ref.attr_path)
            return UpdateResult(ref.attr_path, "failed", verification)

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


def _update_source_with_verification(
    ref: PackageRef, before: PackageState, update_mode: str, *, timeout: str | None
) -> str | None:
    """Return a failure reason when a source written by nix-update cannot be reproduced.

    Feeds the freshly written source back through nix once more, so a hash that nix
    cannot reproduce for the recorded reference is never handed to a commit. A stale
    hash (for example an upstream tag that moved after the previous update) is retried
    by recomputing the source, and only reported when the retry cannot fix it.
    """
    after = read_state(ref.source_kind, ref.attrset, ref.attr)
    source_changed = (
        after.src_hash != before.src_hash
        or after.src_rev != before.src_rev
        or after.src_url != before.src_url
    )
    if not source_changed:
        return None

    reason = _verify_source_hash(ref, timeout=timeout)
    if reason is None or "hash mismatch" not in reason:
        return reason

    logger.info("source hash of %s does not match its source, re-running nix-update", ref.attr_path)
    try:
        _run_nix_update(ref, update_mode, timeout=timeout)
    except CommandError as error:
        return f"source hash verification failed and re-update failed: {error}"

    reason = _verify_source_hash(ref, timeout=timeout)
    return None if reason is None else f"source hash verification failed: {reason}"


def _verify_source_hash(ref: PackageRef, *, timeout: str | None) -> str | None:
    """Fetch the recorded source of a package and report a hash that does not match it."""
    if not read_state(ref.source_kind, ref.attrset, ref.attr).src_hash:
        return None

    if ref.source_kind == "flake":
        command = ["nix", "build", "--no-link", f".#{ref.attr_path}.src"]
    else:
        command = ["nix-build", "-f", "default.nix", "-A", f"{ref.attr_path}.src", "--no-out-link"]
    result = run(command, check=False, timeout=timeout)
    return None if result.returncode == 0 else _source_failure_line(result)


def _source_failure_line(result: subprocess.CompletedProcess[str]) -> str:
    details = result.stderr.strip() or result.stdout.strip()
    lines = [line.strip() for line in details.splitlines() if line.strip()]
    mismatch = next((line for line in lines if "hash mismatch" in line), None)
    if mismatch:
        return mismatch
    failed = next((line for line in lines if "error:" in line), None)
    return failed or (lines[-1] if lines else "source fetch failed")


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


def _update_tangled_revision(file_path: Path, before: PackageState, *, timeout: str | None) -> bool:
    repository_url = (before.src_url or "").split("/archive/", 1)[0]
    with tempfile.TemporaryDirectory(prefix="nur-tangled-") as directory:
        checkout = Path(directory) / "source"
        run(["git", "clone", "--depth=1", repository_url, str(checkout)], timeout=timeout)
        revision, date = (
            run(["git", "show", "-s", "--format=%H%n%cs", "HEAD"], cwd=checkout, timeout=timeout)
            .stdout.strip()
            .splitlines()
        )
    if revision == before.src_rev:
        return False
    parts = branch_parts(before.version)
    prefix = parts[0] if parts else before.version
    text = file_path.read_text()
    text, revision_count = re.subn(
        r'rev = "' + re.escape(before.src_rev or "") + r'";',
        f'rev = "{revision}";',
        text,
        count=1,
    )
    text, version_count = re.subn(
        r'version = "' + re.escape(before.version) + r'";',
        f'version = "{prefix}-unstable-{date}";',
        text,
        count=1,
    )
    if not revision_count or not version_count:
        raise ValueError(f"cannot locate Tangled revision/version in {file_path}")
    file_path.write_text(text)
    return True


def _run_nix_update(ref: PackageRef, version_mode: str, *, timeout: str | None) -> None:
    update_mode = "unstable" if version_mode == "stable" else version_mode
    if ref.source_kind == "flake":
        command = [
            "nix",
            "run",
            "nixpkgs#nix-update",
            "--",
            "--flake",
            "--use-github-releases",
            f"--version={update_mode}",
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
            f"--version={update_mode}",
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
        text, count = re.subn(
            pattern,
            replacement,
            ref.file_path.read_text(),
            count=1,
            flags=re.DOTALL,
        )
        if not count:
            continue
        ref.file_path.write_text(text)
        refreshed = ref.file_path.read_text()
        got_hash = _last_got_hash(ref, timeout=timeout)
        updated, count = re.subn(
            fake_pattern,
            lambda found, final_template=final_template, got_hash=got_hash: final_template.format(
                prefix=found.group(1) if found.groups() else "", hash=got_hash
            ),
            refreshed,
            count=1,
            flags=re.DOTALL,
        )
        if count:
            ref.file_path.write_text(updated)


def _last_got_hash(ref: PackageRef, *, timeout: str | None) -> str:
    result = _build_with_fake_hash(ref, timeout=timeout)
    match = re.search(
        r"^\s*got:\s*(sha256-[A-Za-z0-9+/=]+)$",
        result.stderr + result.stdout,
        re.MULTILINE,
    )
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
