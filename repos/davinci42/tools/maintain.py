# pyright: reportAny=false, reportExplicitAny=false, reportUnusedCallResult=false
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from collections.abc import Callable
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
EXCLUDED = {".git", ".crush", ".ruff_cache", ".mypy_cache", "__pycache__"}


class Pipe[T]:
    def __init__(self, value: T) -> None:
        self.value: T = value

    def __or__[U](self, step: Callable[[T], U]) -> "Pipe[U]":
        return Pipe(step(self.value))


def run(
    root: Path,
    command: list[str],
    capture: bool = False,
    env: dict[str, str] | None = None,
) -> str:
    print("+ " + " ".join(command), flush=True)
    result = subprocess.run(
        command,
        cwd=root,
        check=True,
        text=True,
        stdout=subprocess.PIPE if capture else None,
        env=env,
    )
    return result.stdout.strip() if capture else ""


def packages(root: Path) -> list[str]:
    expr = 'let packages = import ./. {}; in builtins.attrNames (builtins.removeAttrs packages ["nixosModules" "darwinModules"])'
    return json.loads(
        run(root, ["nix", "eval", "--impure", "--json", "--expr", expr], capture=True)
    )


def update_info(root: Path, package: str) -> dict[str, Any]:
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_-]*", package):
        raise ValueError("Invalid package name")
    return json.loads(
        run(
            root,
            [
                "nix-instantiate",
                "--eval",
                "--strict",
                "--json",
                str(Path(__file__).with_name("update-info.nix")),
                "--argstr",
                "root",
                str(root.resolve()),
                "--argstr",
                "name",
                package,
            ],
            capture=True,
        )
    )


def execute_update(
    root: Path,
    package: str,
    target: str | None = None,
    accept_contract: bool = False,
    detect: bool = False,
    info: dict[str, Any] | None = None,
) -> None:
    info = info or update_info(root, package)
    command = list(info["command"])
    if not command:
        raise ValueError("Empty updateScript")
    env = (
        os.environ
        | info["env"]
        | {"NUR_ACCEPT_CONTRACT": "1" if accept_contract else "0"}
    )
    upstream = info.get("upstream")
    if not target and not info.get("snapshot") and isinstance(upstream, str):
        target = run(
            root,
            [
                "gh",
                "release",
                "view",
                "--repo",
                upstream,
                "--json",
                "tagName",
                "--jq",
                ".tagName",
            ],
            capture=True,
        ).removeprefix("v")
    is_nix_update = Path(command[0]).name == "nix-update"
    if target:
        env["NUR_TARGET_VERSION"] = target
        if is_nix_update:
            command = [
                arg for arg in command if not arg.startswith("--version=")
            ] + ["--version=" + target]
    if detect:
        if is_nix_update:
            command.extend(["--src-only", "--no-src"])
        else:
            env["NUR_DETECT_VERSION"] = "1"
    if command[0].startswith("/nix/store/"):
        run(
            root,
            [
                "nix-build",
                "--no-out-link",
                "--expr",
                '{ name }: let pkgs = import <nixpkgs> {}; package = (import ./. {}).${name}; in pkgs.writeText "update-script" (builtins.toJSON package.updateScript)',
                "--argstr",
                "name",
                package,
            ],
            capture=True,
        )
    run(root, command, env=env)


def snapshot(root: Path) -> dict[str, bytes]:
    return {
        str(path.relative_to(root)): path.read_bytes()
        for path in root.rglob("*")
        if path.is_file()
        and not path.is_symlink()
        and not any(
            part in EXCLUDED or part.startswith("result")
            for part in path.relative_to(root).parts
        )
    }


def copy_repository(root: Path, destination: Path) -> None:
    shutil.copytree(
        root,
        destination,
        symlinks=True,
        ignore=lambda _folder, names: [
            name for name in names if name in EXCLUDED or name.startswith("result")
        ],
    )
    for cmd in (["git", "init", "--quiet"], ["git", "add", "."]):
        run(destination, cmd)


def lint(root: Path) -> None:
    files = snapshot(root)
    nix_files = sorted(name for name in files if name.endswith(".nix"))
    python_files = sorted(name for name in files if name.endswith(".py"))
    for cmd in (
        ["nixfmt", "--check", *nix_files],
        ["statix", "check", "."],
        ["deadnix", "--fail", "."],
        ["ruff", "check", *python_files],
        [
            "basedpyright",
            "--pythonpath",
            sys.executable,
            "--level",
            "warning",
            *python_files,
        ],
    ):
        run(root, cmd)


def check(root: Path, package: str, *, run_lint: bool = True) -> None:
    update_info(root, package)
    run(root, ["nix", "build", "-f", ".", package, package + ".tests", "--no-link"])
    if run_lint:
        lint(root)


def publish(
    root: Path, before: dict[str, bytes], after: dict[str, bytes], package: str
) -> None:
    changed = {
        name
        for name in before.keys() | after.keys()
        if before.get(name) != after.get(name)
    }
    if any(not name.startswith(f"pkgs/{package}/") for name in changed):
        raise ValueError("Updater modified files outside its package directory")
    if any(name not in before or name not in after for name in changed):
        raise ValueError("Updater added or deleted files; review manually")
    if snapshot(root) != before:
        raise ValueError(
            "Working files changed during validation; refusing to overwrite them"
        )
    for name in sorted(changed):
        (root / name).write_bytes(after[name])


def update(
    root: Path, package: str, target: str | None = None, accept_contract: bool = False
) -> bool:
    info = update_info(root, package)
    before = snapshot(root)
    with tempfile.TemporaryDirectory(prefix="nur-update-") as temporary:
        candidate = Path(temporary) / "repo"

        def apply(ws: Path) -> Path | None:
            copy_repository(root, ws)
            execute_update(ws, package, target, accept_contract, info=info)
            return ws if snapshot(ws) != before else None

        def validate_and_publish(ws: Path | None) -> bool:
            if ws is None:
                print(f"{package}: no changes")
                return False
            check(ws, package)
            run(ws, ["git", "diff", "--check"])
            publish(root, before, snapshot(ws), package)
            print(f"{package}: updated and validated; nothing committed or pushed")
            return True

        return (Pipe(candidate) | apply | validate_and_publish).value


def main() -> None:
    parser = argparse.ArgumentParser(description="Run package update scripts and tests")
    parser.add_argument("action", choices=["update", "check", "check-all", "lint"])
    parser.add_argument("package", nargs="?")
    parser.add_argument("--version")
    parser.add_argument("--accept-contract", action="store_true")
    args = parser.parse_args()
    try:
        if args.action == "lint":
            lint(ROOT)
        elif args.action == "check-all":
            for package in packages(ROOT):
                check(ROOT, package, run_lint=False)
            for test in ("maintenance", "updates"):
                run(ROOT, [sys.executable, f"tests/{test}.py", "-v"])
            lint(ROOT)
        elif not args.package:
            parser.error("package is required")
        elif args.action == "update":
            update(ROOT, args.package, args.version, args.accept_contract)
        else:
            check(ROOT, args.package)
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        parser.exit(1, f"Maintenance failed: {error}\n")


if __name__ == "__main__":
    main()
