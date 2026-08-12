from __future__ import annotations

from .models import PackageState, ValidationResult
from .versions import branch_parts, should_block_downgrade, version_is_older


def validate_transition(
    before: PackageState,
    after: PackageState,
    *,
    package_files_changed: bool,
    unrelated_files_changed: bool,
    release_prefix: str | None = None,
) -> ValidationResult:
    if unrelated_files_changed:
        return ValidationResult(False, "backend changed files outside package ownership")
    if not package_files_changed:
        return ValidationResult(False, "no package-owned files changed")

    source_changed = before.src_rev != after.src_rev or before.src_url != after.src_url
    dependency_only = (
        before.dependency_hash != after.dependency_hash
        and before.version == after.version
        and before.src_rev == after.src_rev
        and before.src_url == after.src_url
        and before.src_hash == after.src_hash
    )
    if dependency_only:
        return ValidationResult(
            False, "rejected dependency-hash-only diff after no-op source update"
        )

    if should_block_downgrade(before.version, after.version) and version_is_older(
        after.version, before.version
    ):
        return ValidationResult(
            False, f"rejected apparent downgrade {before.version} -> {after.version}"
        )

    before_branch = branch_parts(before.version)
    after_branch = branch_parts(after.version)
    if before.version_mode == "branch" or after.version_mode == "branch":
        if not before_branch or not after_branch:
            return ValidationResult(False, "unrecognized branch version format")
        before_prefix, _ = before_branch
        after_prefix, _ = after_branch
        prefix_changed = before_prefix != after_prefix

        if prefix_changed and not source_changed:
            return ValidationResult(False, "rejected version-only branch prefix change")
        if prefix_changed and after_prefix != release_prefix:
            return ValidationResult(False, "rejected unproven branch release prefix change")
        if before.version != after.version and not source_changed:
            return ValidationResult(False, "rejected branch version change without source change")

    return ValidationResult(
        True,
        "accepted source/package transition" if source_changed else "accepted package transition",
        dependency_hash_refresh_allowed=source_changed,
    )
