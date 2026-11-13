#!/usr/bin/env python3
"""Update pinned NUR packages.

Regular packages go through nix-update. Binary packages select a GitHub
Release asset and rewrite the version and hash pins. One package failure does
not stop the rest; the process exits nonzero after the full set.
"""

import argparse
import json
import os
import re
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

SYSTEMS = ("x86_64-linux", "aarch64-linux")
VERSION_RE = re.compile(r"^[0-9][0-9A-Za-z._+-]*$")
GPUI_VERSION_RE = re.compile(r"^2\.0\.0-preview\.[0-9]+$")
FRIDA_VERSION_RE = re.compile(r"^[0-9]+\.[0-9]+\.[0-9]+$")
SHA256_DIGEST_RE = re.compile(r"^sha256:[0-9a-f]+$")
NIX_STRING_RE = re.compile(r'^[0-9A-Za-z._+/=-]+$')

# `nix run .#update` copies this file into the store, so __file__ is not inside
# the checkout. Updates must rewrite the caller's working tree.
REPO_ROOT = Path(os.environ.get("NUR_PACKAGES_ROOT") or Path.cwd()).resolve()

NIX_UPDATE_ARGS = {
    "neu-cli": ["--version=branch"],
    "modeltrace": ["--version=branch"],
    "quarkpan": ["--version=branch"],
    "rea": ["--format", "--use-github-releases", "--version-regex", "rea-agents-(.*)"],
}

BINARY_PACKAGES = {
    "folia-major-bin": {
        "repo": "chthollyphile/folia-major",
        "source": "pkgs/apps/folia-major/sources/{system}.nix",
        "systems": ("x86_64-linux",),
        "asset": lambda version, system: f"folia-major-{version}-linux-x64.tar.gz",
    },
    "meatshell-bin": {
        "repo": "yituorou/meatshell",
        "source": "pkgs/apps/meatshell/sources/{system}.nix",
        "asset": lambda version, system: (
            f"meatshell-v{version}-linux-aarch64.tar.gz"
            if system == "aarch64-linux"
            else f"meatshell-v{version}-linux-x86_64.AppImage"
        ),
    },
    "neomacs-bin": {
        "repo": "eval-exec/neomacs",
        "source": "pkgs/apps/neomacs/sources/{system}.nix",
        "asset": lambda version, system: (
            f"neomacs-{version}-"
            f"{'aarch64' if system == 'aarch64-linux' else 'x86_64'}-unknown-linux-gnu.tar.gz"
        ),
    },
    "nyaterm-bin": {
        "repo": "nyakang/nyaterm",
        "source": "pkgs/apps/nyaterm/sources/{system}.nix",
        "asset": lambda version, system: (
            f"NyaTerm_{version}_linux_{'arm64' if system == 'aarch64-linux' else 'x64'}.AppImage"
        ),
    },
    "nyaterm-gpui-bin": {
        "repo": "nyakang/nyaterm",
        "source": "pkgs/apps/nyaterm-gpui/sources/{system}.nix",
        "release": "preview",
        "version_re": GPUI_VERSION_RE,
        "asset": lambda version, system: (
            f"NyaTerm_{version}_linux_{'arm64' if system == 'aarch64-linux' else 'x64'}.AppImage"
        ),
    },
    "qrypt-bin": {
        "repo": "yinzhenyu-su/qrypt",
        "source": "pkgs/tools/qrypt/sources/{system}.nix",
        "asset": lambda version, system: (
            f"qrypt_{version}_linux_{'arm64' if system == 'aarch64-linux' else 'amd64'}.tar.gz"
        ),
    },
}

CRAFT_APPS = (
    "artcraft-launcher",
    "cadcraft",
    "deckcraft",
    "designcraft",
    "effectcraft",
    "figcraft",
    "filmcraft",
    "gridcraft",
    "lightcraft",
    "pdfcraft",
    "photocraft",
    "soundcraft",
    "vectorcraft",
    "wordcraft",
)

