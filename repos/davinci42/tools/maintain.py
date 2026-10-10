import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import cast

ROOT = Path(__file__).resolve().parents[1]
EXCLUDED = {".git", ".crush", ".ruff_cache", ".mypy_cache", "__pycache__"}


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
    return cast(
        list[str],
        json.loads(
            run(
                root,
                [
                    "nix",
                    "eval",
                    "--impure",
                    "--json",
                    "--expr",
                    'let packages = import ./. {}; in builtins.attrNames (builtins.removeAttrs packages ["nixosModules"])',
                ],
                capture=True,
            )
        ),
    )


def update_info(root: Path, package: str) -> dict[str, object]:
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_-]*", package):
        raise ValueError("Invalid package name")
    return cast(
        dict[str, object],
        json.loads(
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
        ),
    )


def update_command(root: Path, package: str) -> list[str]:
    return cast(list[str], update_info(root, package)["command"])


def execute_update(
    root: Path,
    package: str,
    target: str | None = None,
    accept_contract: bool = False,
    detect: bool = False,
    info: dict[str, object] | None = None,
) -> None:
    if info is None:
        info = update_info(root, package)
    command = list(cast(list[str], info["command"]))
    if not command:
        raise ValueError("Empty updateScript")
    env = (
        os.environ
        | cast(dict[str, str], info["env"])
        | {
            "NUR_ACCEPT_CONTRACT": "1" if accept_contract else "0",
        }
    )
    if target:
        env["NUR_TARGET_VERSION"] = target
        if Path(command[0]).name == "nix-update":
            command = [
                argument
                for argument in command
                if not argument.startswith("--version=")
            ]
            command.append("--version=" + target)
    if detect:
        if Path(command[0]).name == "nix-update":
            command.extend(["--src-only", "--no-src"])
        else:
            env["NUR_DETECT_VERSION"] = "1"
    _ = run(
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
    _ = run(root, command, env=env)


def version(root: Path, package: str) -> str:
    return cast(str, update_info(root, package)["identity"])


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
    _ = shutil.copytree(
        root,
        destination,
        symlinks=True,
        ignore=lambda _folder, names: [
            name for name in names if name in EXCLUDED or name.startswith("result")
        ],
    )
    _ = run(destination, ["git", "init", "--quiet"])
    _ = run(destination, ["git", "add", "."])


def lint(root: Path) -> None:
    files = snapshot(root)
    nix_files = sorted(name for name in files if name.endswith(".nix"))
    python_files = sorted(name for name in files if name.endswith(".py"))
    _ = run(root, ["nixfmt", "--check", *nix_files])
    _ = run(root, ["statix", "check", "."])
    _ = run(root, ["deadnix", "--fail", "."])
    _ = run(root, ["ruff", "check", *python_files])
    _ = run(
        root,
        [
            "basedpyright",
            "--pythonpath",
            sys.executable,
            "--level",
            "warning",
            *python_files,
        ],
    )


def check(root: Path, package: str, *, run_lint: bool = True) -> None:
    _ = update_command(root, package)
    _ = run(root, ["nix", "build", "-f", ".", package, package + ".tests", "--no-link"])
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
    written: list[str] = []
    try:
        for name in sorted(changed):
            written.append(name)
            _ = (root / name).write_bytes(after[name])
    except OSError:
        for name in written:
            _ = (root / name).write_bytes(before[name])
        raise


def update(
    root: Path, package: str, target: str | None = None, accept_contract: bool = False
) -> bool:
    _ = update_command(root, package)
    before = snapshot(root)
    with tempfile.TemporaryDirectory(prefix="nur-update-") as temporary:
        candidate = Path(temporary) / "repo"
        copy_repository(root, candidate)
        execute_update(candidate, package, target, accept_contract)
        after = snapshot(candidate)
        if before == after:
            print(f"{package}: no changes")
            return False
        check(candidate, package)
        _ = run(candidate, ["git", "diff", "--check"])
        publish(root, before, snapshot(candidate), package)
    print(f"{package}: updated and validated; nothing committed or pushed")
    return True


class Arguments(argparse.Namespace):
    action: str = ""
    package: str | None = None
    version: str | None = None
    accept_contract: bool = False


def main() -> None:
    parser = argparse.ArgumentParser(description="Run package update scripts and tests")
    _ = parser.add_argument("action", choices=["update", "check", "check-all", "lint"])
    _ = parser.add_argument("package", nargs="?")
    _ = parser.add_argument("--version")
    _ = parser.add_argument("--accept-contract", action="store_true")
    args = parser.parse_args(namespace=Arguments())
    try:
        if args.action == "lint":
            lint(ROOT)
        elif args.action == "check-all":
            for package in packages(ROOT):
                check(ROOT, package, run_lint=False)
            for test in ("maintenance", "updates"):
                _ = run(ROOT, [sys.executable, f"tests/{test}.py", "-v"])
            lint(ROOT)
        elif not args.package:
            parser.error("package is required")
        elif args.action == "update":
            _ = update(ROOT, args.package, args.version, args.accept_contract)
        else:
            check(ROOT, args.package)
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        parser.exit(1, f"Maintenance failed: {error}\n")


if __name__ == "__main__":
    main()
