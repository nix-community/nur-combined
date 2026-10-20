#!/usr/bin/env python3
"""Synchronize StoryForge source and locks, without building the application."""
from __future__ import annotations

import argparse
import base64
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import sys
import tempfile
import time
import tomllib
import urllib.error
import urllib.parse
import urllib.request

PACKAGE = Path(__file__).resolve().parent
REPOSITORY = PACKAGE.parent.parent
API = "https://api.github.com/repos/LovelessCodes/StoryForge"
TAG_RE = re.compile(r"storyforge-v(\d+)\.(\d+)\.(\d+)")
SHA_RE = re.compile(r"[0-9a-f]{40}")
PUBLISH = ("source.json", "Cargo.lock", "bun.nix", "compatibility.json")

# Updating a package must not create Python bytecode that could enter its PR.
sys.dont_write_bytecode = True
_spec = importlib.util.spec_from_file_location("storyforge_compatibility", PACKAGE / "compatibility.py")
compatibility = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(compatibility)


class UpdateError(RuntimeError):
    pass


def _redact(value):
    token = os.environ.get("GITHUB_TOKEN")
    return value.replace(token, "[REDACTED]") if token else value


def run(command, *, cwd=None):
    try:
        result = subprocess.run(command, cwd=cwd, text=True, capture_output=True,
                                check=False, timeout=720)
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise UpdateError(f"could not run {command[0]}: {_redact(str(exc))}") from exc
    if result.returncode:
        raise UpdateError(f"command failed ({result.returncode}): {command[0]}\n"
                          + _redact(result.stderr[-4000:]))
    return result.stdout


def github_json(path):
    request = urllib.request.Request(API + path, headers={
        "Accept": "application/vnd.github+json", "User-Agent": "urio-nur-storyforge-updater",
    })
    if os.environ.get("GITHUB_TOKEN"):
        request.add_header("Authorization", "Bearer " + os.environ["GITHUB_TOKEN"])
    for attempt in range(3):
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                return json.load(response)
        except urllib.error.HTTPError as exc:
            if exc.code not in (429, 500, 502, 503, 504) or attempt == 2:
                raise UpdateError(f"GitHub API {path}: HTTP {exc.code}") from exc
        except (urllib.error.URLError, TimeoutError) as exc:
            if attempt == 2:
                raise UpdateError(f"GitHub API {path}: {_redact(str(exc))}") from exc
        except ValueError as exc:
            raise UpdateError(f"GitHub API {path}: malformed JSON") from exc
        time.sleep(2 ** attempt)
    raise UpdateError("GitHub API retry limit reached")


def stable_releases():
    eligible = set()
    for page in range(1, 101):
        batch = github_json(f"/releases?per_page=100&page={page}")
        if not isinstance(batch, list):
            raise UpdateError("GitHub releases response is malformed")
        for release in batch:
            if (not isinstance(release, dict)
                    or type(release.get("draft")) is not bool
                    or type(release.get("prerelease")) is not bool
                    or not isinstance(release.get("tag_name"), str)):
                raise UpdateError("Malformed GitHub release record")
            match = TAG_RE.fullmatch(release["tag_name"])
            if match and not release["draft"] and not release["prerelease"]:
                eligible.add((tuple(map(int, match.groups())), release["tag_name"]))
        if len(batch) < 100:
            break
    else:
        raise UpdateError("Release pagination limit reached")
    if not eligible:
        raise UpdateError("No stable StoryForge releases found")
    return sorted(eligible, reverse=True)


def resolve_tag(tag):
    data = github_json("/commits/" + urllib.parse.quote(tag, safe=""))
    sha = data.get("sha") if isinstance(data, dict) else None
    if not isinstance(sha, str) or not SHA_RE.fullmatch(sha):
        raise UpdateError(f"Invalid commit SHA for {tag}")
    return sha


def is_ancestor(older, newer):
    result = github_json(f"/compare/{older}...{newer}")
    status = result.get("status") if isinstance(result, dict) else None
    if status not in ("ahead", "identical", "behind", "diverged"):
        raise UpdateError("Malformed/unknown ancestry response")
    return status in ("ahead", "identical")