DEFAULT_PACKAGES = [
    "amber-lsp",
    "code996",
    "craft-suite-bin",
    "dnspick",
    "folia-major-bin",
    "ghost-downloader-3",
    "ipgw",
    "kuake-cli",
    "meatshell-bin",
    "modeltrace",
    "neomacs-bin",
    "neu-cli",
    "nyaterm-bin",
    "nyaterm-gpui-bin",
    "oh-dsh-bin",
    "qrypt-bin",
    "quarkpan",
    "quien",
    "rea",
    "seekey",
    "uipro-cli",
    "winpodx-bin",
    "zlib-cli",
]


class UpdateError(Exception):
    pass


def run(command, **kwargs):
    result = subprocess.run(command, text=True, **kwargs)
    if result.returncode != 0:
        detail = (result.stderr or result.stdout or "").strip()
        message = f"command failed ({result.returncode}): {' '.join(command)}"
        if detail:
            message = f"{message}\n{detail}"
        raise UpdateError(message)
    return result


def github_json(url):
    headers = {"User-Agent": "nur-packages-update"}
    if urllib.parse.urlparse(url).netloc == "api.github.com":
        headers["Accept"] = "application/vnd.github+json"
    request = urllib.request.Request(url, headers=headers)
    token = os.environ.get("GITHUB_TOKEN")
    if token:
        request.add_header("Authorization", f"Bearer {token}")
    last_error = None
    for attempt in range(5):
        try:
            with urllib.request.urlopen(request, timeout=60) as response:
                return json.load(response)
        except urllib.error.HTTPError as error:
            last_error = UpdateError(f"GitHub API {error.code} for {url}")
            if error.code < 500 and error.code != 429:
                break
        except urllib.error.URLError as error:
            last_error = UpdateError(f"GitHub API request failed for {url}: {error.reason}")
        if attempt < 4:
            time.sleep(2 * (2**attempt))
    raise last_error


def latest_release(repo):
    return github_json(f"https://api.github.com/repos/{repo}/releases/latest")


def release_version(release, version_re=VERSION_RE):
    tag = release.get("tag_name", "")
    version = tag[1:] if tag.startswith("v") else tag
    if version_re.fullmatch(version) is None:
        raise UpdateError(f"invalid release version: {version}")
    return version


def gpui_release(repo):
    releases = github_json(f"https://api.github.com/repos/{repo}/releases?per_page=30")
    matches = []
    for release in releases:
        tag = release.get("tag_name", "")
        version = tag[1:] if tag.startswith("v") else tag
        match = GPUI_VERSION_RE.fullmatch(version)
        if match:
            matches.append((int(version.rsplit(".", 1)[1]), release))
    if not matches:
        raise UpdateError(f"no GPUI preview release found in {repo}")
    return max(matches)[1]


def asset_record(release, name):
    for asset in release.get("assets", []):
        if asset.get("name") == name:
            return asset
    raise UpdateError(f"release asset not found: {name}")


def sri_hash(digest, url):
    if digest:
        if SHA256_DIGEST_RE.fullmatch(digest) is None:
            raise UpdateError(f"invalid release digest: {digest}")
        result = run(
            ["nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", digest.removeprefix("sha256:")],
            capture_output=True,
        )
        return result.stdout.strip()
    result = run(["nix", "store", "prefetch-file", "--json", url], capture_output=True)
    try:
        return json.loads(result.stdout)["hash"]
    except (json.JSONDecodeError, KeyError) as error:
        raise UpdateError(f"nix prefetch returned no hash for {url}") from error


def replace_nix_string(path, name, value):
    if NIX_STRING_RE.fullmatch(value) is None:
        raise UpdateError(f"refusing to write unsafe {name}: {value}")
    pattern = re.compile(rf'^(  {re.escape(name)} = )".*";$')
    lines = path.read_text().splitlines(keepends=True)
    replaced = False
    for index, line in enumerate(lines):
        match = pattern.fullmatch(line.rstrip("\n"))
        if match:
            lines[index] = f'{match.group(1)}"{value}";\n'
            replaced = True
            break
    if not replaced:
        raise UpdateError(f"{name} assignment not found in {path}")
    path.write_text("".join(lines))


