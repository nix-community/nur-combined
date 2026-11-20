# pyright: reportAny=false, reportExplicitAny=false, reportUnusedCallResult=false, reportUnusedExpression=false
import argparse
import os
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any

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


def report(message: str) -> None:
    print(message, flush=True)
    if summary := os.environ.get("GITHUB_STEP_SUMMARY"):
        with Path(summary).open("a") as output:
            output.write(f"- {message}\n")


def check_updates(
    root: Path, update: bool = False, commit: bool = False
) -> None:
    if commit and not update:
        raise ValueError("--commit requires --update")
    if commit and maintain.run(root, ["git", "status", "--porcelain"], capture=True):
        raise ValueError("--commit requires a clean checkout")
    failures: list[str] = []

    def handle(package: str) -> None:
        candidate = detect(root, package)
        if not candidate:
            report(f"{package}: no newer version")
            return
        current, target = candidate
        if update:
            snapshot = maintain.update_info(root, package)["snapshot"]
            if not maintain.update(root, package, None if snapshot else target):
                return
            if commit:
                title = f"{package}: {current} -> {target}"
                if len(title) >= 72:
                    title = f"{package}: {current[:12]} -> {target[:12]}"
                maintain.run(root, ["git", "add", "--", f"pkgs/{package}"])
                maintain.run(root, ["git", "commit", "-m", title])
            report(f"{package}: {current} -> {target}")
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
    parser.add_argument("--update", action="store_true")
    parser.add_argument("--commit", action="store_true")
    args = parser.parse_args()
    try:
        check_updates(maintain.ROOT, args.update, args.commit)
    except (OSError, ValueError, KeyError, subprocess.SubprocessError) as error:
        report(f"Update failed: {error}")
        parser.exit(1)


if __name__ == "__main__":
    main()
