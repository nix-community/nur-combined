#!/usr/bin/env python3
"""Update one independent package or one group of version-coupled inputs."""

import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tarfile
import tempfile
import urllib.error
import urllib.parse
import urllib.request


def run(*args, **kwargs):
    return subprocess.check_output(args, text=True, **kwargs).strip()


def fetch_json(url, optional=False):
    request = urllib.request.Request(url, headers={"User-Agent": "nur-packages-updater"})
    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    if token and url.startswith("https://api.github.com/"):
        request.add_header("Authorization", f"Bearer {token}")
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        if optional and error.code == 404:
            return None
        raise


def stable_release(repo):
    return fetch_json(f"https://api.github.com/repos/{repo}/releases/latest", optional=True)


def stable_ref(repo):
    release = stable_release(repo)
    if release:
        return release
    tags = fetch_json(f"https://api.github.com/repos/{repo}/tags?per_page=100")
    stable = [tag["name"] for tag in tags if re.fullmatch(r"v?\d+\.\d+\.\d+", tag["name"])]
    if not stable:
        return None
    tag = max(stable, key=lambda value: tuple(map(int, value.removeprefix("v").split("."))))
    return {"tag_name": tag}


def source_revision(repo, minimum_revision=None):
    release = stable_ref(repo)
    api = f"https://api.github.com/repos/{repo}"

    def commit_at(ref):
        return fetch_json(f"{api}/commits/{urllib.parse.quote(ref, safe='')}")

    def preserves_current(commit):
        if minimum_revision is None or commit["sha"] == minimum_revision:
            return True
        comparison = fetch_json(f"{api}/compare/{minimum_revision}...{commit['sha']}")
        return comparison["status"] in ("ahead", "identical")

    branch = None if release else fetch_json(api)["default_branch"]
    commit = commit_at(release["tag_name"] if release else branch)
    if not preserves_current(commit):
        if release:
            # An old stable tag must not discard fixes already in our source.
            release = None
            branch = fetch_json(api)["default_branch"]
            commit = commit_at(branch)
        if not preserves_current(commit):
            # Also protect against a default-branch force push or rollback.
            commit = commit_at(minimum_revision)
    return commit["sha"], release, commit["commit"]["committer"]["date"][:10]


def replace_once(text, pattern, replacement):
    result, count = re.subn(pattern, replacement, text, count=1, flags=re.MULTILINE)
    if count != 1:
        raise ValueError(f"Expected one update site for {pattern}")
    return result


def update_flake(target):
    path = Path("flake.nix")
    text = path.read_text()
    current = re.search(rf'github:{re.escape(target["repo"])}/([0-9a-f]{{40}})(?=["?])', text)
    revision, _, _ = source_revision(target["repo"], minimum_revision=current[1] if current else None)
    path.write_text(pin_flake_url(text, target["repo"], revision))
    run("nix", "flake", "update", target["input"])
    # Runtime package definitions use checked-in snapshots, not Flake outputs.
    subprocess.run([sys.executable, "scripts/sync-project-inputs.py", "--if-supported", target["input"]], check=True)


def pin_flake_url(text, repo, revision):
    pattern = rf'github:{re.escape(repo)}(?=["/?])(?:/[^"?\s]+)?(?:\?[^"\s]*)?'
    def replace(match):
        query = urllib.parse.parse_qsl(urllib.parse.urlparse(match[0]).query)
        directory = [(key, value) for key, value in query if key == "dir"]
        suffix = "?" + urllib.parse.urlencode(directory) if directory else ""
        return f"github:{repo}/{revision}{suffix}"
    return replace_once(text, pattern, replace)


