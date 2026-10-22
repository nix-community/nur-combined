#!/usr/bin/env python3
"""Update one independent CachyOS source.json from immutable upstream Git refs."""
import argparse
import base64
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

KERNEL_REPO = "https://github.com/CachyOS/linux-cachyos.git"
PATCH_REPO = "https://github.com/CachyOS/kernel-patches.git"
KERNEL_RAW = "https://raw.githubusercontent.com/CachyOS/linux-cachyos"
PATCH_RAW = "https://raw.githubusercontent.com/CachyOS/kernel-patches"
RELEASE = "https://github.com/CachyOS/linux/releases/download/{srcname}/{srcname}.tar.gz"
FIELDS = ("version", "url", "hash", "configUrl", "configHash", "patchRev", "patchVersion", "patchHash")


def run(*args, input_text=None, cwd=None):
    result = subprocess.run(args, check=True, capture_output=True, text=True, input=input_text, cwd=cwd)
    return result.stdout.strip()


def curl_bytes(url):
    return subprocess.run(["curl", "--fail", "--silent", "--show-error", "--location", "--max-time", "30", url],
                          check=True, capture_output=True).stdout


def assert_url(url):
    # Follow release redirects but only request headers; do not download kernel archives in --check.
    result = subprocess.run(["curl", "--fail", "--silent", "--show-error", "--location", "--head", "--max-time", "30", url],
                            capture_output=True, text=True)
    if result.returncode:
        raise RuntimeError(f"upstream asset unavailable: {url}: {result.stderr.strip()}")


def valid_hash(value):
    if not isinstance(value, str) or not re.fullmatch(r"sha256-[A-Za-z0-9+/]{43}=", value):
        raise ValueError(f"malformed SRI SHA-256 hash: {value!r}")
    decoded = base64.b64decode(value[7:], validate=True)
    if len(decoded) != 32 or base64.b64encode(decoded).decode() != value[7:]:
        raise ValueError(f"noncanonical SRI SHA-256 hash: {value!r}")


def version_key(value):
    if not isinstance(value, str) or not re.fullmatch(r"\d+(?:\.\d+)*", value):
        raise ValueError(f"malformed numeric kernel version: {value!r}")
    parts = list(map(int, value.split(".")))
    while len(parts) > 1 and parts[-1] == 0:
        parts.pop()
    return tuple(parts)


def git_head(repo):
    lines = run("git", "ls-remote", repo, "HEAD").splitlines()
    if len(lines) != 1:
        raise ValueError(f"expected one HEAD ref from {repo}, got {lines!r}")
    rev, ref = lines[0].split("\t", 1)
    if ref != "HEAD" or not re.fullmatch(r"[0-9a-f]{40}", rev):
        raise ValueError(f"unexpected ls-remote response from {repo}: {lines[0]!r}")
    return rev


def parse_pkgbuild(text):
    """Interpret only known literal PKGBUILD version assignments; never execute shell."""
    values = {}
    for name in ("_major", "_minor", "_tagrel"):
        matches = re.findall(rf"^{name}=([0-9]+(?:\.[0-9]+)*)\s*$", text, re.M)
        if len(matches) != 1:
            raise ValueError(f"PKGBUILD must define one literal {name}=numeric value")
        values[name] = matches[0]
    major, minor, tagrel = values["_major"], values["_minor"], values["_tagrel"]
    if "." in minor or "." in tagrel:
        raise ValueError("PKGBUILD _minor and _tagrel must be integers")
    version = f"{major}.{minor}"
    version_key(version)
    expected_srcname = f"cachyos-{version}-{tagrel}"
    src_matches = re.findall(r"^_srcname=(.*)$", text, re.M)
    if len(src_matches) != 1:
        raise ValueError("PKGBUILD must define exactly one _srcname")
    expr = src_matches[0].strip().strip("\"").strip("'")
    allowed = {
        "cachyos-${_major}.${_minor}-${_tagrel}": expected_srcname,
        expected_srcname: expected_srcname,
    }
    srcname = allowed.get(expr)
    if srcname is None:
        raise ValueError(f"unsupported _srcname expression: {expr!r}")
    return version, srcname


def resolve_metadata(variant):
    package = "linux-cachyos" if variant == "latest" else "linux-cachyos-bore"
    # Resolve current repository heads once; the PKGBUILD and config are pinned to
    # the same linux-cachyos commit, while patches use their independent repo HEAD.
    config_rev = git_head(KERNEL_REPO)
    patch_rev = git_head(PATCH_REPO)
    build_url = f"{KERNEL_RAW}/{config_rev}/{package}/PKGBUILD"
    build = curl_bytes(build_url).decode("utf-8")
    version, srcname = parse_pkgbuild(build)
    release_url = RELEASE.format(srcname=srcname)
    assert_url(release_url)
    config_url = f"{KERNEL_RAW}/{config_rev}/{package}/config"
    config_data = curl_bytes(config_url)
    patch_version = ".".join(version.split(".")[:2])
    patch_path = f"{PATCH_RAW}/{patch_rev}/{patch_version}/sched/0001-bore-cachy.patch"
    # Ensure the filtered patch root contains the variant-specific patch before pinning it.
    if variant == "bore":
        curl_bytes(patch_path)
    return {"version": version, "url": release_url, "configUrl": config_url,
            "configRev": config_rev, "configData": config_data,
            "patchRev": patch_rev, "patchVersion": patch_version,
            "srcname": srcname}


def prefetch_url(url):
    data = json.loads(run("nix", "store", "prefetch-file", "--hash-type", "sha256", "--json", url))
    value = data.get("hash")
    valid_hash(value)
    return value


