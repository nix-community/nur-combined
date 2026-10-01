import argparse
import difflib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import NotRequired, TypedDict, cast

import tomllib

ROOT = Path(__file__).resolve().parents[1]
EXCLUDED = {".git", ".crush", ".ruff_cache", ".mypy_cache", "__pycache__"}


class ReleaseSpecification(TypedDict):
    repository: str
    assets: list[str]


class Specification(TypedDict):
    files: list[str]
    sync: NotRequired[list[str]]
    contract: NotRequired[list[str]]
    tests: NotRequired[list[list[str]]]
    runtimePackageEnv: NotRequired[str]
    rawSource: NotRequired[str]
    release: NotRequired[ReleaseSpecification]


class Arguments(argparse.Namespace):
    action: str = ""
    package: str | None = None
    version: str = "stable"
    accept_contract: bool = False


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


def string_list(value: object) -> bool:
    return (
        isinstance(value, list)
        and bool(cast(list[object], value))
        and all(isinstance(item, str) for item in cast(list[object], value))
    )


def validate_release(release: dict[str, object]) -> None:
    repository = release.get("repository")
    if not isinstance(repository, str) or not re.fullmatch(
        r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", repository
    ):
        raise ValueError("release.repository must be owner/repository")
    if not string_list(release.get("assets")):
        raise ValueError("release.assets must be a nonempty list of filenames")
    if set(release) - {"repository", "assets"}:
        raise ValueError("Unknown release metadata fields")


def specification(root: Path, package: str) -> Specification:
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_-]*", package):
        raise ValueError("Invalid package name")
    folder = root / "pkgs" / package
    raw = cast(
        dict[str, object], tomllib.loads((folder / "maintenance.toml").read_text())
    )

    if not string_list(raw.get("files")):
        raise ValueError("files must be a nonempty list of strings")
    for key in ("sync", "contract"):
        if key in raw and not string_list(raw[key]):
            raise ValueError("Commands must be nonempty arrays of arguments")
    if "tests" in raw:
        tests = raw["tests"]
        if not isinstance(tests, list) or not all(
            string_list(item) for item in cast(list[object], tests)
        ):
            raise ValueError("tests must contain command arrays")
    for key in ("runtimePackageEnv", "rawSource"):
        if key in raw and not isinstance(raw[key], str):
            raise ValueError(key + " must be a string")
    if "release" in raw:
        if not isinstance(raw["release"], dict):
            raise ValueError("release must be a table")
        validate_release(cast(dict[str, object], raw["release"]))
    spec = cast(Specification, cast(object, raw))
    allowed = {
        "files",
        "sync",
        "contract",
        "tests",
        "runtimePackageEnv",
        "rawSource",
        "release",
    }
    if set(spec) - allowed:
        raise ValueError("Unknown maintenance metadata fields")
    for name in spec["files"]:
        path = folder / name
        if (
            path.is_symlink()
            or not path.is_file()
            or not path.resolve().is_relative_to(folder.resolve())
        ):
            raise ValueError(
                "Update files must be regular files inside the package directory"
            )
    if "rawSource" in spec and spec["rawSource"] not in spec["files"]:
        raise ValueError("rawSource must be listed in files")
    for command in [spec.get("sync"), spec.get("contract"), *spec.get("tests", [])]:
        if command is not None and (not command):
            raise ValueError("Commands must be nonempty arrays of arguments")
    return spec


def package_info(root: Path, package: str) -> tuple[str, list[str]]:
    version = run(
        root, ["nix", "eval", "-f", ".", package + ".version", "--raw"], capture=True
    )
    systems = cast(
        list[str],
        json.loads(
            run(
                root,
                ["nix", "eval", "-f", ".", package + ".meta.platforms", "--json"],
                capture=True,
            )
        ),
    )
    if not systems or not all(
        re.fullmatch(r"[A-Za-z0-9_]+-(linux|darwin|freebsd|netbsd|openbsd)", system)
        for system in systems
    ):
        raise ValueError("meta.platforms must contain explicit supported system names")
    return version, sorted(set(systems))


def refresh_raw_source(root: Path, package: str, system: str, filename: str) -> None:
    expression = (
        f"let pkgs = import <nixpkgs> {{ system = {json.dumps(system)}; }}; "
        f"src = (import ./. {{ inherit pkgs; }}).{package}.src; "
        "in { inherit (src) url outputHash outputHashMode; }"
    )
    source = cast(
        dict[str, str],
        json.loads(
            run(
                root,
                ["nix", "eval", "--impure", "--json", "--expr", expression],
                capture=True,
            )
        ),
    )
    if source["outputHashMode"] != "flat":
        raise ValueError(
            "rawSource requires a flat fetchurl source, not an unpacked archive"
        )
    fetched = cast(
        dict[str, str],
        json.loads(
            run(
                root,
                ["nix", "store", "prefetch-file", "--json", source["url"]],
                capture=True,
            )
        ),
    )
    target = root / "pkgs" / package / filename
    content = target.read_text()
    if source["outputHash"] == fetched["hash"]:
        return
    if content.count(source["outputHash"]) != 1:
        raise ValueError("Cannot uniquely locate the platform hash in rawSource")
    _ = target.write_text(content.replace(source["outputHash"], fetched["hash"]))


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