def version_tuple(value):
    match = re.fullmatch(r"(\d+)\.(\d+)\.(\d+)", str(value))
    if not match:
        raise UpdateError(f"Invalid version: {value!r}")
    return tuple(map(int, match.groups()))


def select_candidate(meta):
    releases = stable_releases()
    if meta["mode"] == "release" and resolve_tag(meta["releaseTag"]) != meta["rev"]:
        raise UpdateError(f"Recorded release tag was retagged: {meta['releaseTag']}")
    for version, tag in releases:
        if version <= version_tuple(meta["version"]):
            continue
        sha = resolve_tag(tag)
        if not is_ancestor(meta["rev"], sha) or sha == meta["rev"]:
            raise UpdateError(f"Release {tag} is not a newer descendant of the accepted source")
        return {"version": ".".join(map(str, version)), "rev": sha,
                "mode": "release", "releaseTag": tag}
    return None


def valid_sri(value):
    if not isinstance(value, str) or not re.fullmatch(r"sha256-[A-Za-z0-9+/]{43}=", value):
        return False
    return len(base64.b64decode(value[7:], validate=True)) == 32


def prefetch(rev):
    url = f"https://github.com/LovelessCodes/StoryForge/archive/{rev}.tar.gz"
    result = json.loads(run(["nix", "store", "prefetch-file", "--json", "--unpack", url]))
    # Nix and Lix versions use storePath; accept the alternative path field too.
    path = result.get("storePath", result.get("path"))
    if (not isinstance(path, str) or not path.startswith("/nix/store/")
            or not Path(path).is_dir() or not valid_sri(result.get("hash"))):
        raise UpdateError("Prefetch did not return an unpacked store path and SHA-256 hash")
    return Path(path), result["hash"]


def source_file(source, relative):
    path = source / relative
    if not path.is_file() or not path.resolve().is_relative_to(source.resolve()):
        raise UpdateError(f"Source file is absent or escapes the snapshot: {relative}")
    return path


def locate_snapshot(path):
    if (path / "package.json").is_file() and (path / "bun.lock").is_file():
        return path
    children = [p for p in path.iterdir() if p.is_dir() and not p.is_symlink()
                and (p / "package.json").is_file() and (p / "bun.lock").is_file()]
    if len(children) != 1:
        raise UpdateError("Source archive has an unknown/ambiguous layout")
    return children[0]


def validate_source(source, version):
    package = json.loads(source_file(source, "package.json").read_text())
    tauri = tomllib.loads(source_file(source, "src-tauri/Cargo.toml").read_text())
    conf = json.loads(source_file(source, "src-tauri/tauri.conf.json").read_text())
    source_file(source, "bun.lock")
    lock_bytes = source_file(source, "src-tauri/Cargo.lock").read_bytes()
    lock = tomllib.loads(lock_bytes.decode("utf-8"))
    for label, value in (("package.json", package.get("version")),
                         ("Cargo.toml", tauri.get("package", {}).get("version")),
                         ("tauri.conf.json", conf.get("version"))):
        if value != version:
            raise UpdateError(f"Source version mismatch: {label} has {value!r}, expected {version}")
    roots = [p for p in lock.get("package", []) if p.get("name") == "StoryForge" and "source" not in p]
    if len(roots) != 1 or roots[0].get("version") != version:
        raise UpdateError("Cargo.lock workspace package does not match source version")
    if any(str(p.get("source", "")).startswith("git+") for p in lock.get("package", [])):
        raise UpdateError("Cargo.lock contains Git dependencies; reviewed outputHashes are required")
    return lock_bytes


