import argparse
import json
import os
import re
import shlex
import subprocess
import sys
import tempfile
from collections.abc import Iterator
from datetime import date
from pathlib import Path
from typing import TypedDict, cast
from uuid import uuid4

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tools import maintain


class Asset(TypedDict):
    name: str
    state: str
    size: int


class Release(TypedDict):
    tag_name: str
    draft: bool
    prerelease: bool
    html_url: str
    assets: list[Asset]


class Arguments(argparse.Namespace):
    pr: bool = False
    update: bool = False
    force: bool = False


def github(root: Path, arguments: list[str]) -> str:
    return subprocess.run(
        ["gh", *arguments],
        cwd=root,
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        timeout=300,
    ).stdout.strip()


def version_key(version: str) -> tuple[int, ...]:
    if not re.fullmatch(
        r"(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)", version
    ):
        raise ValueError(
            "Release monitoring requires a stable major.minor.patch version"
        )
    return tuple(int(part) for part in version.split("."))


def candidates(root: Path, repository: str, current: str) -> list[Release]:
    current_version = version_key(current)
    pages = cast(
        list[list[Release]],
        json.loads(
            github(
                root,
                [
                    "api",
                    f"repos/{repository}/releases?per_page=100",
                    "--paginate",
                    "--slurp",
                ],
            )
        ),
    )
    releases: list[Release] = []
    for page in pages:
        for release in page:
            tag = release["tag_name"]
            if (
                release["draft"]
                or release["prerelease"]
                or not re.fullmatch(
                    r"v?(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)", tag
                )
            ):
                continue
            if version_key(tag.removeprefix("v")) > current_version:
                releases.append(release)
    return sorted(
        releases,
        key=lambda release: version_key(release["tag_name"].removeprefix("v")),
        reverse=True,
    )


def ready(release: Release, spec: maintain.ReleaseSpecification) -> bool:
    version = release["tag_name"].removeprefix("v")
    required = {name.replace("{version}", version) for name in spec["assets"]}
    uploaded = {
        asset["name"]
        for asset in release["assets"]
        if asset["state"] == "uploaded" and asset["size"] > 0
    }
    return required <= uploaded


def pr_body(
    package: str,
    release: Release,
    spec: maintain.Specification,
    systems: list[str],
    host: str,
    current: str = "",
    snapshot_dates: tuple[str, str] | None = None,
) -> str:
    if "snapshot" in spec:
        return (
            f"Update `{package}` source from `{current}` to `{release['tag_name']}`.\n\n"
            + (
                f"Snapshot dates: {snapshot_dates[0]} -> {snapshot_dates[1]}.\n\n"
                if snapshot_dates
                else ""
            )
            + f"Upstream: {release['html_url']}\n\n"
            + f"Validated with `just check {package}` on `{host}`: package build, "
            + "regression tests, lint, and `git diff --check`. "
            + "Playback, ad blocking, and VM tests were not run.\n"
        )
    assert "release" in spec
    checks = [
        (
            "Required release assets are uploaded and nonempty."
            if spec["release"]["assets"]
            else "Source-only release; no uploaded assets required."
        ),
        "Source hashes refreshed for: " + ", ".join(systems) + ".",
        f"Package built on `{host}`.",
    ]
    if "sync" in spec:
        checks.append(
            "Generated upstream contract: `" + shlex.join(spec["sync"]) + "`."
        )
    if "contract" in spec:
        checks.append(
            "Pinned contract verified: `" + shlex.join(spec["contract"]) + "`."
        )
    checks.extend("`" + shlex.join(command) + "`" for command in spec.get("tests", []))
    checks.extend(
        [
            "Lint: nixfmt, statix, deadnix, ruff, basedpyright (zero errors and warnings).",
            "`git diff --check`.",
        ]
    )
    untested = ", ".join(system for system in systems if system != host) or "none"
    return (
        f"Update `{package}` to the ready upstream release: {release['html_url']}\n\n"
        + "## Checks performed\n\n"
        + "\n".join(f"- [x] {check}" for check in checks)
        + f"\n\nOther platforms not build-tested: {untested}. VM tests were not run.\n"
        + "Asset presence is not checksum-manifest verification. Review upstream behavior before merging; "
        + "automated contract checks do not cover every compatibility change.\n"
    )