def check(root: Path, package: str, spec: Specification) -> None:
    _, systems = package_info(root, package)
    host = cast(
        str,
        json.loads(
            run(
                root,
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
    if host not in systems:
        raise ValueError(
            f"Cannot validate {package} on {host}; use a supported build host"
        )
    output = run(
        root,
        ["nix", "build", "-f", ".", package, "--no-link", "--print-out-paths"],
        capture=True,
    )
    env = os.environ | {"PYTHONDONTWRITEBYTECODE": "1"}
    if "runtimePackageEnv" in spec:
        env[spec["runtimePackageEnv"]] = output.splitlines()[0]
    for command in spec.get("tests", []):
        _ = run(root, command, env=env)
    lint(root)
    print(
        f"Built and tested: {host}. Other platforms not build-tested: {', '.join(system for system in systems if system != host) or 'none'}",
        flush=True,
    )


def contract_changed(before: bytes, after: bytes) -> bool:
    old = cast(dict[str, object], json.loads(before))
    new = cast(dict[str, object], json.loads(after))
    _ = old.pop("version", None)
    _ = new.pop("version", None)
    return old != new


def publish(
    root: Path, before: dict[str, bytes], candidate: dict[str, bytes], allowed: set[str]
) -> None:
    changed = {
        name
        for name in before.keys() | candidate.keys()
        if before.get(name) != candidate.get(name)
    }
    if changed - allowed:
        raise ValueError(
            "Updater modified undeclared files: " + ", ".join(sorted(changed - allowed))
        )
    if snapshot(root) != before:
        raise ValueError(
            "Working files changed during validation; refusing to overwrite them"
        )
    for name in sorted(changed):
        if name not in candidate:
            raise ValueError("Updater deleted a declared file")
    written: list[str] = []
    try:
        for name in sorted(changed):
            written.append(name)
            _ = (root / name).write_bytes(candidate[name])
    except OSError:
        for name in written:
            _ = (root / name).write_bytes(before[name])
        raise
    print(
        f"Updated {len(changed)} file(s); review git diff. Nothing committed or pushed."
    )


def update(
    root: Path, package: str, version: str, accept_contract: bool = False
) -> None:
    spec = specification(root, package)
    before = snapshot(root)
    allowed = {f"pkgs/{package}/{name}" for name in spec["files"]}
    with tempfile.TemporaryDirectory(prefix="nur-update-") as temporary:
        candidate = Path(temporary) / "repo"
        _ = shutil.copytree(
            root,
            candidate,
            ignore=lambda _folder, names: [
                name for name in names if name in EXCLUDED or name.startswith("result")
            ],
            symlinks=True,
        )
        _ = run(candidate, ["git", "init", "--quiet"])
        _ = run(candidate, ["git", "add", "."])
        _, systems = package_info(candidate, package)
        _ = run(
            candidate,
            [
                "nix-update",
                "-f",
                ".",
                package,
                "--system",
                systems[0],
                "--version=" + version,
                *(["--no-src"] if "rawSource" in spec else []),
            ],
        )
        target, target_systems = package_info(candidate, package)
        if target_systems != systems:
            raise ValueError(
                "Supported platforms changed during version update; review manually"
            )
        for system in systems:
            if "rawSource" in spec:
                refresh_raw_source(candidate, package, system, spec["rawSource"])
            else:
                _ = run(
                    candidate,
                    [
                        "nix-update",
                        "-f",
                        ".",
                        package,
                        "--system",
                        system,
                        "--version=skip",
                    ],
                )
            if package_info(candidate, package)[0] != target:
                raise ValueError(
                    "Package version changed while refreshing platform hashes"
                )
        if "sync" in spec:
            _ = run(candidate, spec["sync"])
        if "contract" in spec:
            _ = run(candidate, spec["contract"])
        after = snapshot(candidate)
        for name in sorted(allowed):
            if before[name] != after[name]:
                print(
                    "".join(
                        difflib.unified_diff(
                            before[name].decode().splitlines(True),
                            after[name].decode().splitlines(True),
                            fromfile=name,
                            tofile=name,
                        )
                    ),
                    flush=True,
                )
        schema_changes = any(
            name.endswith("-schema.json")
            and contract_changed(before[name], after[name])
            for name in allowed
        )
        if schema_changes and not accept_contract:
            raise ValueError(
                "Upstream contract changed. Review the diff, then rerun update-reviewed to accept it; working files are unchanged"
            )
        check(candidate, package, spec)
        publish(root, before, snapshot(candidate), allowed)
        print(f"Target version: {target}; refreshed hashes for: {', '.join(systems)}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Structured NUR package maintenance")
    _ = parser.add_argument(
        "action", choices=["update", "check", "contract", "lint", "check-all"]
    )
    _ = parser.add_argument("package", nargs="?")
    _ = parser.add_argument("--version", default="stable")
    _ = parser.add_argument("--accept-contract", action="store_true")
    args = parser.parse_args(namespace=Arguments())
    try:
        if args.action == "lint":
            lint(ROOT)
        elif args.action == "check-all":
            for path in sorted((ROOT / "pkgs").glob("*/maintenance.toml")):
                check(ROOT, path.parent.name, specification(ROOT, path.parent.name))
            for test in ("maintenance", "updates"):
                _ = run(
                    ROOT,
                    ["python3", f"tests/{test}.py", "-v"],
                    env=os.environ | {"PYTHONDONTWRITEBYTECODE": "1"},
                )
        elif not args.package:
            parser.error("package is required")
        elif args.action == "update":
            update(ROOT, args.package, args.version, args.accept_contract)
        else:
            spec = specification(ROOT, args.package)
            if args.action == "check":
                check(ROOT, args.package, spec)
            elif "contract" in spec:
                _ = run(ROOT, spec["contract"])
            else:
                print("No upstream contract check declared for " + args.package)
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        parser.exit(1, f"Maintenance failed: {error}\n")


if __name__ == "__main__":
    main()
