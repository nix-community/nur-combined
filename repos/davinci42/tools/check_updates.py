# pyright: reportAny=false, reportExplicitAny=false, reportUnusedCallResult=false, reportUnusedExpression=false
import argparse
import os
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any
from urllib.parse import quote
from uuid import uuid4

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tools import maintain
from tools.maintain import Pipe


def detect(root: Path, package: str) -> tuple[str, str] | None:
    with tempfile.TemporaryDirectory(prefix="nur-detect-") as temporary:
        candidate = Path(temporary) / "repo"

        def run_detect(ws: Path) -> tuple[dict[str, Any], str, str]:
            maintain.copy_repository(root, ws)
            info = maintain.update_info(ws, package)
            maintain.execute_update(ws, package, detect=True, info=info)
            return info, info["identity"], maintain.update_info(ws, package)["identity"]

        def filter_newer(
            state: tuple[dict[str, Any], str, str],
        ) -> tuple[str, str] | None:
            info, current, target = state
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
            return None if comparison == "-1" else (current, target)

        return (Pipe(candidate) | run_detect | filter_newer).value


def github(root: Path, arguments: list[str]) -> str:
    return subprocess.run(
        ["gh", *arguments],
        cwd=root,
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        timeout=300,
    ).stdout.strip()


def pr_body(
    root: Path,
    package: str,
    current: str,
    target: str,
    before: dict[str, Any],
    after: dict[str, Any],
) -> str:
    if not all(
        isinstance(info.get(key), str) and info[key]
        for info in (before, after)
        for key in ("upstream", "sourceRef", "system")
    ):
        raise ValueError("Cannot determine upstream diff or validation platform")
    if before["upstream"] != after["upstream"]:
        raise ValueError("Upstream repository changed; review manually")
    old_ref = quote(before["sourceRef"], safe="")
    new_ref = quote(after["sourceRef"], safe="")
    template = (root / ".github/package-update-pr.md").read_text()
    run_id = os.environ.get("GITHUB_RUN_ID")
    ci_url = (
        f"{os.environ['GITHUB_SERVER_URL']}/{os.environ['GITHUB_REPOSITORY']}/actions/runs/{run_id}"
        if run_id
        else ""
    )
    if not run_id:
        template = template.replace("[CI logs]({ci_run_url})\n", "")
    return template.format(
        package=package,
        old_version=current,
        new_version=target,
        compare_url=f"{after['upstream']}/compare/{old_ref}...{new_ref}",
        check_command=f"just check {package}",
        system=after["system"],
        checks_run="Package build, package checks, lint and `git diff --check`",
        ci_run_url=ci_url,
    ).strip()


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
        maintain.run(
            root, ["git", "worktree", "add", "--detach", str(worktree), "HEAD"]
        )
        try:
            before = maintain.update_info(worktree, package)
            if not maintain.update(
                worktree, package, None if before["snapshot"] else target
            ):
                return f"{package}: no changes"
            after = maintain.update_info(worktree, package)
            if after["identity"] != target:
                raise ValueError("Upstream moved during update; retry the check")
            body = pr_body(root, package, current, target, before, after)
            for cmd in (
                ["git", "diff", "--check"],
                ["git", "add", "--", f"pkgs/{package}"],
                ["git", "commit", "-m", title],
                ["git", "push", "-u", "origin", f"HEAD:refs/heads/{branch}"],
            ):
                maintain.run(worktree, cmd)
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
                    body,
                ],
            )
        finally:
            maintain.run(root, ["git", "worktree", "remove", "--force", str(worktree)])


def report(message: str) -> None:
    print(message, flush=True)
    if summary := os.environ.get("GITHUB_STEP_SUMMARY"):
        with Path(summary).open("a") as output:
            output.write(f"- {message}\n")


def check_updates(
    root: Path, pr: bool = False, update: bool = False, force: bool = False
) -> None:
    if force and not pr:
        raise ValueError("--force requires --pr")
    if pr and maintain.run(root, ["git", "status", "--porcelain"], capture=True):
        raise ValueError("PR publishing requires a clean checkout")
    failures: list[str] = []

    def handle(package: str) -> None:
        candidate = detect(root, package)
        if not candidate:
            report(f"{package}: no newer version")
            return
        current, target = candidate
        if pr:
            report(open_pr(root, package, current, target, force))
        elif update:
            snapshot = maintain.update_info(root, package)["snapshot"]
            maintain.update(root, package, None if snapshot else target)
        else:
            report(f"{package}: {current} -> {target} (read-only check)")

    for package in maintain.packages(root):
        try:
            Pipe(package) | handle
        except (OSError, ValueError, KeyError, subprocess.SubprocessError) as error:
            failures.append(package)
            report(f"{package}: failed: {error}")
    if failures:
        raise ValueError("Updates failed for: " + ", ".join(failures))


def main() -> None:
    parser = argparse.ArgumentParser(description="Check package update scripts")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--pr", action="store_true")
    mode.add_argument("--update", action="store_true")
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()
    try:
        check_updates(maintain.ROOT, args.pr, args.update, args.force)
    except (OSError, ValueError, KeyError, subprocess.SubprocessError) as error:
        report(f"Update failed: {error}")
        parser.exit(1)


if __name__ == "__main__":
    main()