def update_package(
    root: Path, package: str, version: str, spec: maintain.Specification
) -> None:
    snapshot = spec.get("snapshot")
    if not snapshot:
        _ = maintain.run(root, ["just", "update", package, version])
        return
    _ = maintain.run(root, snapshot["command"])
    if snapshot_revision(root, snapshot) != version:
        raise ValueError("Upstream moved during update; retry the check")
    _ = maintain.run(root, ["just", "check", package])


def snapshot_date(root: Path, repository: str, revision: str) -> str:
    timestamp = github(
        root,
        [
            "api",
            f"repos/{repository}/commits/{revision}",
            "--template",
            "{{.commit.committer.date}}",
        ],
    )
    return date.fromisoformat(timestamp.split("T")[0]).isoformat()


def open_pr(
    root: Path,
    repository: str,
    base: str,
    package: str,
    current: str,
    release: Release,
    spec: maintain.Specification,
    systems: list[str],
    force: bool = False,
) -> str:
    snapshot = spec.get("snapshot")
    version = release["tag_name"].removeprefix("v")
    branch = f"updates/{package}-{current}-to-{version}"
    existing = cast(
        list[dict[str, str]],
        json.loads(
            github(
                root,
                [
                    "pr",
                    "list",
                    "--repo",
                    repository,
                    "--head",
                    branch,
                    "--base",
                    base,
                    "--state",
                    "all",
                    "--json",
                    "url",
                ],
            )
        ),
    )
    if existing and not force:
        return "existing PR: " + existing[0]["url"]
    if force:
        branch += f"-force-{uuid4().hex}"
    title = f"{package}: {current} -> {version}"
    snapshot_dates = None
    if snapshot:
        snapshot_dates = (
            snapshot_date(root, snapshot["repository"], current),
            snapshot_date(root, snapshot["repository"], version),
        )
        name = snapshot.get("name", snapshot["attribute"].split(".")[-1])
        title = f"{package}: {name} {snapshot_dates[1]} ({version[:7]})"
    with tempfile.TemporaryDirectory(prefix="nur-pr-") as temporary:
        worktree = Path(temporary) / "repo"
        _ = maintain.run(
            root, ["git", "worktree", "add", "--detach", str(worktree), "HEAD"]
        )
        try:
            update_package(worktree, package, version, spec)
            _ = maintain.run(worktree, ["git", "diff", "--check"])
            host = cast(
                str,
                json.loads(
                    maintain.run(
                        worktree,
                        [
                            "nix",
                            "eval",
                            "--impure",
                            "--json",
                            "--expr",
                            "builtins.currentSystem",
                        ],
                        capture=True,
                    )
                ),
            )
            files = [f"pkgs/{package}/{name}" for name in (snapshot or spec)["files"]]
            if snapshot:
                changed = maintain.run(
                    worktree, ["git", "diff", "--name-only"], capture=True
                ).splitlines()
                if not changed or set(changed) - set(files):
                    raise ValueError(
                        "Snapshot update changed undeclared files or made no changes"
                    )
            _ = maintain.run(worktree, ["git", "add", "--", *files])
            _ = maintain.run(worktree, ["git", "commit", "-m", title])
            _ = maintain.run(
                worktree, ["git", "push", "-u", "origin", f"HEAD:refs/heads/{branch}"]
            )
            return github(
                worktree,
                [
                    "pr",
                    "create",
                    "--repo",
                    repository,
                    "--base",
                    base,
                    "--head",
                    branch,
                    "--title",
                    title,
                    "--body",
                    pr_body(
                        package, release, spec, systems, host, current, snapshot_dates
                    ),
                ],
            )
        finally:
            _ = maintain.run(
                root, ["git", "worktree", "remove", "--force", str(worktree)]
            )