def update_github_source(target, path, source_name):
    text = path.read_text()
    prefix = re.escape(source_name) + r' = fetchFromGitHub \{[\s\S]*?'
    current = re.search(rf'{prefix}rev = "([^"]+)";', text)
    if current is None:
        raise ValueError(f"Missing pinned revision in {path}: {source_name}")
    revision, release, date = source_revision(target["repo"], minimum_revision=current[1])
    source = json.loads(run("nix", "flake", "prefetch", "--json", f"github:{target['repo']}/{revision}"))
    owner, repo = target["repo"].split("/", 1)
    for field, value in [("owner", owner), ("repo", repo), ("rev", revision), ("hash", source["hash"])]:
        text = replace_once(text, rf'({prefix}{field} = ")[^"]+(";)', rf'\g<1>{value}\2')
    if release or revision != current[1]:
        version = release["tag_name"].removeprefix("v") if release else f"0-unstable-{date}"
        text = replace_once(text, r'(^  version = ")[^"]+(";)', rf'\g<1>{version}\2')
    path.write_text(text)


def update_vtype(target):
    update_github_source(target, Path("pkgs/vtype-linux/default.nix"), "upstreamSrc")


def update_github(target):
    update_github_source(target, Path(f"pkgs/{target['attr']}/default.nix"), "src")


def update_honk(target):
    release = stable_release(target["repo"])
    if release is None:
        releases = fetch_json(f"https://api.github.com/repos/{target['repo']}/releases")
        release = next(entry for entry in releases if not entry["draft"])
    asset = next(asset for asset in release["assets"] if asset["name"] == "honk-core-debug-x86_64-unknown-linux-musl.tar.gz")
    source = json.loads(run("nix", "store", "prefetch-file", "--json", asset["browser_download_url"]))
    path = Path("pkgs/honk/default.nix")
    text = path.read_text()
    version = release["tag_name"].removeprefix("v")
    text = replace_once(text, r'(version = ")[^"]+(";)', rf'\g<1>{version}\2')
    text = replace_once(text, r'(url = ")[^"]+(";)', rf'\g<1>{asset["browser_download_url"]}\2')
    text = replace_once(text, r'    (?:sha256|hash) = "[^"]+";', f'    hash = "{source["hash"]}";')
    path.write_text(text)


def semver_key(version):
    match = re.fullmatch(r"(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z.-]+))?(?:\+[0-9A-Za-z.-]+)?", version)
    if not match:
        raise ValueError(f"Unsupported npm version: {version}")
    prerelease = match[4]
    identifiers = tuple((0, int(part)) if part.isdigit() else (1, part)
                        for part in prerelease.split(".")) if prerelease else ()
    return (*map(int, match.group(1, 2, 3)), prerelease is None, identifiers)


def npm_version(metadata, current_version=None):
    stable = [version for version in metadata["versions"] if re.fullmatch(r"\d+\.\d+\.\d+", version)]
    candidate = max(stable, key=semver_key) if stable else metadata["dist-tags"]["latest"]
    if current_version is not None and semver_key(candidate) < semver_key(current_version):
        # Keep a newer prerelease channel rather than reverting to an old
        # stable release. Never follow a dist-tag backwards either.
        return max([current_version, metadata["dist-tags"]["latest"]], key=semver_key)
    return candidate


def update_cloudflare(target):
    metadata = fetch_json(f"https://registry.npmjs.org/{target['registry']}")
    old_version = run("nix", "eval", "--raw", ".#packages.x86_64-linux.cloudflare-cli.version")
    version = npm_version(metadata, current_version=old_version)
    if old_version == version:
        return
    source = json.loads(run("nix", "store", "prefetch-file", "--json", metadata["versions"][version]["dist"]["tarball"]))
    with tempfile.TemporaryDirectory(prefix="nur-cf-update-") as directory:
        # Read only package.json; do not extract arbitrary archive members.
        with tarfile.open(source["storePath"], "r:gz") as archive:
            package = json.load(archive.extractfile("package/package.json"))
        package.pop("devDependencies", None)
        Path(directory, "package.json").write_text(json.dumps(package, indent=2) + "\n")
        subprocess.run(["npm", "install", "--package-lock-only", "--ignore-scripts", "--omit=dev", "--no-audit", "--no-fund"], cwd=directory, check=True)
        Path("pkgs/cloudflare-cli/package-lock.json").write_text(Path(directory, "package-lock.json").read_text())
    deps_hash = run("prefetch-npm-deps", "pkgs/cloudflare-cli/package-lock.json")
    path = Path("pkgs/cloudflare-cli/default.nix")
    text = path.read_text().replace(f'version = "{old_version}";', f'version = "{version}";', 1)
    text = replace_once(text, r'(url = "https://registry\.npmjs\.org/cf/-/cf-\$\{version\}\.tgz";\s+hash = ")[^"]+(";)', rf'\g<1>{source["hash"]}\2')
    text = replace_once(text, r'(npmDepsHash = ")[^"]+(";)', rf'\g<1>{deps_hash}\2')
    path.write_text(text)


