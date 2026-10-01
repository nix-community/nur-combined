import argparse
import json
import os
import re
import shlex
import subprocess
import sys
import tempfile
from collections.abc import Iterator
from pathlib import Path
from typing import TypedDict, cast

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
                or not re.fullmatch(r"v?[0-9]+\.[0-9]+\.[0-9]+", tag)
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
) -> str:
    checks = [
        "Required release assets are uploaded and nonempty.",
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


def open_pr(
    root: Path,
    repository: str,
    base: str,
    package: str,
    current: str,
    release: Release,
    spec: maintain.Specification,
    systems: list[str],
) -> str:
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
    if existing:
        return "existing PR: " + existing[0]["url"]
    title = f"{package}: {current} -> {version}"
    with tempfile.TemporaryDirectory(prefix="nur-pr-") as temporary:
        worktree = Path(temporary) / "repo"
        _ = maintain.run(
            root, ["git", "worktree", "add", "--detach", str(worktree), "HEAD"]
        )
        try:
            _ = maintain.run(worktree, ["just", "update", package, version])
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
            files = [f"pkgs/{package}/{name}" for name in spec["files"]]
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
                    pr_body(package, release, spec, systems, host),
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


def ready_updates(
    root: Path,
) -> Iterator[tuple[str, maintain.Specification, str, list[str], Release]]:
    for path in sorted((root / "pkgs").glob("*/maintenance.toml")):
        package = path.parent.name
        spec = maintain.specification(root, package)
        if "release" not in spec:
            raise ValueError(f"{package}: missing release monitoring metadata")
        current, systems = maintain.package_info(root, package)
        newer = candidates(root, spec["release"]["repository"], current)
        if not newer:
            report(f"{package}: no newer stable release (packaged {current}).")
            continue
        release = newer[0]
        version = release["tag_name"].removeprefix("v")
        if not ready(release, spec["release"]):
            report(f"{package} {version}: waiting for required assets.")
            continue
        yield package, spec, current, systems, release


def check_updates(root: Path, pr: bool = False, update: bool = False) -> None:
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
                    root, repository, base, package, current, release, spec, systems
                )
            )
        elif update:
            _ = maintain.run(root, ["just", "update", package, version])
            report(f"{package}: {current} -> {version}, validated without committing.")
        else:
            report(f"{package} {version}: assets ready (read-only check).")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Check declared packages for ready upstream releases"
    )
    mode = parser.add_mutually_exclusive_group()
    _ = mode.add_argument("--pr", action="store_true")
    _ = mode.add_argument("--update", action="store_true")
    args = parser.parse_args(namespace=Arguments())
    try:
        check_updates(maintain.ROOT, args.pr, args.update)
    except (OSError, ValueError, KeyError, subprocess.SubprocessError) as error:
        report(f"Update failed: {error}")
        parser.exit(1)


if __name__ == "__main__":
    main()