def current_system():
    result = run(
        ["nix", "eval", "--impure", "--raw", "--expr", "builtins.currentSystem"],
        capture_output=True,
    )
    return result.stdout.strip()


def validate_package(package, system):
    flake = f"path:{REPO_ROOT}"
    run(["nix", "eval", "--raw", f"{flake}#packages.{system}.{package}.drvPath"], stdout=subprocess.DEVNULL)
    native = current_system()
    if system == native:
        run(["nix", "build", f"{flake}#packages.{system}.{package}", "--no-link"])
    else:
        print(f"Skipping build for non-native system {system} on {native}", flush=True)


def update_nix_package(package):
    print(f"==> Updating {package}", flush=True)
    command = ["nix-update", package, "--flake", "--build", "--format"]
    extra = NIX_UPDATE_ARGS.get(package, ["--use-github-releases"])
    if package == "rea":
        command = ["nix-update", package, "--flake", *extra]
    else:
        command.extend(extra)
    run(command, cwd=REPO_ROOT)


def update_binary_package(package, system):
    spec = BINARY_PACKAGES[package]
    systems = spec.get("systems", SYSTEMS)
    if system not in systems:
        raise UpdateError(f"unsupported architecture: {system}")
    print(f"==> Updating {package} for {system}", flush=True)
    if spec.get("release") == "preview":
        release = gpui_release(spec["repo"])
    else:
        release = latest_release(spec["repo"])
    version = release_version(release, spec.get("version_re", VERSION_RE))
    name = spec["asset"](version, system)
    asset = asset_record(release, name)
    url = asset.get("browser_download_url")
    if not url:
        raise UpdateError(f"release asset has no download URL: {name}")
    digest = asset.get("digest") or ""
    replace_nix_string(REPO_ROOT / spec["source"].format(system=system), "version", version)
    replace_nix_string(
        REPO_ROOT / spec["source"].format(system=system),
        "hash",
        sri_hash(digest, url),
    )
    print(f"Updated {package} for {system} to {version}", flush=True)
    validate_package(package, system)


def craft_repo(app):
    return "craft-launcher" if app == "artcraft-launcher" else app


def update_craft_suite(system, app=None):
    if system not in SYSTEMS:
        raise UpdateError(f"unsupported architecture: {system}")
    if app is not None and app not in CRAFT_APPS:
        raise UpdateError(f"unknown Craft app: {app}")
    label = f"{app}-bin" if app else "craft-suite-bin"
    print(f"==> Updating {label} for {system}", flush=True)
    arch = "aarch64" if system == "aarch64-linux" else "x86_64"
    source = REPO_ROOT / f"pkgs/apps/craft-suite/sources/{system}.json"
    pins = json.loads(source.read_text())
    missing = [name for name in CRAFT_APPS if name not in pins]
    if missing:
        raise UpdateError(f"craft source is missing apps: {', '.join(missing)}")
    selected = [app] if app else list(CRAFT_APPS)
    for name in selected:
        release = latest_release(f"storytold/{craft_repo(name)}")
        version = release_version(release)
        asset_name = f"{name}-{version}-linux-{arch}.tar.gz"
        asset = asset_record(release, asset_name)
        url = asset.get("browser_download_url")
        if not url:
            raise UpdateError(f"release asset has no download URL: {asset_name}")
        pins[name] = {
            "hash": sri_hash(asset.get("digest") or "", url),
            "url": url,
            "version": version,
        }
        print(f"Updated {name}-bin for {system} to {version}", flush=True)
    source.write_text(json.dumps(pins, indent=2, sort_keys=True) + "\n")
    validate_package(label, system)