def update_package(target):
    metadata = json.loads(run("nix", "eval", "--json", f".#packages.x86_64-linux.{target['attr']}", "--apply",
        'p: { urls = p.src.urls or []; homepage = p.meta.homepage or ""; }'))
    urls = metadata["urls"]
    registry = next((urllib.parse.unquote(urllib.parse.urlparse(url).path.split("/-/")[0].lstrip("/"))
        for url in urls if url.startswith("https://registry.npmjs.org/")), None)
    github = next((re.match(r"https://github\.com/([^/]+/[^/]+)", url)
        for url in [*urls, metadata["homepage"]] if re.match(r"https://github\.com/([^/]+/[^/]+)", url)), None)
    policy = "stable"
    if registry:
        metadata = fetch_json(f"https://registry.npmjs.org/{urllib.parse.quote(registry, safe='')}")
        policy = "stable" if any(re.fullmatch(r"\d+\.\d+\.\d+", version) for version in metadata["versions"]) else "unstable"
    elif github and not stable_ref(github[1]):
        policy = "unstable" if any("/releases/download/" in url for url in urls) else "branch"
    subprocess.run(["nix-update", "--flake", target["attr"], f"--version={policy}"], check=True)


def discover_targets(root=Path(".")):
    lock = json.loads((root / "flake.lock").read_text())
    targets = {}
    for name, node_name in lock["nodes"][lock["root"]]["inputs"].items():
        if not isinstance(node_name, str):
            continue
        original = lock["nodes"][node_name]["original"]
        if original["type"] == "github":
            targets[name] = {"kind": "flake", "input": name, "repo": f"{original['owner']}/{original['repo']}"}
        else:
            targets[name] = {"kind": "lock", "input": name}
    aliases = []
    for recipe in sorted((root / "pkgs").glob("*/default.nix")):
        name = recipe.parent.name
        metadata_file = recipe.parent / "update.json"
        metadata = json.loads(metadata_file.read_text()) if metadata_file.exists() else {}
        update_group = metadata.pop("group", None)
        group = update_group or name
        if update_group is not None:
            aliases.append((name, group))
            continue
        if group in targets:
            raise ValueError(f"Package and input update groups collide: {group}")
        targets[group] = {"kind": "package", "attr": name, **metadata}
    for name, group in aliases:
        if group not in targets:
            raise ValueError(f"Unknown update group {group} for {name}")
    return targets


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("target", nargs="?")
    parser.add_argument("--list", action="store_true")
    args = parser.parse_args()
    targets = discover_targets()
    if args.list:
        print(json.dumps({"include": [{"name": name} for name in targets]}))
        return
    if args.target not in targets:
        parser.error("Specify a target from --list")
    before = {path: path.read_bytes() for path in [Path("flake.nix"), *Path("pkgs").rglob("*.nix"), *Path("nixos-modules").rglob("*.nix")]}
    target = targets[args.target]
    handlers = {"flake": update_flake, "github": update_github, "vtype": update_vtype, "honk": update_honk, "cloudflare": update_cloudflare, "package": update_package}
    if target["kind"] == "lock":
        run("nix", "flake", "update", target["input"])
    else:
        handlers[target["kind"]](target)
    changed = [str(path) for path, content in before.items() if path.read_bytes() != content]
    if changed:
        subprocess.run(["nixpkgs-fmt", *changed], check=True)


if __name__ == "__main__":
    main()