def validate_bun(stage, source, pin):
    lock = compatibility.parse_jsonc(source_file(source, "bun.lock").read_text())
    packages = lock.get("packages")
    if not isinstance(packages, dict) or not packages:
        raise UpdateError("Unsupported or empty Bun packages schema")
    expected = set()
    for record in packages.values():
        if not isinstance(record, list) or not record or not isinstance(record[0], str):
            raise UpdateError("Unsupported Bun package record")
        expected.add(record[0])
    tool = f"github:nix-community/bun2nix/{pin['rev']}"
    # Check that the generator flake's source matches the shared reviewed pin.
    metadata = json.loads(run(["nix", "flake", "metadata", "--json", "--no-write-lock-file", tool]))
    if metadata.get("locked", {}).get("narHash") != pin["hash"]:
        raise UpdateError("Generator source hash differs from the reviewed adapter pin")
    output = stage / "bun.nix"
    run(["nix", "run", "--no-write-lock-file", tool + "#bun2nix", "--",
         "-l", str(source / "bun.lock"), "-o", str(output)])
    if not output.is_file() or not output.stat().st_size:
        raise UpdateError("Generator produced no manifest")
    expression = f'''builtins.attrNames (import (builtins.toPath {json.dumps(str(output))}) {{
      copyPathToStore = x: x; fetchFromGitHub = x: x; fetchgit = x: x; fetchurl = x: x;
    }})'''
    actual = set(json.loads(run(["nix", "eval", "--json", "--impure", "--expr", expression,
                                "--option", "allow-import-from-derivation", "false"])))
    if actual != expected:
        raise UpdateError(f"Generated Bun manifest differs from lock: missing={sorted(expected - actual)}, "
                          f"extra={sorted(actual - expected)}")


def validate_evaluation(stage, candidate):
    expression = f'''let
      flake = builtins.getFlake {json.dumps(str(REPOSITORY))};
      pkgs = import flake.inputs.nixpkgs {{ system = "x86_64-linux"; config.allowUnfree = true; }};
      p = pkgs.callPackage (builtins.toPath {json.dumps(str(stage))}) {{ }};
    in {{ version = p.version; drvPath = p.drvPath; }}'''
    result = json.loads(run(["nix", "eval", "--json", "--impure", "--expr", expression,
                             "--option", "allow-import-from-derivation", "false"]))
    if (result.get("version") != candidate["version"]
            or not re.fullmatch(r"/nix/store/[a-z0-9]{32}-.+\.drv", result.get("drvPath", ""))):
        raise UpdateError("Staged package evaluation returned an unexpected version/derivation")


def load_metadata():
    meta = json.loads((PACKAGE / "source.json").read_text())
    pin = json.loads((PACKAGE / "bun2nix-pin.json").read_text())
    required = {"version", "rev", "hash", "mode", "releaseTag"}
    if (not isinstance(meta, dict) or set(meta) != required or meta["mode"] not in ("snapshot", "release")
            or not isinstance(meta["rev"], str) or not SHA_RE.fullmatch(meta["rev"])
            or not valid_sri(meta["hash"])):
        raise UpdateError("Invalid source.json")
    version_tuple(meta["version"])
    if meta["mode"] == "snapshot" and meta["releaseTag"] is not None:
        raise UpdateError("Snapshot must have null releaseTag")
    if meta["mode"] == "release":
        tag = TAG_RE.fullmatch(str(meta["releaseTag"]))
        if not tag or tuple(map(int, tag.groups())) != version_tuple(meta["version"]):
            raise UpdateError("Recorded release tag does not match version")
    if (not isinstance(pin, dict) or set(pin) != {"version", "rev", "hash"}
            or pin["version"] != "2.1.2" or pin["rev"] != "0456acb1b7394fc14c414b056aa889df5124943a"
            or pin["hash"] != "sha256-8HmRrSjDKZNl9KC0fms3QMtDJlO/OssK4cZw7VrllcA="):
        raise UpdateError("Tool pin differs from the reviewed vendored adapter")
    return meta, pin


def _atomic_write(path, contents, mode=0o644):
    fd, temp_name = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(fd, "wb") as stream:
            stream.write(contents)
        os.chmod(temp_name, mode)
        os.replace(temp_name, path)
    finally:
        Path(temp_name).unlink(missing_ok=True)