def prefetch_git_root(rev, root_dir):
    output = run("nix-prefetch-git", "--url", PATCH_REPO, "--rev", rev,
                 "--root-dir", root_dir, "--quiet")
    data = json.loads(output)
    value = data.get("hash") or data.get("sha256")
    if isinstance(value, str) and re.fullmatch(r"sha256-[A-Za-z0-9+/]{43}=", value):
        return value
    if not isinstance(value, str) or not value:
        raise ValueError("nix-prefetch-git returned no hash")
    sri = run("nix", "hash", "to-sri", "--type", "sha256", value)
    valid_hash(sri)
    return sri


def candidate_hashes(meta):
    meta["hash"] = prefetch_url(meta["url"])
    # Hash precisely the already-resolved immutable config bytes with Nix's fetchurl hash semantics.
    # We retain its URL for the builder, and independently verify that the URL still serves those bytes.
    if curl_bytes(meta["configUrl"]) != meta["configData"]:
        raise ValueError("immutable config content changed during update")
    meta["configHash"] = prefetch_url(meta["configUrl"])
    meta["patchHash"] = prefetch_git_root(meta["patchRev"], meta["patchVersion"] + "/")
    return {key: meta[key] for key in FIELDS}


def check_schema(current, variant=None):
    if not isinstance(current, dict) or set(current) != set(FIELDS):
        raise ValueError(f"source.json fields must be exactly {FIELDS}; got {sorted(current) if isinstance(current, dict) else type(current).__name__}")
    for key in ("hash", "configHash", "patchHash"):
        valid_hash(current[key])
    version_key(current["version"])
    if not re.fullmatch(r"[0-9a-f]{40}", current["patchRev"]):
        raise ValueError("malformed patchRev")
    release_pattern = (r"https://github\.com/CachyOS/linux/releases/download/(?P<tag>cachyos-"
                       + re.escape(current["version"]) + r"-\d+)/(?P=tag)\.tar\.gz")
    if not re.fullmatch(release_pattern, current["url"]):
        raise ValueError("source archive URL does not identify this CachyOS/linux version")
    expected_variant = {"latest": "linux-cachyos", "bore": "linux-cachyos-bore"}.get(variant)
    config_pattern = rf"{re.escape(KERNEL_RAW)}/[0-9a-f]{{40}}/(linux-cachyos|linux-cachyos-bore)/config"
    if not re.fullmatch(config_pattern, current["configUrl"]):
        raise ValueError("config URL is outside pinned CachyOS/linux-cachyos config paths")
    if expected_variant and not current["configUrl"].endswith(f"/{expected_variant}/config"):
        raise ValueError("config URL does not match selected kernel variant")
    expected_patch_version = ".".join(current["version"].split(".")[:2])
    if current["patchVersion"] != expected_patch_version:
        raise ValueError("patchVersion does not match kernel major.minor")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("package_dir", type=Path)
    parser.add_argument("variant", choices=("latest", "bore"))
    parser.add_argument("--check", action="store_true", help="resolve live refs and release availability without prefetch or writes")
    args = parser.parse_args()
    expected_package = "linux-cachyos-latest-x86_64-v3" if args.variant == "latest" else "linux-cachyos-bore-x86_64-v3"
    package_dir = args.package_dir.resolve()
    if package_dir.name != expected_package:
        raise ValueError(f"variant {args.variant!r} may update only {expected_package}, not {package_dir.name}")
    source = package_dir / "source.json"
    original = source.read_bytes()
    current = json.loads(original)
    check_schema(current, args.variant)
    meta = resolve_metadata(args.variant)
    resolved = {"configRev": meta["configRev"], "patchRev": meta["patchRev"]}
    if version_key(meta["version"]) <= version_key(current["version"]):
        print(f"{args.variant}: unchanged (pinned {current['version']}, live {meta['version']}; linux-cachyos={resolved['configRev']}, kernel-patches={resolved['patchRev']})")
        return 0
    if args.check:
        print(f"{args.variant}: update available {current['version']} -> {meta['version']}; linux-cachyos={resolved['configRev']}, kernel-patches={resolved['patchRev']}")
        return 0
    temporary = None
    try:
        candidate = candidate_hashes(meta)
        # Enforce source identities after discovery and after hashes are computed.
        check_schema(candidate, args.variant)
        expected = {"version": meta["version"], "url": meta["url"], "configUrl": meta["configUrl"],
                    "patchRev": meta["patchRev"], "patchVersion": meta["patchVersion"]}
        if any(candidate[key] != value for key, value in expected.items()):
            raise ValueError("candidate source identity changed during hash resolution")
        mode = source.stat().st_mode & 0o777
        with tempfile.NamedTemporaryFile("wb", dir=source.parent, delete=False) as f:
            temporary = Path(f.name)
            f.write((json.dumps(candidate, indent=2, sort_keys=True) + "\n").encode())
            f.flush()
            os.fchmod(f.fileno(), mode)
        os.replace(temporary, source)
        temporary = None
        package = source.parent.name
        evaluated = run("nix", "eval", "--raw", "--no-write-lock-file", f".#packages.x86_64-linux.{package}.version",
                        cwd=package_dir.parents[1])
        if evaluated != candidate["version"]:
            raise ValueError(f"evaluated version {evaluated!r} != candidate {candidate['version']!r}")
    except BaseException:
        source.write_bytes(original)
        raise
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)
    print(f"{source.parent.name}: {current['version']} -> {candidate['version']}")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as exc:
        print(f"CachyOS updater: {exc}", file=sys.stderr)
        sys.exit(1)
