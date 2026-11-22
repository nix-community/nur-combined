#!/usr/bin/env python3
"""Update by-name/on/one-api.

Bumps the release version, source hash, the committed npm lockfiles (upstream
does not ship any) and the fetchNpmDeps/vendorHash pins.  Run it through the
package's passthru.updateScript so nodejs is on PATH:

    nix run .#one-api.passthru.updateScript
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.error
import urllib.request
from pathlib import Path

THEMES = ("default", "berry", "air")
UPSTREAM = "songquanpeng/one-api"
FAKE_HASH = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
PACKAGE_PATH = Path("by-name/on/one-api")

VERSION_RE = r'(?m)^(  version = ")[^"]+(";)'
SRC_HASH_RE = r'(rev = "[^"]+";\n\s*hash = ")[^"]+(";)'
VENDOR_HASH_RE = r'(vendorHash = ")[^"]+(";)'


def die(message):
    sys.exit(f"update-one-api: {message}")


def find_repo():
    """Locate the checkout.

    The script is copied into the Nix store by passthru.updateScript, so
    __file__ says nothing about the repository; run from the checkout instead.
    """
    override = os.environ.get("ONE_API_REPO_ROOT")
    if override:
        return Path(override)
    for candidate in (Path.cwd(), *Path.cwd().parents):
        if (candidate / PACKAGE_PATH / "package.nix").is_file():
            return candidate
    die("cannot find the nurpkgs checkout; run this from the repository root")


REPO = find_repo()
ROOT = REPO / PACKAGE_PATH
PACKAGE_NIX = ROOT / "package.nix"


def run(command, cwd=None):
    result = subprocess.run(command, cwd=cwd, text=True, capture_output=True)
    if result.returncode != 0:
        die(
            f"command failed: {' '.join(command)}\n"
            f"{result.stdout}{result.stderr}"
        )
    return result.stdout


def http_get(url):
    request = urllib.request.Request(url, headers={"User-Agent": "nurpkgs-one-api-updater"})
    token = os.environ.get("GITHUB_TOKEN")
    if token:
        request.add_header("Authorization", f"Bearer {token}")
    return urllib.request.urlopen(request, timeout=120)


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, request, file, code, message, headers, new_url):
        return None


def latest_version():
    # github.com/releases/latest redirects to the release tag and is not subject
    # to the API rate limit that /repos/.../releases/latest enforces.
    url = f"https://github.com/{UPSTREAM}/releases/latest"
    opener = urllib.request.build_opener(NoRedirect)
    try:
        opener.open(url, timeout=120)
    except urllib.error.HTTPError as error:
        location = error.headers.get("Location", "")
        if error.code not in (301, 302) or "/tag/" not in location:
            die(f"cannot resolve {url}: HTTP {error.code}")
        tag = location.rstrip("/").rsplit("/", 1)[1]
        if not tag.startswith("v"):
            die(f"unexpected release tag: {tag}")
        return tag[1:]
    die(f"{url} did not redirect to a release tag")


def current_version():
    match = re.search(VERSION_RE, PACKAGE_NIX.read_text())
    if not match:
        die(f"cannot find the version binding in {PACKAGE_NIX}")
    return match.group(0).split('"')[1]


def replace(pattern, value, what):
    text = PACKAGE_NIX.read_text()
    match = re.search(pattern, text, re.S)
    if not match:
        die(f"cannot find {what} in {PACKAGE_NIX}")
    PACKAGE_NIX.write_text(text[: match.end(1)] + value + text[match.start(2) :])


def tarball_url(version):
    return f"https://github.com/{UPSTREAM}/archive/refs/tags/v{version}.tar.gz"


def source_hash(version):
    base32 = run(["nix-prefetch-url", "--unpack", tarball_url(version)]).strip().splitlines()[-1]
    return run(["nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", base32]).strip()


def fetch_and_extract(version, directory):
    archive = directory / "one-api.tar.gz"
    with http_get(tarball_url(version)) as response, open(archive, "wb") as handle:
        shutil.copyfileobj(response, handle)
    unpacked = directory / "src"
    unpacked.mkdir()
    with tarfile.open(archive) as tar:
        try:
            tar.extractall(unpacked, filter="data")
        except TypeError:  # Python < 3.12
            tar.extractall(unpacked)
    return unpacked / f"one-api-{version}"


def refresh_lockfiles(version):
    print(f"  regenerating npm lockfiles from v{version}")
    with tempfile.TemporaryDirectory() as temp:
        src = fetch_and_extract(version, Path(temp))
        for theme in THEMES:
            theme_dir = src / "web" / theme
            run(
                [
                    "npm",
                    "install",
                    "--package-lock-only",
                    "--ignore-scripts",
                    "--no-audit",
                    "--no-fund",
                ],
                cwd=theme_dir,
            )
            destination = ROOT / "locks" / theme / "package-lock.json"
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(theme_dir / "package-lock.json", destination)


def build_hash(attribute):
    result = subprocess.run(
        ["nix", "build", "--no-link", "--print-out-paths", f".#{attribute}"],
        cwd=REPO,
        text=True,
        capture_output=True,
    )
    if result.returncode == 0:
        return None
    match = re.search(r"got:\s+(sha256-[A-Za-z0-9+/=]+)", result.stderr)
    if not match:
        die(f"nix build .#{attribute} failed without a hash mismatch:\n{result.stderr}")
    return match.group(1)


def repin(pattern, attribute, what):
    replace(pattern, FAKE_HASH, what)
    resolved = build_hash(attribute)
    if resolved is None:
        die(f".#{attribute} built with a placeholder hash; refusing to keep it")
    replace(pattern, resolved, what)
    print(f"  {what}: {resolved}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--force",
        action="store_true",
        help="re-pin lockfiles and hashes even if the version is already current",
    )
    args = parser.parse_args()

    version = latest_version()
    pinned = current_version()

    if version == pinned and not args.force:
        print(f"one-api is already at v{pinned}")
        return

    if version != pinned:
        print(f"updating one-api v{pinned} -> v{version}")
        replace(VERSION_RE, version, "version")
        replace(SRC_HASH_RE, source_hash(version), "source hash")
        refresh_lockfiles(version)
    else:
        print(f"re-pinning one-api v{version}")
        refresh_lockfiles(version)

    for theme in THEMES:
        repin(
            rf'(npmDepsHashes = \{{(?:(?!\}};).)*{theme} = ")[^"]+(";)',
            f"one-api.npmDeps.{theme}",
            f"{theme} npm deps hash",
        )
    repin(VENDOR_HASH_RE, "one-api.goModules", "vendor hash")

    print("verifying one-api builds")
    run(["nix", "build", "--no-link", "--print-out-paths", ".#one-api"], cwd=REPO)
    print("done")


if __name__ == "__main__":
    main()