def publish(stage, new_meta, digest=None):
    (stage / "source.json").write_text(json.dumps(new_meta, indent=2) + "\n")
    backup = {name: ((PACKAGE / name).read_bytes(), (PACKAGE / name).stat().st_mode & 0o777)
              if (PACKAGE / name).exists() else None for name in PUBLISH}
    try:
        for name in PUBLISH:
            _atomic_write(PACKAGE / name, (stage / name).read_bytes())
    except BaseException:
        for name, old in backup.items():
            if old is None:
                (PACKAGE / name).unlink(missing_ok=True)
            else:
                _atomic_write(PACKAGE / name, *old)
        raise


def update(check=False):
    meta, pin = load_metadata()
    candidate = select_candidate(meta)
    if candidate is None:
        return {"status": "up-to-date", "version": meta["version"], "rev": meta["rev"]}
    if check:
        return {"status": "update-available", **candidate}
    original, digest = prefetch(candidate["rev"])
    source = locate_snapshot(original)
    lock_bytes = validate_source(source, candidate["version"])
    # Cheap compatibility validation comes before a potentially uncached tool build.
    plan = compatibility.make_plan(source)
    compatibility.apply_plan(source, plan, check_only=True)
    new_meta = {**candidate, "hash": digest}
    with tempfile.TemporaryDirectory(prefix="storyforge-update-") as temp:
        stage = Path(temp) / "package"
        shutil.copytree(PACKAGE, stage, ignore=shutil.ignore_patterns("__pycache__"))
        (stage / "source.json").write_text(json.dumps(new_meta, indent=2) + "\n")
        (stage / "Cargo.lock").write_bytes(lock_bytes)
        (stage / "compatibility.json").write_text(json.dumps(plan, indent=2) + "\n")
        validate_bun(stage, source, pin)
        validate_evaluation(stage, candidate)
        if (stage / "Cargo.lock").read_bytes() != lock_bytes:
            raise UpdateError("Staged Cargo.lock was changed unexpectedly")
        publish(stage, new_meta)
    return {"status": "updated", "version": candidate["version"], "rev": candidate["rev"]}


def verify_current():
    """Exercise prefetch, generator and evaluation without publishing any files."""
    meta, pin = load_metadata()
    original, digest = prefetch(meta["rev"])
    if digest != meta["hash"]:
        raise UpdateError("Current immutable source hash changed")
    source = locate_snapshot(original)
    lock_bytes = validate_source(source, meta["version"])
    plan = compatibility.make_plan(source)
    if lock_bytes != (PACKAGE / "Cargo.lock").read_bytes():
        raise UpdateError("Checked-in Cargo.lock differs from its source")
    if plan != json.loads((PACKAGE / "compatibility.json").read_text()):
        raise UpdateError("Checked-in compatibility plan differs from its source")
    with tempfile.TemporaryDirectory(prefix="storyforge-verify-") as temp:
        stage = Path(temp) / "package"
        shutil.copytree(PACKAGE, stage, ignore=shutil.ignore_patterns("__pycache__"))
        validate_bun(stage, source, pin)
        if (stage / "bun.nix").read_bytes() != (PACKAGE / "bun.nix").read_bytes():
            raise UpdateError("Regenerated bun.nix differs; review the generated manifest")
        validate_evaluation(stage, meta)
    return {"status": "verified", "version": meta["version"], "rev": meta["rev"]}


def _interrupted(signum, _frame):
    raise UpdateError(f"Interrupted by signal {signum}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--check", action="store_true", help="select a release without downloads or writes")
    mode.add_argument("--verify-current", action="store_true",
                      help="regenerate the current dependency manifest and evaluate it without changing files")
    args = parser.parse_args()
    for signum in (signal.SIGTERM, signal.SIGHUP):
        signal.signal(signum, _interrupted)
    try:
        result = verify_current() if args.verify_current else update(check=args.check)
        print(json.dumps(result, sort_keys=True))
        return 0
    except (UpdateError, OSError, ValueError, KeyError, TypeError, KeyboardInterrupt) as exc:
        print("storyforge updater: " + _redact(str(exc)), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
