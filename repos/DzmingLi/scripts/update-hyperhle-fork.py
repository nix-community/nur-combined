#!/usr/bin/env python3
"""Regenerate the checked-in crate2nix inputs, then verify before keeping them."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import urllib.request

FEATURE = "touchHLE_libxml2_wrapper/static"
GENERATED = ("sources.json", "Cargo.nix", "crate-hashes.json", "rust-dependencies.txt")


def run(*args, cwd=None, env=None):
    return subprocess.check_output(args, cwd=cwd, env=env, text=True).strip()


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2) + "\n")


def generate(source, output, package, info):
    """Only source inputs are hashed; patches remain ordinary Nix inputs."""
    layout = json.loads((package / "source-layout.json").read_text())
    info["components"] = {}
    for name, spec in layout.items():
        with tempfile.TemporaryDirectory() as temporary:
            for relative in [spec["path"], *spec["vendor"]]:
                target = Path(temporary) / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copytree(source / relative, target, symlinks=True)
            info["components"][name] = run("nix", "hash", "path", temporary)
    write_json(output / "sources.json", info)

    # Keep output paths relative to the upstream tree, never to a temporary
    # checkout. The Nix overrides supply every local crate's actual source.
    hash_cache = package / "crate-hashes.json"
    if hash_cache.exists():
        shutil.copyfile(hash_cache, source / "crate-hashes.json")
    lock_before = (source / "Cargo.lock").read_bytes()
    subprocess.run(
        ["crate2nix", "generate", "--no-default-features", "--features", FEATURE],
        cwd=source, check=True,
    )
    if (source / "Cargo.lock").read_bytes() != lock_before:
        raise RuntimeError("crate2nix changed Cargo.lock; refusing an unlocked update")
    for name in ("Cargo.nix", "crate-hashes.json"):
        (output / name).write_text((source / name).read_text().rstrip() + "\n")

    metadata = json.loads(run(
        "cargo", "metadata", "--locked", "--format-version", "1",
        "--no-default-features", "--features", FEATURE, cwd=source,
    ))
    # Match upstream cargo-license's traversal: include transitive normal
    # dependencies, across targets, excluding dev/build-only dependencies.
    nodes = {node["id"]: node for node in metadata["resolve"]["nodes"]}
    root = metadata["resolve"]["root"]
    pending = [root] if root else metadata["workspace_members"][:]
    connected = set()
    while pending:
        ident = pending.pop()
        if ident in connected:
            continue
        connected.add(ident)
        pending.extend(dep["pkg"] for dep in nodes[ident]["deps"]
                       if any(kind["kind"] is None for kind in dep["dep_kinds"]))
    lines = []
    for dep in sorted(metadata["packages"], key=lambda p: (p["name"], p["version"])):
        if dep["id"] not in connected or dep["name"].startswith("touchHLE"):
            continue
        if not dep["license"]:
            raise RuntimeError(f"Missing license for {dep['name']}")
        authors = ", ".join(sorted(set(dep["authors"])))
        author_text = f" by {authors}" if authors else " (author unspecified)"
        lines.append(f"- {dep['name']} version {dep['version']}{author_text}, "
                     f"licensed under {dep['license']}\n")
    (output / "rust-dependencies.txt").write_text("".join(lines))


def latest_tag():
    headers = {"Accept": "application/vnd.github+json", "User-Agent": "nur-hyperhle-updater"}
    if token := os.environ.get("GITHUB_TOKEN"):
        headers["Authorization"] = f"Bearer {token}"
    request = urllib.request.Request(
        "https://api.github.com/repos/KlugKlugTG/HyperHLE-Fork/releases/latest",
        headers=headers,
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        release = json.load(response)
    if release["draft"] or release["prerelease"]:
        raise RuntimeError("Expected a stable published release")
    return release["tag_name"]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--regenerate", action="store_true", help="regenerate the pinned revision")
    mode.add_argument("--version", help="release tag/version; default: latest stable release")
    parser.add_argument("--no-build", action="store_true", help="only generate and evaluate (development)")
    args = parser.parse_args()
    repo = Path(run("git", "rev-parse", "--show-toplevel"))
    package = repo / "pkgs/hyperhle-fork"
    info = json.loads((package / "sources.json").read_text())
    if not args.regenerate:
        tag = args.version or latest_tag()
        version = tag.removeprefix("v")
        if version == info["version"]:
            print(f"hyperhle-fork {version}: up to date")
            return
        if not tag.startswith("v"):
            tag = "v" + tag
        fetched = json.loads(run(
            "nix-prefetch-git", "--url", "https://github.com/KlugKlugTG/HyperHLE-Fork.git",
            "--rev", "refs/tags/" + tag, "--fetch-submodules",
        ))
        info = {"version": version, "rev": fetched["rev"], "hash": run(
            "nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", fetched["sha256"],
        )}

    original = {name: (package / name).read_bytes() if (package / name).exists() else None
                for name in GENERATED}
    with tempfile.TemporaryDirectory(prefix="hyperhle-update-") as temporary:
        temporary = Path(temporary)
        write_json(temporary / "fetch.json", {
            "owner": "KlugKlugTG", "repo": "HyperHLE-Fork", "fetchSubmodules": True,
            "rev": info["rev"], "hash": info["hash"],
        })
        env = dict(os.environ, HYPERHLE_UPDATE_REPO=str(repo),
                   HYPERHLE_UPDATE_FETCH=str(temporary / "fetch.json"))
        source_store = run("nix", "build", "--impure", "--no-link", "--print-out-paths", "--expr", """
            let pkgs = import (builtins.getFlake (builtins.getEnv "HYPERHLE_UPDATE_REPO")).inputs.nixpkgs {};
            in pkgs.fetchFromGitHub (builtins.fromJSON (builtins.readFile (builtins.getEnv "HYPERHLE_UPDATE_FETCH")))
        """, env=env)
        source = temporary / "source"
        shutil.copytree(source_store, source, symlinks=True)
        # Nix store sources are read-only; only the temporary copy is writable.
        for path in [source, *source.rglob("*")]:
            if not path.is_symlink():
                path.chmod(path.stat().st_mode | 0o200)
        output = temporary / "generated"
        output.mkdir()
        generate(source, output, package, info)
        # Fail before touching the package if a carried patch no longer applies.
        for name in (
            "fix-hidpi-window-and-mouse.patch",
            "fix-max-texture-size.patch",
            "fix-sigsetjmp-exports.patch",
            "fix-ctype-exports.patch",
            "precomputed-licenses.patch",
        ):
            subprocess.run(["patch", "--batch", "-p1", "-i", str(package / name)],
                           cwd=source, check=True)
        for name, content in original.items():
            current = (package / name).read_bytes() if (package / name).exists() else None
            if current != content:
                raise RuntimeError(f"{name} changed during generation; refusing to overwrite it")
        try:
            for name in GENERATED:
                shutil.copyfile(output / name, package / name)
            subprocess.run(["nix", "eval", ".#hyperhle-fork.drvPath", "--raw",
                            "--option", "allow-import-from-derivation", "false"], cwd=repo, check=True)
            if not args.no_build:
                subprocess.run(["nix", "build", ".#hyperhle-fork", "--no-link"], cwd=repo, check=True)
        except BaseException:
            for name, content in original.items():
                if content is None:
                    (package / name).unlink(missing_ok=True)
                else:
                    (package / name).write_bytes(content)
            raise
    print(f"\nhyperhle-fork {info['version']}: generated and verified")


if __name__ == "__main__":
    main()