def report(message: str) -> None:
    print(message, flush=True)
    summary = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary:
        with Path(summary).open("a") as output:
            _ = output.write(f"- {message}\n")


def snapshot_revision(root: Path, spec: maintain.SnapshotSpecification) -> str:
    revision = maintain.run(
        root,
        ["nix", "eval", "-f", ".", spec["attribute"] + ".src.rev", "--raw"],
        capture=True,
    )
    if not re.fullmatch(r"[0-9a-f]{40}", revision):
        raise ValueError("Invalid pinned snapshot commit")
    return revision


def ready_package(
    root: Path,
    package: str,
    spec: maintain.Specification,
) -> tuple[str, list[str], Release] | None:
    current, systems = maintain.package_info(root, package)
    if "snapshot" in spec:
        snapshot = spec["snapshot"]
        current = snapshot_revision(root, snapshot)
        target = github(
            root,
            [
                "api",
                f"repos/{snapshot['repository']}/commits/{snapshot['branch']}",
                "--template",
                "{{.sha}}",
            ],
        )
        if not re.fullmatch(r"[0-9a-f]{40}", target):
            raise ValueError("Invalid upstream snapshot commit")
        if current == target:
            report(f"{package}: source is already current.")
            return None
        release: Release = {
            "tag_name": target,
            "draft": False,
            "prerelease": False,
            "html_url": f"https://github.com/{snapshot['repository']}/commit/{target}",
            "assets": [],
        }
    else:
        assert "release" in spec
        newer = candidates(root, spec["release"]["repository"], current)
        if not newer:
            report(f"{package}: no newer stable release (packaged {current}).")
            return None
        release = newer[0]
        if not ready(release, spec["release"]):
            report(f"{package} {release['tag_name']}: waiting for required assets.")
            return None
    return current, systems, release


def ready_updates(
    root: Path,
) -> Iterator[tuple[str, maintain.Specification, str, list[str], Release]]:
    for path in sorted((root / "pkgs").glob("*/maintenance.toml")):
        package = path.parent.name
        spec = maintain.specification(root, package)
        if "release" not in spec and "snapshot" not in spec:
            continue
        candidate = ready_package(root, package, spec)
        if candidate:
            current, systems, release = candidate
            yield package, spec, current, systems, release


def check_updates(
    root: Path,
    pr: bool = False,
    update: bool = False,
    force: bool = False,
) -> None:
    if force and not pr:
        raise ValueError("--force requires --pr")
    if pr and maintain.run(root, ["git", "status", "--porcelain"], capture=True):
        raise ValueError("PR publishing requires a clean checkout")
    repository, base = (
        (os.environ["GITHUB_REPOSITORY"], os.environ["UPDATE_BASE"]) if pr else ("", "")
    )
    for package, spec, current, systems, release in ready_updates(root):
        version = release["tag_name"].removeprefix("v")
        if pr:
            report(
                open_pr(
                    root,
                    repository,
                    base,
                    package,
                    current,
                    release,
                    spec,
                    systems,
                    force=force,
                )
            )
        elif update:
            update_package(root, package, version, spec)
            report(f"{package}: {current} -> {version}, validated without committing.")
        else:
            report(f"{package} {version}: update ready (read-only check).")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Check declared packages for ready upstream releases"
    )
    mode = parser.add_mutually_exclusive_group()
    _ = mode.add_argument("--pr", action="store_true")
    _ = mode.add_argument("--update", action="store_true")
    _ = parser.add_argument(
        "--force",
        action="store_true",
        help="Ignore existing PRs and publish from a new branch; still run all validation (requires --pr)",
    )
    args = parser.parse_args(namespace=Arguments())
    try:
        check_updates(maintain.ROOT, args.pr, args.update, args.force)
    except (OSError, ValueError, KeyError, subprocess.SubprocessError) as error:
        report(f"Update failed: {error}")
        parser.exit(1)


if __name__ == "__main__":
    main()