def update_rea():
    update_nix_package("rea")
    source = run(
        ["nix", "build", ".#rea.src", "--no-link", "--print-out-paths"],
        cwd=REPO_ROOT,
        capture_output=True,
    ).stdout.strip()
    lock = json.loads((Path(source) / "package-lock.json").read_text())
    version = lock["packages"]["node_modules/frida"]["version"]
    pins_path = REPO_ROOT / "pkgs/tools/rea/frida.json"
    pins = json.loads(pins_path.read_text())
    if version == pins["version"]:
        run(["nix", "build", ".#rea", "--no-link"], cwd=REPO_ROOT)
        return
    if FRIDA_VERSION_RE.fullmatch(version) is None:
        raise UpdateError(f"invalid Frida version: {version}")
    metadata = github_json(f"https://registry.npmjs.org/frida/{version}")
    napi_versions = metadata.get("binary", {}).get("napi_versions", [])
    napi = max((item for item in napi_versions if isinstance(item, int) and item > 0), default=None)
    if napi is None:
        raise UpdateError(f"Frida {version} has no N-API version")
    release = github_json(f"https://api.github.com/repos/frida/frida/releases/tags/{version}")
    hashes = {}
    for system, arch in (("x86_64-linux", "x64"), ("aarch64-linux", "arm64")):
        asset_name = f"frida-v{version}-napi-v{napi}-linux-{arch}.tar.gz"
        url = f"https://github.com/frida/frida/releases/download/{version}/{asset_name}"
        asset = asset_record(release, asset_name)
        hashes[system] = sri_hash(asset.get("digest") or "", url)
    pins_path.write_text(
        json.dumps({"version": version, "napiVersion": napi, "hashes": hashes}, indent=2) + "\n"
    )
    print(f"Updated Frida bindings to {version} for both Linux architectures", flush=True)
    run(["nix", "build", ".#rea", "--no-link"], cwd=REPO_ROOT)


def update_package(package, system):
    if package == "rea":
        update_rea()
    elif package == "craft-suite-bin":
        update_craft_suite(system)
    elif package.endswith("-bin") and package.removesuffix("-bin") in CRAFT_APPS:
        update_craft_suite(system, package.removesuffix("-bin"))
    elif package in BINARY_PACKAGES:
        update_binary_package(package, system)
    else:
        update_nix_package(package)


def usage():
    print("Usage: nur-packages-update [--arch <system>] <package>...")
    print("       nur-packages-update [--arch <system>] --all")
    print("       nur-packages-update --list")
    print()
    print("Available packages:")
    for package in DEFAULT_PACKAGES:
        print(f"  {package}")


def parse_args(argv):
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--arch", default="x86_64-linux")
    parser.add_argument("--all", action="store_true")
    parser.add_argument("--list", action="store_true")
    parser.add_argument("-h", "--help", action="store_true")
    parser.add_argument("packages", nargs="*")
    args = parser.parse_args(argv)
    if args.help or (not args.packages and not args.all and not args.list):
        usage()
        raise SystemExit(0)
    if args.list:
        for package in DEFAULT_PACKAGES:
            print(package)
        raise SystemExit(0)
    if args.arch not in SYSTEMS:
        print(f"error: unsupported architecture: {args.arch}", file=sys.stderr)
        raise SystemExit(1)
    return DEFAULT_PACKAGES if args.all else args.packages, args.arch


def main(argv=None):
    packages, system = parse_args(sys.argv[1:] if argv is None else argv)
    if not (REPO_ROOT / "flake.nix").is_file() or not (REPO_ROOT / "pkgs").is_dir():
        print(
            f"error: {REPO_ROOT} is not the package repository "
            "(run from the checkout or set NUR_PACKAGES_ROOT)",
            file=sys.stderr,
        )
        return 1
    failures = []
    for package in packages:
        try:
            update_package(package, system)
        except Exception as error:
            print(f"error: failed to update {package}: {error}", file=sys.stderr)
            failures.append(package)
    if failures:
        print(f"error: package updates failed: {' '.join(failures)}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
