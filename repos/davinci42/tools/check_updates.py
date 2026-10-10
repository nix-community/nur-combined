import argparse
import os
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import cast
from uuid import uuid4

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tools import maintain


def detect(root: Path, package: str) -> tuple[str, str] | None:
    with tempfile.TemporaryDirectory(prefix="nur-detect-") as temporary:
        candidate = Path(temporary) / "repo"
        maintain.copy_repository(root, candidate)
        info = maintain.update_info(candidate, package)
        current = cast(str, info["identity"])
        maintain.execute_update(candidate, package, detect=True, info=info)
        target = cast(str, maintain.update_info(candidate, package)["identity"])
        if target == current:
            return None
        if info["snapshot"]:
            return current, target
        comparison = maintain.run(
            root,
            [
                "nix-instantiate",
                "--eval",
                "--strict",
                "--expr",
                "{ target, current }: builtins.compareVersions target current",
                "--argstr",
                "target",
                target,
                "--argstr",
                "current",
                current,
            ],
            capture=True,
        )
        if comparison == "-1":
            return None
        return current, target


def github(root: Path, arguments: list[str]) -> str:
    return subprocess.run(
        ["gh", *arguments],
        cwd=root,
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        timeout=300,
    ).stdout.strip()


def open_pr(root: Path, package: str, current: str, target: str, force: bool) -> str:
    repository = os.environ["GITHUB_REPOSITORY"]
    base = os.environ["UPDATE_BASE"]
    branch = f"updates/{package}-{current}-to-{target}"
    existing = github(
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
            "--jq",
            ".[0].url // empty",
        ],
    )
    if existing and not force:
        return "existing PR: " + existing
    if force:
        branch += "-force-" + uuid4().hex
    title = f"{package}: {current} -> {target}"
    if len(title) >= 72:
        title = f"{package}: {current[:12]} -> {target[:12]}"
    with tempfile.TemporaryDirectory(prefix="nur-pr-") as temporary:
        worktree = Path(temporary) / "repo"
        _ = maintain.run(
            root, ["git", "worktree", "add", "--detach", str(worktree), "HEAD"]
        )
        try:
            snapshot = maintain.update_info(worktree, package)["snapshot"]
            if not maintain.update(worktree, package, None if snapshot else target):
                return f"{package}: no changes"
            if maintain.version(worktree, package) != target:
                raise ValueError("Upstream moved during update; retry the check")
            _ = maintain.run(worktree, ["git", "diff", "--check"])
            _ = maintain.run(worktree, ["git", "add", "--", f"pkgs/{package}"])
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
                    f"Update {package} from {current} to {target}.\n\n"
                    + f"Validated with `just check {package}`: package build, passthru tests and lint. "
                    + "Only the current platform was build-tested; VM tests were not run.",
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


def check_updates(
    root: Path, pr: bool = False, update: bool = False, force: bool = False
) -> None:
    if force and not pr:
        raise ValueError("--force requires --pr")
    if pr and maintain.run(root, ["git", "status", "--porcelain"], capture=True):
        raise ValueError("PR publishing requires a clean checkout")
    failures: list[str] = []
    for package in maintain.packages(root):
        try:
            candidate = detect(root, package)
            if not candidate:
                report(f"{package}: no newer version")
                continue
            current, target = candidate
            if pr:
                report(open_pr(root, package, current, target, force))
            elif update:
                snapshot = maintain.update_info(root, package)["snapshot"]
                _ = maintain.update(root, package, None if snapshot else target)
            else:
                report(f"{package}: {current} -> {target} (read-only check)")
        except (OSError, ValueError, KeyError, subprocess.SubprocessError) as error:
            failures.append(package)
            report(f"{package}: failed: {error}")
    if failures:
        raise ValueError("Updates failed for: " + ", ".join(failures))


class Arguments(argparse.Namespace):
    pr: bool = False
    update: bool = False
    force: bool = False


def main() -> None:
    parser = argparse.ArgumentParser(description="Check package update scripts")
    mode = parser.add_mutually_exclusive_group()
    _ = mode.add_argument("--pr", action="store_true")
    _ = mode.add_argument("--update", action="store_true")
    _ = parser.add_argument("--force", action="store_true")
    args = parser.parse_args(namespace=Arguments())
    try:
        check_updates(maintain.ROOT, args.pr, args.update, args.force)
    except (OSError, ValueError, KeyError, subprocess.SubprocessError) as error:
        report(f"Update failed: {error}")
        parser.exit(1)


if __name__ == "__main__":
    main()
